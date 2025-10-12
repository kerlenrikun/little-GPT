const path = require('path');
const Module = require('module');
const logger = require('../utils/logger');

/**
 * SandboxIsolationManager - 统一管理所有沙箱隔离逻辑
 * 
 * 职责：
 * - 创建完全隔离的VM沙箱环境
 * - 统一管理模块系统、进程环境、全局对象的隔离
 * - 提供安全、一致的沙箱执行上下文
 */
class SandboxIsolationManager {
  constructor(workingPath, options = {}) {
    this.workingPath = workingPath;  // 工作目录（~/.promptx）
    this.toolboxPath = options.toolboxPath || workingPath;  // 工具箱目录（用于依赖加载）
    this.sandboxPath = workingPath;  // 向后兼容
    this.options = {
      enableDependencyLoading: true,
      enableBuiltinModules: true,
      enableFileSystemAccess: false,
      ...options
    };
    this.isolatedContext = null;
  }

  /**
   * 创建完全隔离的沙箱环境
   * @returns {Object} 隔离的沙箱上下文
   */
  createIsolatedContext() {
    if (this.isolatedContext) {
      return this.isolatedContext;
    }

    this.isolatedContext = {
      // 1. 模块系统隔离 - 核心功能
      require: this.createIsolatedRequire(),
      module: { exports: {} },
      exports: {},
      
      // 2. 进程环境隔离
      process: this.createIsolatedProcess(),
      
      // 3. 全局对象隔离
      ...this.createIsolatedGlobals(),
      
      // 4. 路径相关隔离
      __dirname: this.workingPath,
      __filename: path.join(this.workingPath, 'sandbox.js'),
      
      // 5. 注入受限的 fs（直接可用）
      fs: this.createRestrictedFS(),
      
      // 6. 阻止动态代码执行
      eval: () => {
        throw new Error('[SandboxIsolation] eval is not allowed in sandbox');
      },
      Function: undefined
    };

    return this.isolatedContext;
  }

  /**
   * 创建隔离的require函数 - 解决核心依赖加载问题
   * @returns {Function} 隔离的require函数
   */
  createIsolatedRequire() {
    // 关键：使用Module.createRequire创建绑定到toolbox路径的require
    const contextFile = path.join(this.toolboxPath, 'package.json');
    let sandboxRequire;
    
    try {
      // 创建绑定到toolbox上下文的require（依赖在这里）
      sandboxRequire = Module.createRequire(contextFile);
    } catch (error) {
      // fallback: 如果package.json不存在，使用虚拟路径
      const virtualContextFile = path.join(this.toolboxPath, 'virtual-context.js');
      sandboxRequire = Module.createRequire(virtualContextFile);
    }

    // 返回增强的require函数
    return (moduleName) => {
      // 拦截 fs 和相关模块
      if (moduleName === 'fs' || moduleName === 'fs/promises') {
        return this.createRestrictedFS();
      }
      
      // 拦截 child_process，禁止使用
      if (moduleName === 'child_process') {
        throw new Error('[SandboxIsolation] child_process is not allowed in sandbox');
      }
      
      // 拦截 path 模块，提供受限版本
      if (moduleName === 'path') {
        return this.createRestrictedPath();
      }
      
      try {
        // 优先使用沙箱require（自动处理符号链接）
        return sandboxRequire(moduleName);
      } catch (error) {
        // 智能fallback处理
        return this.handleRequireFallback(moduleName, error);
      }
    };
  }

  /**
   * 处理require失败的智能fallback
   * @param {string} moduleName - 模块名
   * @param {Error} error - 原始错误
   * @returns {*} 模块对象或抛出错误
   */
  handleRequireFallback(moduleName, error) {
    // 1. 尝试加载Node.js内置模块
    if (this.options.enableBuiltinModules && this.isBuiltinModule(moduleName)) {
      try {
        return require(moduleName);
      } catch (builtinError) {
        // 内置模块加载失败，继续下一步
      }
    }

    // 2. 如果是分析阶段且模块不存在，返回mock对象
    if (this.options.analysisMode && error.code === 'MODULE_NOT_FOUND') {
      logger.debug(`[SandboxIsolation] Analysis mode: mocking module ${moduleName}`);
      return this.createMockModule();
    }

    // 3. 其他情况直接抛出原始错误
    throw error;
  }

  /**
   * 检查是否为Node.js内置模块
   * @param {string} moduleName - 模块名
   * @returns {boolean} 是否为内置模块
   */
  isBuiltinModule(moduleName) {
    const builtinModules = [
      'path', 'fs', 'url', 'crypto', 'util', 'os', 'events', 'stream',
      'http', 'https', 'querystring', 'zlib', 'buffer', 'child_process'
    ];
    
    return builtinModules.includes(moduleName) || moduleName.startsWith('node:');
  }

  /**
   * 创建mock模块对象
   * @returns {Object} mock对象
   */
  createMockModule() {
    return new Proxy({}, {
      get: () => () => ({}),  // 所有属性和方法都返回空函数/对象
      apply: () => ({}),      // 如果被当作函数调用
      construct: () => ({})   // 如果被当作构造函数
    });
  }

  /**
   * 创建受限的文件系统
   * 实现完全透明的拦截，在VM层面控制文件访问边界
   * @returns {Object} 受限的fs对象
   */
  createRestrictedFS() {
    const realFs = require('fs');
    const boundary = path.resolve(this.workingPath); // 转为绝对路径
    
    logger.info(`[SandboxFS] Creating restricted FS with boundary: ${boundary}`);
    
    // 核心：智能路径解析，防止相对路径越权
    const resolveSafePath = (inputPath) => {
      // 处理undefined或null的情况
      if (!inputPath) {
        throw new Error('[SandboxFS] Path is required');
      }
      
      // 1. 处理各种路径形式
      let resolved;
      
      if (path.isAbsolute(inputPath)) {
        // 绝对路径：直接解析
        resolved = path.resolve(inputPath);
      } else {
        // 相对路径：基于 workingPath 解析
        // 这是关键！防止 ../../ 越权
        resolved = path.resolve(boundary, inputPath);
      }
      
      // 2. 规范化路径（处理 .. 和 . ）
      resolved = path.normalize(resolved);
      
      // 3. 边界检查
      if (!resolved.startsWith(boundary)) {
        // 记录详细信息用于调试
        logger.error(`[SandboxFS] 文件访问越权尝试：
          输入路径: ${inputPath}
          解析结果: ${resolved}
          允许边界: ${boundary}
          调用栈: ${new Error().stack}
        `);
        
        throw new Error(
          `[SandboxFS] 文件访问被拒绝：路径 "${inputPath}" 超出工作目录边界 ${boundary}`
        );
      }
      
      return resolved;
    };
    
    // 创建 Proxy 来拦截所有 fs 操作
    const handler = {
      get(target, prop) {
        const original = target[prop];
        
        // 如果不是函数，直接返回
        if (typeof original !== 'function') {
          // 处理 fs.promises
          if (prop === 'promises') {
            return new Proxy(realFs.promises, {
              get(promiseTarget, promiseProp) {
                const promiseOriginal = promiseTarget[promiseProp];
                if (typeof promiseOriginal !== 'function') {
                  return promiseOriginal;
                }
                
                // 包装 promises 方法
                return async function(...args) {
                  // 识别路径参数（通常是第一个）
                  if (args.length > 0 && typeof args[0] === 'string') {
                    args[0] = resolveSafePath(args[0]);
                  }
                  
                  // 处理 rename、copyFile 等双路径操作
                  if ((promiseProp === 'rename' || promiseProp === 'copyFile') && args.length > 1) {
                    args[1] = resolveSafePath(args[1]);
                  }
                  
                  // 调用原始函数
                  return await promiseOriginal.apply(promiseTarget, args);
                };
              }
            });
          }
          
          return original;
        }
        
        // 包装同步函数
        return function(...args) {
          // 识别路径参数（通常是第一个）
          if (args.length > 0 && typeof args[0] === 'string') {
            args[0] = resolveSafePath(args[0]);
          }
          
          // 处理 rename、copyFile 等双路径操作
          if ((prop === 'renameSync' || prop === 'copyFileSync') && args.length > 1) {
            args[1] = resolveSafePath(args[1]);
          }
          
          // 调用原始函数
          return original.apply(target, args);
        };
      }
    };
    
    // 返回代理的 fs 对象
    return new Proxy(realFs, handler);
  }

  /**
   * 创建受限的 path 模块
   * 防止使用 path.resolve 绕过限制
   * @returns {Object} 受限的path对象
   */
  createRestrictedPath() {
    const realPath = require('path');
    const boundary = path.resolve(this.workingPath);
    
    return new Proxy(realPath, {
      get(target, prop) {
        if (prop === 'resolve') {
          return (...args) => {
            const resolved = target.resolve(...args);
            // 如果解析结果超出边界，记录警告
            if (!resolved.startsWith(boundary)) {
              logger.warn(`[SandboxPath] path.resolve 尝试越权: ${resolved}`);
            }
            return resolved;
          };
        }
        return target[prop];
      }
    });
  }

  /**
   * 创建隔离的process对象
   * @returns {Object} 隔离的process对象
   */
  createIsolatedProcess() {
    return {
      // 环境变量（浅拷贝，避免污染）
      env: { ...process.env },
      
      // 工作目录返回 workingPath（~/.promptx）
      cwd: () => this.workingPath,
      
      // 安全的只读属性
      version: process.version,
      platform: process.platform,
      arch: process.arch,
      pid: process.pid,
      
      // 时间相关
      hrtime: process.hrtime,
      uptime: process.uptime,
      
      // 禁用危险方法
      exit: () => { throw new Error('[SandboxIsolation] process.exit() is not allowed in sandbox'); },
      abort: () => { throw new Error('[SandboxIsolation] process.abort() is not allowed in sandbox'); },
      
      // 阻止底层访问
      binding: () => {
        throw new Error('[SandboxIsolation] process.binding() is not allowed in sandbox');
      },
      dlopen: () => {
        throw new Error('[SandboxIsolation] Native modules are not allowed in sandbox');
      }
    };
  }

  /**
   * 创建隔离的全局对象
   * @returns {Object} 安全的全局对象集合
   */
  createIsolatedGlobals() {
    return {
      // 基础类型
      Object: Object,
      Array: Array,
      String: String,
      Number: Number,
      Boolean: Boolean,
      Date: Date,
      RegExp: RegExp,
      Error: Error,
      
      // JSON处理
      JSON: JSON,
      
      // 数学对象
      Math: Math,
      
      // URL处理
      URL: URL,
      URLSearchParams: URLSearchParams,
      
      // 缓冲区
      Buffer: Buffer,
      
      // 定时器
      setTimeout: setTimeout,
      clearTimeout: clearTimeout,
      setInterval: setInterval,
      clearInterval: clearInterval,
      setImmediate: setImmediate,
      clearImmediate: clearImmediate,
      
      // 输出
      console: console,  // Keep console for sandboxed code
      
      // Promise相关
      Promise: Promise
    };
  }

  /**
   * 启用分析模式 - 用于工具分析阶段
   */
  enableAnalysisMode() {
    this.options.analysisMode = true;
    // 重置上下文以应用新选项
    this.isolatedContext = null;
  }

  /**
   * 启用执行模式 - 用于工具执行阶段
   */
  enableExecutionMode() {
    this.options.analysisMode = false;
    // 重置上下文以应用新选项
    this.isolatedContext = null;
  }

  /**
   * 清理隔离管理器
   */
  cleanup() {
    this.isolatedContext = null;
  }

  /**
   * 获取隔离状态信息
   * @returns {Object} 状态信息
   */
  getIsolationStatus() {
    return {
      sandboxPath: this.sandboxPath,
      options: this.options,
      contextCreated: !!this.isolatedContext,
      timestamp: new Date().toISOString()
    };
  }
}

module.exports = SandboxIsolationManager;