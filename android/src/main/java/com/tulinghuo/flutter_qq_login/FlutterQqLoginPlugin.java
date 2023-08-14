package com.tulinghuo.flutter_qq_login;

import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.os.Build;
import android.util.Log;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.tencent.connect.common.Constants;
import com.tencent.tauth.IUiListener;
import com.tencent.tauth.Tencent;
import com.tencent.tauth.UiError;

import org.json.JSONObject;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry;

/**
 * FlutterQqLoginPlugin
 */
public class FlutterQqLoginPlugin implements FlutterPlugin, MethodCallHandler,
        ActivityAware,
        PluginRegistry.ActivityResultListener,
        IUiListener {
    /// The MethodChannel that will the communication between Flutter and native Android
    ///
    /// This local reference serves to register the plugin with the Flutter Engine and unregister it
    /// when the Flutter Engine is detached from the Activity
    private MethodChannel channel;
    private Activity activity;
    private Context context;

    private Tencent tencent;
    private String appId;
    private Result loginResult;

    @Override
    public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
        channel = new MethodChannel(flutterPluginBinding.getBinaryMessenger(), "flutter_qq_login");
        channel.setMethodCallHandler(this);
        context = flutterPluginBinding.getApplicationContext();
    }

    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
        if (call.method.equals("init")) {
            this.appId = call.argument("appId");
            Log.i("flutter_qq_login", "call init -> appId= " + appId);
            Tencent.setIsPermissionGranted(true, Build.MODEL);
            tencent = Tencent.createInstance(appId, context);
            result.success(null);
        } else if (call.method.equals("isInstalled")) {
            Tencent.resetTargetAppInfoCache();
            boolean isInstalled = tencent.isQQInstalled(context);
            result.success(isInstalled);
        } else if (call.method.equals("login")) {
            boolean isSessionValid = tencent.isSessionValid();
            Log.i("flutter_qq_login", "isSessionValid -> " + isSessionValid);
            if (!isSessionValid) {
                Log.i("flutter_qq_login", "activity -> " + activity);
                tencent.login(activity, "all", this);
            }
            this.loginResult = result;
        } else if (call.method.equals("getUserInfo")) {
            new Thread() {
                @Override
                public void run() {
                    try {
                        String accessToken = call.argument("accessToken");
                        String openid = call.argument("openid");
                        String api = "https://graph.qq.com/user/get_user_info?access_token=%s&oauth_consumer_key=%s&openid=%s";
                        api = String.format(api, accessToken, appId, openid);
                        JSONObject json = tencent.request(api, null, Constants.HTTP_GET);
                        Log.i("flutter_qq_login", "get_user_info -> " + json.toString());
                        result.success(json.toString());
                    } catch (Exception e) {
                        Log.i("flutter_qq_login", e.getMessage(), e);
                    }
                }
            }.start();
        } else {
            result.notImplemented();
        }
    }

    @Override
    public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
        channel.setMethodCallHandler(null);
        loginResult = null;
    }

    @Override
    public void onAttachedToActivity(@NonNull ActivityPluginBinding binding) {
        this.activity = binding.getActivity();
        binding.addActivityResultListener(this);
    }

    @Override
    public void onDetachedFromActivityForConfigChanges() {

    }

    @Override
    public void onReattachedToActivityForConfigChanges(@NonNull ActivityPluginBinding binding) {

    }

    @Override
    public void onDetachedFromActivity() {

    }

    @Override
    public void onComplete(Object o) {
        JSONObject jsonObject = (JSONObject) o;
        Log.i("flutter_qq_login", "onComplete -> " + jsonObject.toString());
        if (this.loginResult != null) {
            this.loginResult.success(jsonObject.toString());
            this.loginResult = null;
        }
    }

    @Override
    public void onError(UiError uiError) {
        Log.e("flutter_qq_login", "onError -> errorCode=" + uiError.errorCode + " errorMessage=" + uiError.errorMessage + " errorDetail=" + uiError.errorDetail);
    }

    @Override
    public void onCancel() {
        Log.i("flutter_qq_login", "onCancel");
    }

    @Override
    public void onWarning(int i) {
        Log.w("flutter_qq_login", "onWarning-> " + i);
    }

    @Override
    public boolean onActivityResult(int requestCode, int resultCode, @Nullable Intent data) {
        Tencent.onActivityResultData(requestCode, resultCode, data, this);
        return true;
    }
}
