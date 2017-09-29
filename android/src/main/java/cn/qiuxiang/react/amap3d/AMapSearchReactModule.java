package cn.qiuxiang.react.amap3d;

import com.amap.api.services.core.LatLonPoint;
import com.amap.api.services.geocoder.GeocodeResult;
import com.amap.api.services.geocoder.GeocodeSearch;
import com.amap.api.services.geocoder.RegeocodeAddress;
import com.amap.api.services.geocoder.RegeocodeQuery;
import com.amap.api.services.geocoder.RegeocodeResult;
import com.amap.api.services.geocoder.StreetNumber;
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
 * Created by linsht on 2017/9/29.
 */


public class AMapSearchReactModule extends ReactContextBaseJavaModule
        implements GeocodeSearch.OnGeocodeSearchListener,LifecycleEventListener {
    private static final String MODULE_NAME = "AMapSearch";
    private GeocodeSearch mGeocodeSearch;
    private GeocodeSearch.OnGeocodeSearchListener mGeocodeSearchListener = this;
    private String mEventDesc;
    private final ReactApplicationContext mReactContext;

    private void sendEvent(String eventName,
                           @Nullable WritableMap params) {
        if (mReactContext != null) {
            mReactContext
                    .getJSModule(DeviceEventManagerModule.RCTDeviceEventEmitter.class)
                    .emit(eventName, params);
        }
    }

    public AMapSearchReactModule(ReactApplicationContext reactContext) {
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
    public void reGeocodeSearch(@Nullable ReadableMap options, String eventDesc) {
        mEventDesc = eventDesc;
        mGeocodeSearch = new GeocodeSearch(mReactContext);
        mGeocodeSearch.setOnGeocodeSearchListener(mGeocodeSearchListener);
        mReactContext.addLifecycleEventListener(this);

        if (options != null) {
            if (options.hasKey("longitude") && options.hasKey("latitude")) {
                double longitude = options.getDouble("longitude");
                double latitude = options.getDouble("latitude");
                LatLonPoint latLonPoint = new LatLonPoint(latitude,longitude);
                RegeocodeQuery query = new RegeocodeQuery(latLonPoint, 100,GeocodeSearch.AMAP);
                mGeocodeSearch.getFromLocationAsyn(query);
            }
        }
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
    public void onRegeocodeSearched(RegeocodeResult regeocodeResult, int i) {
        WritableMap map = Arguments.createMap();
        if (i == 1000) {
            //success
            RegeocodeAddress mRegeocodeAddress = regeocodeResult.getRegeocodeAddress();
            map.putString("address",mRegeocodeAddress.getFormatAddress());
            map.putString("province",mRegeocodeAddress.getProvince());
            map.putString("city",mRegeocodeAddress.getCity());
            map.putString("district",mRegeocodeAddress.getDistrict());
            map.putString("cityCode",mRegeocodeAddress.getCityCode());
            map.putString("adCode",mRegeocodeAddress.getAdCode());
            map.putString("township",mRegeocodeAddress.getTownship());
            map.putString("neighborhood",mRegeocodeAddress.getNeighborhood());
            map.putString("building",mRegeocodeAddress.getBuilding());
            StreetNumber streetNumber = mRegeocodeAddress.getStreetNumber();
            map.putString("street",streetNumber.getStreet());
            map.putString("number",streetNumber.getNumber());
            map.putString("direction",streetNumber.getDirection());
            map.putDouble("distance",streetNumber.getDistance());
        } else {
            //failed
            map.putInt("errorCode", -1);
            map.putString("errorInfo", "逆地址编码失败");
        }
        sendEvent(mEventDesc, map);
    }

    @Override
    public void onGeocodeSearched(GeocodeResult geocodeResult, int i) {

    }
}
