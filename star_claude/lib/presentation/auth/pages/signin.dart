import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:star_claude/common/__init__.dart';
import 'package:star_claude/core/configs/__init__.dart';
import 'package:star_claude/domain/entities/auth/user.dart';
import 'package:star_claude/domain/repository/user_repository.dart';
import 'package:star_claude/presentation/home/widgets/base_button.dart';
import 'package:star_claude/presentation/page__init__.dart';
import 'package:star_claude/models/router.dart';
import 'package:star_claude/domain/provider/user_provider.dart';
import 'package:star_claude/presentation/auth/utils/storage_utils.dart';
import 'package:star_claude/common/utils/string_utils.dart';
import 'package:star_claude/presentation/auth/utils/animated_disappear_widget.dart';

class SigninPage extends StatefulWidget {
  const SigninPage({super.key});

  @override
  State<SigninPage> createState() => _SigninPageState();
}

class _SigninPageState extends State<SigninPage> with TickerProviderStateMixin {
  // 控制器和键
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final GlobalKey _phoneNumberFieldKey = GlobalKey();
  final FocusNode _phoneNumberFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();
  final GlobalKey<State<AnimatedDisappearWidget>> _animatedButtonKey =
      GlobalKey();

  // 状态管理变量
  String? _errorMessage;
  bool _isPasswordVisible = false; // 控制密码是否可见
  bool _shouldRememberCredentials = false; // 控制是否记住登录凭证
  double _phoneNumberFieldOffset = 0.0;
  double _passwordFieldOffset = 0.0;
  double _loginFormOpacity = 0.0; // 控制登录表单的透明度

  // 数据和存储
  late UserRepository _userRepository;
  List<Map<String, dynamic>> _loginHistory = []; // 存储登录历史记录
  /// 用户信息
  UserProvider get userProvider =>
      Provider.of<UserProvider>(context, listen: false);

  //------------------------------------------------------------------------------
  // 生命周期方法
  //------------------------------------------------------------------------------
  @override
  void initState() {
    super.initState();
    _userRepository = UserRepository();
    _loadLastLoginCredentials();
    _loadLoginHistory();

    // 添加焦点监听器
    _phoneNumberFocusNode.addListener(() {
      setState(() {
        _phoneNumberFieldOffset = _phoneNumberFocusNode.hasFocus ? -5.0 : 0.0;
      });
    });

    _passwordFocusNode.addListener(() {
      setState(() {
        _passwordFieldOffset = _passwordFocusNode.hasFocus ? -5.0 : 0.0;
      });
    });

    // 添加页面加载动画
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        _loginFormOpacity = 1.0;
      });
    });
  }

  @override
  void dispose() {
    _phoneNumberController.dispose();
    _passwordController.dispose();
    _phoneNumberFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  //------------------------------------------------------------------------------
  // 数据加载和存储方法
  //------------------------------------------------------------------------------
  /// 加载登录历史记录
  Future<void> _loadLoginHistory() async {
    final history = await StorageUtils.getLoginHistory();
    setState(() {
      _loginHistory = history;
    });
  }

  /// 加载上次登录的用户凭证
  Future<void> _loadLastLoginCredentials() async {
    final credentials = await StorageUtils.getLastLoginCredentials();
    if (credentials != null) {
      setState(() {
        _phoneNumberController.text = credentials['phoneNumber'] as String;
        _passwordController.text = credentials['password'] as String;
        _shouldRememberCredentials = true;
      });
    }
  }

  //------------------------------------------------------------------------------
  // 业务逻辑处理方法
  //------------------------------------------------------------------------------
  /// 处理用户登录逻辑
  Future<void> _handleLogin() async {
    if (!FeishuConfig.isConfigValid) {
      if (mounted) {
        setState(() {
          _errorMessage = '飞书配置未完成，请先配置FeishuConfig.dart文件';
        });
      }
      return;
    }

    final phoneNumber = _phoneNumberController.text.trim();
    final password = _passwordController.text.trim();

    if (phoneNumber.isEmpty || password.isEmpty) {
      if (mounted) {
        setState(() {
          _errorMessage = '请填写手机号和密码';
        });
      }
      return;
    }

    // 触发按钮消失动画
    final animatedState = _animatedButtonKey.currentState;
    if (animatedState != null) {
      (animatedState as dynamic).startAnimation();
    }

    try {
      // 等待动画完成后再设置加载状态
      await Future.delayed(const Duration(milliseconds: 200));

      // 登录验证
      final result = await _userRepository.loginUser(
        phoneNumber,
        password,
        userProvider.currentUser.job ?? '',
      );

      if (mounted) {
        // 重置动画
        final animatedState = _animatedButtonKey.currentState;
        if (animatedState != null) {
          (animatedState as dynamic).resetAnimation();
        }
      }

      if (result['success'] == true) {
        // 保存登录凭证到本地存储
        await StorageUtils.saveLastLoginCredentials(
          phoneNumber: phoneNumber,
          password: password,
          shouldRemember: _shouldRememberCredentials,
        );
        final userProvider = Provider.of<UserProvider>(context, listen: false);
        // 登录成功
        if (mounted) {
          userProvider.setUserAndLogin(result['entity']);

          // 显示登录成功提示
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: Colors.transparent,
              duration: const Duration(milliseconds: 600), // 缩短显示时间为1.5秒
              content: const Text(
                '登录成功!',
                style: TextStyle(color: Colors.white),
                textAlign: TextAlign.center,
              ),
            ),
          );

          // 清空表单
          _phoneNumberController.clear();
          _passwordController.clear();

          // 异步延迟，让提示信息有时间显示
          await Future.delayed(const Duration(seconds: 0));

          // 登录成功后导航到主页
          if (mounted) {
            context.to(HomePage);
          }
        }
      } else {
        if (mounted) {
          // 重置动画
          final animatedState = _animatedButtonKey.currentState;
          if (animatedState != null) {
            (animatedState as dynamic).resetAnimation();
          }
          setState(() {
            _errorMessage = result['message'] ?? '登录失败，请检查手机号和密码';
          });
        }
      }
    } catch (e) {
      if (mounted) {
        // 重置动画
        final animatedState = _animatedButtonKey.currentState;
        if (animatedState != null) {
          (animatedState as dynamic).resetAnimation();
        }
        setState(() {
          _errorMessage = '登录过程中发生错误: $e';
        });
      }
    }
  }

  //------------------------------------------------------------------------------
  // UI交互控制方法
  //------------------------------------------------------------------------------
  /// 切换密码可见性
  void _togglePasswordVisibility() {
    setState(() {
      _isPasswordVisible = !_isPasswordVisible;
    });
  }

  /// 显示登录历史记录弹出菜单
  void _showLoginHistoryMenu() {
    if (_loginHistory.isEmpty) {
      return;
    }

    // 获取输入框的位置信息
    final RenderBox? textFieldRenderBox =
        _phoneNumberFieldKey.currentContext?.findRenderObject() as RenderBox?;

    if (textFieldRenderBox == null) {
      return;
    }

    final Offset textFieldPosition = textFieldRenderBox.localToGlobal(
      Offset.zero,
    );
    final Size textFieldSize = textFieldRenderBox.size;

    // 创建菜单项列表
    List<PopupMenuEntry> menuItems = [];

    // 添加标题
    menuItems.add(
      PopupMenuItem(
        height: 0,
        enabled: false,
        child: ListTile(
          minTileHeight: 12,
          minLeadingWidth: 8,
          dense: true,
          onTap: () {},
          leading: Icon(Icons.key, size: 14, color: Colors.white),
          title: Text(
            '历史登录',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );

    // 添加分隔线
    menuItems.add(const PopupMenuDivider(height: 4));

    // 添加登录历史记录项
    for (var record in _loginHistory) {
      final phoneNumber = record['phoneNumber'] as String;
      final password = record['password'] as String;

      menuItems.add(
        PopupMenuItem(
          padding: EdgeInsets.zero,
          child: ListTile(
            dense: true,
            contentPadding: const EdgeInsets.symmetric(horizontal: 20),
            hoverColor: Colors.white.withOpacity(0.1),
            onTap: () {
              setState(() {
                _phoneNumberController.text = phoneNumber;
                _passwordController.text = password;
                _shouldRememberCredentials = true;
              });
              Navigator.pop(context);
            },
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  phoneNumber + '                           ',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: Colors.white,
                  ),
                ),
                Text(
                  '* ' * password.length,
                  style: TextStyle(fontSize: 12, color: Colors.white70),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // 添加底部分隔线和管理选项
    menuItems.add(const PopupMenuDivider(height: 4));

    // 显示弹出菜单形状位置设定
    showMenu(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(2),
          topRight: Radius.circular(2),
          bottomLeft: Radius.circular(2),
          bottomRight: Radius.circular(4),
        ),
      ),
      color: Color(0xff142634).withOpacity(0.95),
      // 添加毛玻璃效果相关参数
      surfaceTintColor: Color.fromARGB(255, 27, 31, 33), // 毛玻璃效果的表面色调
      elevation: 8, // 增加阴影提升立体感
      position: RelativeRect.fromLTRB(
        textFieldPosition.dx + 28,
        textFieldPosition.dy + textFieldSize.height + 2,
        textFieldPosition.dx + textFieldSize.width, //左边界 + 宽度 = 右边界
        0,
      ),
      items: menuItems,
    );
  }

  //------------------------------------------------------------------------------
  // UI组件构建方法
  //------------------------------------------------------------------------------
  /// 登录标题文本
  Widget _loginText() {
    return const Text(
      'Sign In',
      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
      textAlign: TextAlign.center,
    );
  }

  /// 手机号输入框
  Widget _phoneNumberField(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      transform: Matrix4.translationValues(0, _phoneNumberFieldOffset, 0),
      child: TextField(
        key: _phoneNumberFieldKey,
        controller: _phoneNumberController,
        focusNode: _phoneNumberFocusNode,
        keyboardType: TextInputType.phone,
        decoration: InputDecoration(
          hintText: 'Phone Number',
          border: const OutlineInputBorder(),
          suffixIcon: Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: _loginHistory.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.history),
                    onPressed: _showLoginHistoryMenu,
                    color: Colors.grey,
                  )
                : null,
          ),
        ),
      ),
    );
  }

  /// 密码输入框
  Widget _passwordField(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      transform: Matrix4.translationValues(0, _passwordFieldOffset, 0),
      child: TextField(
        controller: _passwordController,
        focusNode: _passwordFocusNode,
        obscureText: !_isPasswordVisible, // 根据_isPasswordVisible控制是否显示密码
        decoration: InputDecoration(
          hintText: 'Password',
          border: const OutlineInputBorder(),
          suffixIcon: Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: IconButton(
              icon: Icon(
                // 根据密码可见性状态显示不同图标
                _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                color: Colors.grey,
              ),
              onPressed: _togglePasswordVisibility, // 点击切换密码可见性
            ),
          ),
        ),
      ),
    );
  }

  /// 记住我复选框
  Widget _rememberMeCheckbox() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Checkbox(
          value: _shouldRememberCredentials,
          onChanged: (value) {
            setState(() {
              _shouldRememberCredentials = value ?? false;
            });
          },
          activeColor: const Color(0xff00a8e9),
          checkColor: Colors.white,
        ),
        const Text(
          'Remember Me',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  /// 错误提示
  Widget _errorText() {
    return AnimatedOpacity(
      opacity: _errorMessage != null ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 300),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
        child: Row(
          children: [
            Icon(Icons.error_outline, color: Colors.red[400], size: 18),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                _errorMessage!,
                style: const TextStyle(color: Colors.red, fontSize: 14),
                textAlign: TextAlign.start,
                overflow: TextOverflow.visible,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 帮助提示
  Widget _helpText(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'If You Need Any Support',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w400,
            color: Color(0xff9e9e9e),
          ),
        ),
        TextButton(
          onPressed: () {},
          child: const Text(
            'Click Here',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: Color(0xff38B432),
            ),
          ),
        ),
      ],
    );
  }

  /// 注册链接文本
  Widget _registerText(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 30),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Not A Member ?',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
          TextButton(
            onPressed: () => context.to(RegisterPage),
            child: const Text(
              'Register Now',
              style: TextStyle(color: Color(0xff00a8e9)),
            ),
          ),
        ],
      ),
    );
  }

  /// 处理登录按钮按下状态
  void _onLoginButtonPressed() async {
    // 执行登录逻辑
    await _handleLogin();
  }

  //------------------------------------------------------------------------------
  // 主构建方法
  //------------------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: _registerText(context),
      appBar: BasicAppBar(
        title: Transform.scale(
          scale: 0.58,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Image.asset(AppImages.logo),
              SizedBox(width: 15),
              SvgPicture.asset(AppVectors.logo),
            ],
          ),
        ),
      ),
      body: Padding(
        padding: EdgeInsetsGeometry.only(
          top: 80,
          bottom: 50,
          left: 30,
          right: 30,
        ),
        child: FadeTransition(
          opacity: AlwaysStoppedAnimation(_loginFormOpacity),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _loginText(),
              const SizedBox(height: 12),
              _helpText(context),
              const SizedBox(height: 28),
              _phoneNumberField(context),
              const SizedBox(height: 16),
              _passwordField(context),
              const SizedBox(height: 20),
              if (_errorMessage != null)
                // 错误提示
                _errorText(),
              // 记住我复选框
              _rememberMeCheckbox(),
              const SizedBox(height: 6),
              // 登录按钮与动画 - 使用AnimatedDisappearWidget
              AnimatedDisappearWidget(
                key: _animatedButtonKey,
                loadingWidget: const CircularProgressIndicator(
                  color: AppColors.primary,
                  strokeWidth: 5,
                ),
                child: BasicAppButton(
                  onPressed: _onLoginButtonPressed,
                  title: 'Sign In',
                  letterspacing: 1,
                  fontsize: 17,
                  width: 279 + 30,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

