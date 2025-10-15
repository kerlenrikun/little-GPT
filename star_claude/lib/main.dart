import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'models/__init__.dart';
import 'domain/__init__.dart';
import 'core/configs/theme/__init__.dart';
import 'presentation/page__init__.dart';

void main() {
  // 确保Flutter绑定已初始化
  // 这是使用任何平台通道（如shared_preferences）的必要步骤
  WidgetsFlutterBinding.ensureInitialized();
  
  runApp(const MyApp());
}
class MyApp extends StatelessWidget {
  const MyApp({super.key});
  
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider(create: (context) => UserRepository()),
        ChangeNotifierProvider(create: (context) => DateProvider()),
        ChangeNotifierProvider(create: (context) => UserProvider()),
        ChangeNotifierProvider(create: (context) => SuccDataProvider()),
        ChangeNotifierProvider(create: (context) => CommonDataProvider()),
        ChangeNotifierProvider(create: (context) => AccountDataProvider()),
      ],
      child: MaterialApp(
        theme: AppTheme.darkTheme,
        darkTheme: AppTheme.darkTheme,
      debugShowCheckedModeBanner: false,
      home: const SplashPage(),
      routes: {
        ...AppRouter.addRouteMap({
          HomePage: (context) => HomePage(),
          GetStartedPage:(context) => GetStartedPage(),
          ChooseIdPage:(context) => ChooseIdPage(),
          SignupOrSigninPage:(context) => SignupOrSigninPage(),
          RegisterPage:(context)=>RegisterPage(),
          SigninPage:(context)=>SigninPage(),
          ProfilePage:(context)=>ProfilePage(),
          DatasetPage:(context)=>DatasetPage(),
          AccountPage:(context)=>AccountPage(),
          TestPage:(context)=>TestPage(),
          SortPage:(context)=>SortPage(),
        }),
      },
    ),
    );
  }
}

///登录过程中发生错误: type 'Null' is not a subtype of type 'String' of 'function result'
///实体类可能有null值，需要在使用前进行判断
