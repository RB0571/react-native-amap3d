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

@end
