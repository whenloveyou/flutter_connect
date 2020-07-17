package com.flappygo.flutterflappyconnect;

import android.app.Activity;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;

import androidx.annotation.NonNull;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.Registrar;

/**
 * FlutterflappyconnectPlugin
 */
public class FlutterflappyconnectPlugin implements FlutterPlugin, MethodCallHandler, EventChannel.StreamHandler {
    /// The MethodChannel that will the communication between Flutter and native Android
    ///
    /// This local reference serves to register the plugin with the Flutter Engine and unregister it
    /// when the Flutter Engine is detached from the Activity
    private MethodChannel channel;

    private EventChannel eventChannel;

    //上下文activity
    private Context context;

    //监听
    private BroadcastReceiver broadcastReceiver;

    //用于所有回调
    private EventChannel.EventSink meventSink;

    @Override
    public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {

        context = flutterPluginBinding.getApplicationContext();
        addBroadCast(context);

        channel = new MethodChannel(flutterPluginBinding.getFlutterEngine().getDartExecutor(), "flutterflappyconnect");
        channel.setMethodCallHandler(this);

        eventChannel = new EventChannel(flutterPluginBinding.getBinaryMessenger(), "flutterflappyconnect_event");
        eventChannel.setStreamHandler(this);

    }


    // This static function is optional and equivalent to onAttachedToEngine. It supports the old
    // pre-Flutter-1.12 Android projects. You are encouraged to continue supporting
    // plugin registration via this function while apps migrate to use the new Android APIs
    // post-flutter-1.12 via https://flutter.dev/go/android-project-migration.
    //
    // It is encouraged to share logic between onAttachedToEngine and registerWith to keep
    // them functionally equivalent. Only one of onAttachedToEngine or registerWith will be called
    // depending on the user's project. onAttachedToEngine or registerWith must both be defined
    // in the same class.
    public static void registerWith(Registrar registrar) {
        final MethodChannel channel = new MethodChannel(registrar.messenger(), "flutterflappyconnect");

        FlutterflappyconnectPlugin plugin = new FlutterflappyconnectPlugin();
        plugin.context = registrar.activity().getApplicationContext();
        plugin.addBroadCast(registrar.activity().getApplicationContext());

        plugin.eventChannel = new EventChannel(registrar.messenger(), "flutterflappyconnect_event");
        plugin.eventChannel.setStreamHandler(plugin);

        channel.setMethodCallHandler(plugin);
    }

    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
        if (call.method.equals("getConnectionType")) {

            int state = IntenetUtil.getNetworkState(context);

            if (state == IntenetUtil.NETWORN_2G) {
                result.success("0");
            } else if (state == IntenetUtil.NETWORN_3G) {
                result.success("1");
            } else if (state == IntenetUtil.NETWORN_4G) {
                result.success("2");
            } else if (state == IntenetUtil.NETWORN_5G) {
                result.success("3");
            } else if (state == IntenetUtil.NETWORN_MOBILE || state == IntenetUtil.NETWORN_ETHERNET) {
                result.success("4");
            } else if (state == IntenetUtil.NETWORN_WIFI || state == IntenetUtil.UnCon_WIFI) {
                result.success("5");
            } else if (state == IntenetUtil.NETWORN_NONE) {
                result.success("6");
            } else {
                result.success("0");
            }
        } else {
            result.notImplemented();
        }
    }

    //添加
    private void addBroadCast(Context context) {
        if (broadcastReceiver == null) {
            broadcastReceiver = new BroadcastReceiver() {
                @Override
                public void onReceive(Context context, Intent intent) {
                    if (meventSink != null) {
                        meventSink.success("");
                    }
                }
            };
        }
        //增加监听
        IntentFilter intentFilter = new IntentFilter();
        intentFilter.addAction("android.net.conn.CONNECTIVITY_CHANGE");
        context.registerReceiver(broadcastReceiver, intentFilter);
    }


    //移除
    private void removeBroadCast(Context context) {
        if (broadcastReceiver != null && context != null) {
            context.unregisterReceiver(broadcastReceiver);
            broadcastReceiver = null;
        }
    }

    @Override
    public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
        removeBroadCast(context);
        channel.setMethodCallHandler(null);
        eventChannel.setStreamHandler(null);
    }

    @Override
    public void onListen(Object arguments, EventChannel.EventSink events) {
        meventSink = events;
    }

    @Override
    public void onCancel(Object arguments) {
        meventSink = null;
    }
}
