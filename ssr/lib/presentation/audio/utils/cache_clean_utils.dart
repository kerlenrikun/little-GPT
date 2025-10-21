import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:dio/dio.dart';
import 'package:path/path.dart' as p;
import 'package:shared_preferences/shared_preferences.dart';

/// 音频缓存管理器 - 单例模式
class AudioCacheManager {
  static final AudioCacheManager _instance = AudioCacheManager._internal();
  factory AudioCacheManager() => _instance;

  AudioCacheManager._internal();

  late Directory _cacheDir;
  late File _indexFile;
  Map<String, dynamic> _index = {};

  /// 初始化缓存管理器
  Future<void> init() async {
    // 获取应用文档目录的上级目录下的cache文件夹
    final appDir = await getApplicationDocumentsDirectory();
    final parentDir = appDir.parent;
    _cacheDir = Directory(p.join(parentDir.path, "cache", "audio_cache"));

    if (!(await _cacheDir.exists())) {
      await _cacheDir.create(recursive: true);
    }

    _indexFile = File("${_cacheDir.path}/cache_index.json");
    if (await _indexFile.exists()) {
      try {
        _index = jsonDecode(await _indexFile.readAsString());
      } catch (e) {
        print("缓存索引文件解析失败: $e");
        _index = {};
      }
    }
  }

  /// 保存索引文件
  Future<void> _saveIndex() async {
    try {
      await _indexFile.writeAsString(jsonEncode(_index));
    } catch (e) {
      print("保存缓存索引失败: $e");
    }
  }

  /// 获取缓存文件（如果存在且完整）
  Future<File?> getCachedFile(String url) async {
    final info = _index[url];
    if (info == null) return null;

    final file = File(info['filePath']);
    if (!await file.exists()) {
      // 文件不存在，从索引中移除
      _index.remove(url);
      await _saveIndex();
      return null;
    }

    recordAccess(url);
    return file;
  }

  /// 记录访问时间
  void recordAccess(String url) {
    if (_index[url] != null) {
      _index[url]['lastAccess'] = DateTime.now().toIso8601String();
      _saveIndex();
    }
  }

  /// 分段缓存音频
  Future<File> cacheAudio(
    String url, {
    int chunkSize = 1 * 1024 * 1024,
    void Function(double progress)? onProgress,
  }) async {
    final dio = Dio();
    final fileName = Uri.parse(url).pathSegments.last.isEmpty
        ? 'audio_${DateTime.now().millisecondsSinceEpoch}.mp3'
        : Uri.parse(url).pathSegments.last;

    final targetFile = File("${_cacheDir.path}/$fileName");
    final tempFile = File("${targetFile.path}.temp");

    // 检查临时文件是否存在，支持断点续传
    int downloaded = await tempFile.exists() ? await tempFile.length() : 0;

    try {
      // 发送请求获取文件流
      final response = await dio.get<ResponseBody>(
        url,
        options: Options(
          responseType: ResponseType.stream,
          headers: downloaded > 0 ? {'range': 'bytes=$downloaded-'} : null,
        ),
      );

      // 获取文件总大小
      final totalSize = _getTotalSize(response, downloaded);

      // 打开文件追加写入
      final raf = tempFile.openSync(mode: FileMode.append);
      final stream = response.data!.stream;

      // 下载进度跟踪
      int receivedBytes = downloaded;

      await for (final chunk in stream) {
        raf.writeFromSync(chunk);
        receivedBytes += chunk.length;

        // 回调进度
        if (onProgress != null && totalSize > 0) {
          onProgress(receivedBytes / totalSize);
        }
      }

      await raf.close();

      // 下载完成 -> 重命名
      await tempFile.rename(targetFile.path);

      // 更新索引
      _index[url] = {
        'filePath': targetFile.path,
        'lastAccess': DateTime.now().toIso8601String(),
        'isComplete': true,
        'totalSize': await targetFile.length(),
      };
      await _saveIndex();

      return targetFile;
    } catch (e) {
      print("音频缓存失败: $e");
      // 如果失败且有现有缓存，返回现有缓存
      if (await targetFile.exists()) {
        return targetFile;
      }
      rethrow;
    }
  }

  /// 从响应头中获取文件总大小
  int _getTotalSize(Response<ResponseBody> response, int downloaded) {
    final contentLength = response.headers.value('content-length');
    final contentRange = response.headers.value('content-range');

    if (contentRange != null) {
      // Content-Range: bytes 0-1023/2048
      final match = RegExp(r'/([0-9]+)').firstMatch(contentRange);
      if (match != null) {
        return int.parse(match.group(1)!);
      }
    }

    if (contentLength != null) {
      return int.parse(contentLength) + downloaded;
    }

    return 0;
  }

  /// 清理 N 天未访问的缓存
  Future<void> cleanOldCache({
    Duration maxAge = const Duration(days: 2),
  }) async {
    final now = DateTime.now();
    final toRemove = <String>[];

    for (final entry in _index.entries) {
      final lastAccessStr = entry.value['lastAccess'];
      if (lastAccessStr == null) continue;

      final lastAccess = DateTime.tryParse(lastAccessStr);
      if (lastAccess == null || now.difference(lastAccess) > maxAge) {
        // 删除对应的缓存文件
        final filePath = entry.value['filePath'];
        if (filePath != null) {
          try {
            final file = File(filePath);
            if (await file.exists()) {
              await file.delete();
            }
          } catch (e) {
            print("删除缓存文件失败: $filePath, 错误: $e");
          }
        }
        toRemove.add(entry.key);
      }
    }

    // 从索引中移除
    for (final key in toRemove) {
      _index.remove(key);
    }

    // 保存更新后的索引
    await _saveIndex();
  }

  /// 清理所有缓存
  Future<void> cleanAllCache() async {
    try {
      // 删除所有缓存文件
      if (await _cacheDir.exists()) {
        final files = await _cacheDir.list().toList();
        for (final file in files) {
          if (file is File && file.path != _indexFile.path) {
            await file.delete();
          }
        }
      }

      // 清空索引
      _index.clear();
      await _saveIndex();
    } catch (e) {
      print("清理所有缓存失败: $e");
    }
  }

  /// 获取缓存大小
  Future<int> getCacheSize() async {
    int totalSize = 0;

    if (await _cacheDir.exists()) {
      final files = await _cacheDir.list(recursive: true).toList();
      for (final file in files) {
        if (file is File) {
          try {
            totalSize += await file.length();
          } catch (e) {
            print("获取文件大小失败: ${file.path}, 错误: $e");
          }
        }
      }
    }

    return totalSize;
  }

  /// 获取缓存文件数量
  int getCacheCount() {
    return _index.length;
  }

  /// 格式化缓存大小显示
  String formatSize(int bytes) {
    if (bytes < 1024)
      return '$bytes B';
    else if (bytes < 1024 * 1024)
      return '${(bytes / 1024).toStringAsFixed(2)} KB';
    else if (bytes < 1024 * 1024 * 1024)
      return '${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB';
    else
      return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
  }
}

/// 缓存清理工具类（提供更便捷的清理方法）
class CacheCleanUtils {
  static final AudioCacheManager _cacheManager = AudioCacheManager();

  /// 初始化缓存管理器
  static Future<void> init() async {
    await _cacheManager.init();
  }

  /// 清理指定天数之前的缓存
  static Future<void> cleanOldCache({int days = 2}) async {
    await _cacheManager.cleanOldCache(maxAge: Duration(days: days));
  }

  /// 清理所有缓存
  static Future<void> cleanAllCache() async {
    await _cacheManager.cleanAllCache();
  }

  /// 获取缓存信息（大小和数量）
  static Future<Map<String, dynamic>> getCacheInfo() async {
    final size = await _cacheManager.getCacheSize();
    final count = _cacheManager.getCacheCount();
    return {
      'size': size,
      'formattedSize': _cacheManager.formatSize(size),
      'count': count,
    };
  }

  /// 定期清理任务（可在应用启动时调用）
  static Future<void> scheduledCleanup() async {
    await init();

    // 检查上次清理时间
    final prefs = await SharedPreferences.getInstance();
    final lastCleanKey = 'last_cache_cleanup';
    final lastCleanStr = prefs.getString(lastCleanKey);

    final now = DateTime.now();
    if (lastCleanStr == null) {
      // 首次运行，清理3天前的缓存
      await cleanOldCache(days: 3);
      await prefs.setString(lastCleanKey, now.toIso8601String());
    } else {
      final lastClean = DateTime.tryParse(lastCleanStr);
      if (lastClean != null && now.difference(lastClean).inDays >= 1) {
        // 每天清理一次，清理2天前的缓存
        await cleanOldCache(days: 2);
        await prefs.setString(lastCleanKey, now.toIso8601String());
      }
    }
  }
}
