import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:ssr/common/widget/appbar/app_bar.dart';
import 'package:ssr/core/config/assets/app_images.dart';
import 'package:ssr/core/config/assets/app_vector.dart';
import 'package:ssr/data/config/feishu_config.dart';
import 'package:ssr/domain/entity/user.dart';
import 'package:ssr/domain/provider/user_provider.dart';

import 'package:ssr/model/router.dart';
import 'package:ssr/core/config/theme/app_colors.dart';

import 'package:ssr/domain/repository/user_repository.dart';
import 'package:ssr/common/widget/button/basic_app_button.dart';
import 'package:ssr/common/animated/disappear.dart';
import 'package:ssr/presentation/auth/signin.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> with TickerProviderStateMixin {
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final GlobalKey<State<Disappear>> _animatedButtonKey = GlobalKey();
  final GlobalKey _fullNameFieldKey = GlobalKey();
  final GlobalKey _phoneNumberFieldKey = GlobalKey();
  final FocusNode _fullNameFocusNode = FocusNode();
  final FocusNode _phoneNumberFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();

  String? _errorMessage;
  bool _isPasswordVisible = false; // 控制密码是否可见
  double _fullNameFieldOffset = 0.0;
  double _phoneNumberFieldOffset = 0.0;
  double _passwordFieldOffset = 0.0;

  late UserRepository _userRepository;

  @override
  void initState() {
    super.initState();
    _userRepository = UserRepository();

    // 添加焦点监听器
    _fullNameFocusNode.addListener(() {
      setState(() {
        _fullNameFieldOffset = _fullNameFocusNode.hasFocus ? -5.0 : 0.0;
      });
    });

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
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneNumberController.dispose();
    _passwordController.dispose();
    _fullNameFocusNode.dispose();
    _phoneNumberFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  // 切换密码可见性
  void _passwordVisibility() {
    setState(() {
      _isPasswordVisible = !_isPasswordVisible;
    });
  }

  Future<void> _handleSignup() async {
    if (!FeishuConfig.isConfigValid) {
      setState(() {
        _errorMessage = '飞书配置未完成，请先配置FeishuConfig.dart文件';
      });
      return;
    }

    final fullName = _fullNameController.text.trim();
    final phoneNumber = _phoneNumberController.text.trim();
    final password = _passwordController.text.trim();

    if (fullName.isEmpty || phoneNumber.isEmpty || password.isEmpty) {
      setState(() {
        _errorMessage = '请填写所有必填字段';
      });
      return;
    }

    // 触发动画
    final animatedState = _animatedButtonKey.currentState;
    if (animatedState != null) {
      (animatedState as dynamic).startAnimation();
    }

    setState(() {
      _errorMessage = null;
    });

    try {
      // 检查手机号是否已注册
      final isRegistered = await _userRepository.isPhoneNumberExist(
        //phoneNumberExist
        phoneNumber,
      );
      if (isRegistered) {
        // 重置动画
        final animatedState = _animatedButtonKey.currentState;
        if (animatedState != null) {
          (animatedState as dynamic).resetAnimation();
        }
        setState(() {
          _errorMessage = '该手机号已注册';
        });
        return;
      }

      // 更新用户模型
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      // 创建当前用户实体
      UserEntity userEntity = UserEntity(
        fullName: fullName,
        phoneNumber: phoneNumber,
        password: password,
        job: userProvider.currentUser.job,
        allowJob: userProvider.currentUser.job != null
            ? {userProvider.currentUser.job!: 1}
            : {},
      );

      // 注册用户
      final result = await _userRepository.registerUser(userEntity);

      // 重置动画
      final animatedState = _animatedButtonKey.currentState;
      if (animatedState != null) {
        (animatedState as dynamic).resetAnimation();
      }

      if (result['success'] == true) {
        // 注册成功
        if (mounted) {
          // 登入
          userProvider.setUserAndLogin(userEntity);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: Colors.transparent,
              content: const Text(
                '注册成功!',
                style: TextStyle(color: Colors.white),
                textAlign: TextAlign.center,
              ),
            ),
          );

          // 清空表单
          _fullNameController.clear();
          _phoneNumberController.clear();
          _passwordController.clear();

          // 可以导航到登录页面或其他页面
          //context.to(HomePage);
        }
      } else {
        // 重置动画
        final animatedState = _animatedButtonKey.currentState;
        if (animatedState != null) {
          (animatedState as dynamic).resetAnimation();
        }
        setState(() {
          _errorMessage = result['message'] ?? '注册失败';
        });
      }
    } catch (e) {
      // 重置动画
      final animatedState = _animatedButtonKey.currentState;
      if (animatedState != null) {
        (animatedState as dynamic).resetAnimation();
      }
      setState(() {
        _errorMessage = '注册过程中发生错误: $e';
      });
    }
  }

  Widget _registerText() {
    return const Text(
      'Register',
      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
      textAlign: TextAlign.center,
    );
  }

  Widget _fullNameField(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      transform: Matrix4.translationValues(0, _fullNameFieldOffset, 0),
      child: TextField(
        key: _fullNameFieldKey,
        controller: _fullNameController,
        focusNode: _fullNameFocusNode,
        decoration: const InputDecoration(
          hintText: 'Full Name',
          border: OutlineInputBorder(),
        ),
      ),
    );
  }

  Widget _phoneNumberField(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      transform: Matrix4.translationValues(0, _phoneNumberFieldOffset, 0),
      child: TextField(
        key: _phoneNumberFieldKey,
        controller: _phoneNumberController,
        focusNode: _phoneNumberFocusNode,
        keyboardType: TextInputType.phone,
        decoration: const InputDecoration(
          hintText: 'Phone Number',
          border: OutlineInputBorder(),
        ),
      ),
    );
  }

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
              onPressed: _passwordVisibility, // 点击切换密码可见性
            ),
          ),
        ),
      ),
    );
  }

  Widget _signText(BuildContext context) {
    return Padding(
      padding: EdgeInsetsGeometry.symmetric(vertical: 30),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Do you have an account?',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
          TextButton(
            onPressed: () => context.to(SigninPage),
            child: const Text(
              'Sign In',
              style: TextStyle(color: Color(0xff00a8e9)),
            ),
          ),
        ],
      ),
    );
  }

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          BasicAppBar(
            // 传入 logo
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
          // 背景修饰
          Align(
            alignment: Alignment.topRight,
            child: SvgPicture.asset(AppVectors.topPattern),
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: SvgPicture.asset(AppVectors.bottomPattern),
          ),
          Padding(
            padding: EdgeInsetsGeometry.only(top: 120, left: 30, right: 30),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    _registerText(),
                    const SizedBox(height: 15),
                    _helpText(context),
                    const SizedBox(height: 26),
                    _fullNameField(context),
                    const SizedBox(height: 16),
                    _phoneNumberField(context),
                    const SizedBox(height: 16),
                    _passwordField(context),
                    const SizedBox(height: 20),
                    if (_errorMessage != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 4,
                          horizontal: 16,
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.error_outline,
                              color: Colors.red[400],
                              size: 18,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                _errorMessage!,
                                style: const TextStyle(
                                  color: Colors.red,
                                  fontSize: 14,
                                ),
                                textAlign: TextAlign.start,
                                overflow: TextOverflow.visible,
                              ),
                            ),
                          ],
                        ),
                      ),
                    Disappear(
                      key: _animatedButtonKey,
                      loadingWidget: const CircularProgressIndicator(
                        color: AppColors.primary,
                        strokeWidth: 5,
                      ),
                      child: BasicAppButton(
                        onPressed: _handleSignup,
                        title: 'Create Account',
                        letterspacing: 1,
                        fontsize: 17,
                        width: 279 + 30,
                      ),
                    ),
                  ],
                ),
                _signText(context)
              ],
            ),
          ),
        ],
      ),
    );
  }
}
