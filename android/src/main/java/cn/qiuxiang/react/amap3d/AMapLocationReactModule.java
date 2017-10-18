package cn.qiuxiang.react.amap3d;

import android.util.Log;

import com.amap.api.location.AMapLocation;
import com.amap.api.location.AMapLocationClient;
import com.amap.api.location.AMapLocationClientOption;
import com.amap.api.location.AMapLocationListener;
import com.facebook.react.bridge.Arguments;
import com.facebook.react.bridge.LifecycleEventListener;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.ReadableMap;
import com.facebook.react.bridge.WritableMap;
import com.facebook.react.modules.core.DeviceEventManagerModule;

import java.util.HashMap;
import java.util.Map;

import javax.annotation.Nullable;

/**
 * Created by linsht on 2017/10/18.
 */


public class AMapLocationReactModule extends ReactContextBaseJavaModule
        implements AMapLocationListener,LifecycleEventListener {
    private static final String MODULE_NAME = "AMapLocation";

    private AMapLocationClient mLocationClient = null;
//    private AMapLocationClient mLocationClient1 = null;
    private AMapLocationListener mLocationListener = this;
    private String mEventDesc = null;
//    private String mEventDesc1 = null;
    private final ReactApplicationContext mReactContext;

    private void sendEvent(String eventName,
                           @Nullable WritableMap params) {
        if (mReactContext != null) {
            mReactContext
                    .getJSModule(DeviceEventManagerModule.RCTDeviceEventEmitter.class)
                    .emit(eventName, params);
        }
    }

    public AMapLocationReactModule(ReactApplicationContext reactContext) {
        super(reactContext);
        this.mReactContext = reactContext;
    }

    @Override
    public String getName() {
        return MODULE_NAME;
    }

    @Override
    public Map<String, Object> getConstants() {
        final Map<String, Object> constants = new HashMap<>();
        return constants;
    }

    @ReactMethod
    public void startUpdatingLocation(@Nullable ReadableMap options, String eventDesc) {
        mEventDesc = eventDesc;
        long minTime = 5*60*1000;

        //初始化定位
        mLocationClient = new AMapLocationClient(mReactContext);
        //设置定位回调监听
        mLocationClient.setLocationListener(mLocationListener);
        mReactContext.addLifecycleEventListener(this);

        if (options != null) {
            if (options.hasKey("minTime")) {
                minTime = (long) options.getInt("minTime");
            }
        }
        Log.d(this.getName(),"minTime=" + minTime);
        //初始化AMapLocationClientOption对象
        AMapLocationClientOption mLocationOption = new AMapLocationClientOption();
        //设置定位模式为AMapLocationMode.Hight_Accuracy，高精度模式。
        mLocationOption.setLocationMode(AMapLocationClientOption.AMapLocationMode.Hight_Accuracy);
        //设置定位模式为AMapLocationMode.Battery_Saving，低功耗模式。
//        mLocationOption.setLocationMode(AMapLocationClientOption.AMapLocationMode.Battery_Saving);
        //获取一次定位结果：
        //该方法默认为false。
        //mLocationOption.setOnceLocation(false);
        //获取最近3s内精度最高的一次定位结果：
        //设置setOnceLocationLatest(boolean b)接口为true，启动定位时SDK会返回最近3s内精度最高的一次定位结果。如果设置其为true，setOnceLocation(boolean b)接口也会被设置为true，反之不会，默认为false。
        //mLocationOption.setOnceLocationLatest(false);
        //设置定位间隔,单位毫秒,默认为2000ms，最低1000ms。
        mLocationOption.setInterval(minTime);
        //给定位客户端对象设置定位参数
        mLocationClient.setLocationOption(mLocationOption);
        //启动定位
        mLocationClient.startLocation();
    }

    @ReactMethod
    public void stopUpdatingLocation() {
        if (null != mLocationClient) {
            mLocationClient.stopLocation();//停止定位后，本地定位服务并不会被销毁
            mLocationClient.onDestroy();//销毁定位客户端，同时销毁本地定位服务
            mLocationClient = null;
            mEventDesc = null;
        }
    }

    @ReactMethod
    public void getCurrentLocation(String eventDesc) {
        final String event = eventDesc;

        //初始化定位
        final AMapLocationClient locationClient = new AMapLocationClient(mReactContext);
        //设置定位回调监听
        locationClient.setLocationListener(new AMapLocationListener() {
            @Override
            public void onLocationChanged(AMapLocation aMapLocation) {
                WritableMap map = getMap(aMapLocation);
                if (null != event) {
                    sendEvent(event, map);
                    if (null != locationClient) {
                        locationClient.stopLocation();
                        locationClient.onDestroy();
                    }
                }
            }
        });
        mReactContext.addLifecycleEventListener(this);

        //初始化AMapLocationClientOption对象
        AMapLocationClientOption mLocationOption = new AMapLocationClientOption();
        //设置定位模式为AMapLocationMode.Hight_Accuracy，高精度模式。
        mLocationOption.setLocationMode(AMapLocationClientOption.AMapLocationMode.Hight_Accuracy);
        //设置定位模式为AMapLocationMode.Battery_Saving，低功耗模式。
//        mLocationOption.setLocationMode(AMapLocationClientOption.AMapLocationMode.Battery_Saving);
        //获取一次定位结果：
        //该方法默认为false。
        mLocationOption.setOnceLocation(true);
        //获取最近3s内精度最高的一次定位结果：
        //设置setOnceLocationLatest(boolean b)接口为true，启动定位时SDK会返回最近3s内精度最高的一次定位结果。如果设置其为true，setOnceLocation(boolean b)接口也会被设置为true，反之不会，默认为false。
//        mLocationOption.setOnceLocationLatest(true);
        //给定位客户端对象设置定位参数
        locationClient.setLocationOption(mLocationOption);
        //启动定位
        locationClient.startLocation();
    }

    @Override
    public void onHostResume() {

    }

    @Override
    public void onHostPause() {

    }

    @Override
    public void onHostDestroy() {

    }


    @Override
    public void onLocationChanged(AMapLocation aMapLocation) {
        WritableMap map = this.getMap(aMapLocation);
        if (null != mEventDesc) {
            sendEvent(mEventDesc, map);
        }
    }

    public WritableMap getMap(AMapLocation aMapLocation) {
        WritableMap map = Arguments.createMap();
        if (aMapLocation != null) {
            if (aMapLocation.getErrorCode() == 0) {
                //可在其中解析amapLocation获取相应内容。
                map.putDouble("longitude",aMapLocation.getLongitude());
                map.putDouble("latitude",aMapLocation.getLatitude());
                map.putDouble("accuracy",aMapLocation.getAccuracy());
                map.putInt("locationType",aMapLocation.getLocationType());
                Log.d(this.getName(),"latitude:"+aMapLocation.getLatitude()+"longitude:"+aMapLocation.getLongitude());
            }else {
                //定位失败时，可通过ErrCode（错误码）信息来确定失败的原因，errInfo是错误信息，详见错误码表。
                Log.e("AmapError","location Error, ErrCode:"
                        + aMapLocation.getErrorCode() + ", errInfo:"
                        + aMapLocation.getErrorInfo());
                //failed
                map.putInt("errorCode", -1);
                map.putString("errorInfo", "获取位置失败");
            }
        }
        return map;
    }
}
