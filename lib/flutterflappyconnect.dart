import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

enum ConnectionType {
  //2G网络
  TYPE_2G,
  //3G网络
  TYPE_3G,
  //4G网络
  TYPE_4G,
  //5G网络
  TYPE_5G,
  //手机
  TYPE_MOBILE,
  //WIFI
  TYPE_WIFI,
  //没有
  TYPE_NONE
}

//连接
class Flutterflappyconnect {
  //渠道
  static const MethodChannel _channel =
      const MethodChannel('flutterflappyconnect');

  //用于接收回调新的的channel
  static const EventChannel _eventChannel =
      EventChannel('flutterflappyconnect_event');

  //监听
  static List<VoidCallback> _networkChangedListeners = new List<VoidCallback>();

  //是否处于监听状态
  static bool _isListen = false;

  //获取当前的连接类型
  static Future<ConnectionType> getConnectionType() async {
    final String version = await _channel.invokeMethod('getConnectionType');
    if (version == "0") {
      return ConnectionType.TYPE_2G;
    }
    if (version == "1") {
      return ConnectionType.TYPE_3G;
    }
    if (version == "2") {
      return ConnectionType.TYPE_4G;
    }
    if (version == "3") {
      return ConnectionType.TYPE_5G;
    }
    if (version == "4") {
      return ConnectionType.TYPE_MOBILE;
    }
    if (version == "5") {
      return ConnectionType.TYPE_WIFI;
    }
    if (version == "6") {
      return ConnectionType.TYPE_NONE;
    }
    return ConnectionType.TYPE_NONE;
  }

  //新增监听
  static void addNetworkChangeListener(VoidCallback callback) {
    if (!_networkChangedListeners.contains(callback)) {
      _networkChangedListeners.add(callback);
    }
    //没有开启监听就开启监听
    if (!_isListen) {
      _isListen = true;
      //注册用于和原生代码的持续回调
      Stream<String> stream = _eventChannel
          .receiveBroadcastStream()
          .map((result) => result as String);
      //数据
      stream.listen((data) {
        //数据
        for (int s = 0; s < _networkChangedListeners.length; s++) {
          _networkChangedListeners[s]();
        }
      });
    }
  }

  //移除监听
  static void removeNetworkChangeListener(VoidCallback callback) {
    if (_networkChangedListeners.contains(callback)) {
      _networkChangedListeners.remove(callback);
    }
  }

  //移除所有监听
  static void clearNetworkChangeListener(VoidCallback callback) {
    _networkChangedListeners.clear();
  }
}
