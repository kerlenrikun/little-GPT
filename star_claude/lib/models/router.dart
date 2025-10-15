// ignore_for_file: unused_import

import 'package:flutter/material.dart';

class AppRouter {
  static String routeToName(Type type) => type.toString();

  //<T>是泛型参数， 有它在， 就可以在方法中传入和返回任意类型
  static Map<String, T> addRouteMap<T>(Map<Type, T> map) {
    final Map<String, T> target = <String, T>{};
    map.forEach((key, value) => target[routeToName(key)] = value);
    return target;
  }
}

// BuildContext的扩展方法，提供便捷的路由导航功能
extension Context on BuildContext {
  // 通过类型名称进行路由跳转的便捷方法
  //
  // 参数:
  //   router: 目标页面的类型（Type对象）
  //
  // 返回值:
  //   Future<T?>: 异步返回可能包含数据的Future对象
  //
  // 功能说明:
  //   1. 使用AppRouter.routeToName方法将Type转换为字符串路由名称
  //   2. 调用Navigator.pushNamed进行命名路由跳转
  //   3. 支持泛型T，可以接收从目标页面返回的数据
  //   4. 通过BuildContext扩展，可以在任何Widget中直接使用
  Future<T?> to <T extends Object?>(Type router) {
    return Navigator.pushNamed(this, AppRouter.routeToName(router));
  }
}
