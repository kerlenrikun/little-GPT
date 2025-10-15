// ignore_for_file: unused_import, unused_field, prefer_final_fields

import 'package:flutter/material.dart';
import 'package:star_claude/models/shop.dart';

class Cart extends ChangeNotifier{
  //待售商品列表
  List<Shop> _shopList = [
    Shop(
      name: 'NIKE板鞋',
      imagePath: 'assets/images/shoe.jpg',
      price: '234',
      description: '白色板鞋，质感享受',
    ),
    Shop(
      name: '红魔-10 Air',
      imagePath: 'assets/images/phone.webp',
      price: '592',
      description: '红魔史上最薄全面屏\n疾影黑 / 霜刃白 ',
    ),
    Shop(
      name: 'nubi红魔6',
      imagePath: 'assets/images/nubi_phone_6.webp',
      price: '573',
      description: '多维散热,17 分钟充满\n红蓝水晶 / 黑曜石 ',
    ),
  ];

  //购物车商品列表
  List<Shop> _cartList = [];
  
  //获取待售商品列表
  List<Shop> get getShopList => _shopList;

  //获取购物车商品列表
  List<Shop> get getCartList => _cartList;

  //👉添加商品到购物车
  void addItemToCart(Shop shop){
    _cartList.add(shop);
    notifyListeners();
  }

  //👉从购物车移除商品
  void removeItemFromCart(Shop shop){
    _cartList.remove(shop);
    notifyListeners();
  }

  //👉清空购物车
  void clearCart(){
    _cartList.clear();
    notifyListeners();
  }
}

