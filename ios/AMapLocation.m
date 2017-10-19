#import "AMapLocation.h"

#import <React/RCTLog.h>
#import <React/RCTUtils.h>
#import <React/RCTBridge.h>
#import <React/RCTEventDispatcher.h>

#import <AMapFoundationKit/AMapFoundationKit.h>
#import <AMapLocationKit/AMapLocationKit.h>

#pragma ide diagnostic ignored "OCUnusedClassInspection"


static NSString * const kErrorCodeKey = @"errorCode";
static NSString * const kErrorInfoKey = @"errorInfo";

@interface AMapLocation () <AMapLocationManagerDelegate>

@property (nonatomic, strong) AMapLocationManager         *locationManager;
@property (nonatomic, strong) AMapLocationManager   *locationManager1;

@property (nonatomic, strong) NSString *eventDesc;

@end

@implementation AMapLocation

@synthesize bridge = _bridge;

RCT_EXPORT_MODULE(AMapLocation);

#pragma mark - Lifecycle
- (void)dealloc {
    self.locationManager = nil;
}

RCT_EXPORT_METHOD(startUpdatingLocation:(NSDictionary *)options eventDesc:(NSString *)eventDesc) {
    if(options && [options isKindOfClass:[NSDictionary class]]) {
        id distanceFilterValue = options[@"distanceFilter"];
        CGFloat distanceFilter = [distanceFilterValue doubleValue];
        if (distanceFilterValue) {
            self.locationManager.distanceFilter = distanceFilter;
        }
    }
    self.eventDesc = eventDesc;
    [self.locationManager startUpdatingLocation];
}

RCT_EXPORT_METHOD(stopUpdatingLocatoin) {
    [self.locationManager stopUpdatingLocation];
}

- (NSDictionary *)constantsToExport {
    return nil;
}

#pragma mark - Setter & Getter
- (AMapLocationManager *)locationManager {
    if (!_locationManager) {
        _locationManager = [[AMapLocationManager alloc] init];
        _locationManager.delegate = self;
        [_locationManager setDistanceFilter:100];
    }
    return _locationManager;
}

#pragma mark - AMapLocationManagerDelegate
- (void)amapLocationManager:(AMapLocationManager *)manager didUpdateLocation:(CLLocation *)location
{
    NSLog(@"location:{lat:%f; lon:%f; accuracy:%f}", location.coordinate.latitude, location.coordinate.longitude, location.horizontalAccuracy);
    NSMutableDictionary *resultDic = [NSMutableDictionary dictionary];
    resultDic[@"latitude"] = @(location.coordinate.latitude);
    resultDic[@"longitude"] = @(location.coordinate.longitude);
    resultDic[@"horizontalAccuracy"] = @(location.horizontalAccuracy);
    resultDic[@"verticalAccuracy"] = @(location.verticalAccuracy);
    [self.bridge.eventDispatcher sendAppEventWithName:self.eventDesc body:resultDic];
}

#pragma mark - Location once
RCT_EXPORT_METHOD(getCurrentLocation:(NSString *)eventDesc) {
    self.locationManager1 = [[AMapLocationManager alloc] init];
    // 带逆地理信息的一次定位（返回坐标和地址信息）
    [self.locationManager1 setDesiredAccuracy:kCLLocationAccuracyHundredMeters];
    //   定位超时时间，最低2s，此处设置为2s
    self.locationManager1.locationTimeout = 2;
    //   逆地理请求超时时间，最低2s，此处设置为2s
    self.locationManager1.reGeocodeTimeout = 2;
    [self.locationManager1 requestLocationWithReGeocode:YES completionBlock:^(CLLocation *location, AMapLocationReGeocode *regeocode, NSError *error) {
        NSMutableDictionary *resultDic = [NSMutableDictionary dictionary];
        if (error)
        {
            NSLog(@"locError:{%ld - %@};", (long)error.code, error.localizedDescription);
//            if (error.code == AMapLocationErrorLocateFailed)
            {
                //failed
                resultDic[@"errorCode"] = @(-1);
                resultDic[@"errorInfo"] = @"获取位置失败";
            }
        } else {
            NSLog(@"location:%@", location);
            resultDic[@"latitude"] = @(location.coordinate.latitude);
            resultDic[@"longitude"] = @(location.coordinate.longitude);
            resultDic[@"horizontalAccuracy"] = @(location.horizontalAccuracy);
            resultDic[@"verticalAccuracy"] = @(location.verticalAccuracy);
        }
        if (regeocode) {
            //解析regeocode获取地址描述
            resultDic[@"address"]   = regeocode.formattedAddress ? : [NSNull null];
            resultDic[@"province"]  = regeocode.province ? : [NSNull null];
            resultDic[@"city"]      = regeocode.city ? : [NSNull null];
            resultDic[@"district"]  = regeocode.district ? : [NSNull null];
            resultDic[@"cityCode"]  = regeocode.citycode ? : [NSNull null];
            resultDic[@"adCode"]    = regeocode.adcode ? : [NSNull null];
            resultDic[@"street"]    = regeocode.street ? : [NSNull null];
            resultDic[@"number"]    = regeocode.number ? : [NSNull null];
        }
        [self.bridge.eventDispatcher sendAppEventWithName:eventDesc body:resultDic];
    }];
}

@end
