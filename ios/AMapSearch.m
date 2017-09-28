#import "AMapSearch.h"

#import <React/RCTLog.h>
#import <React/RCTUtils.h>
#import <React/RCTBridge.h>
#import <React/RCTEventDispatcher.h>

#import <AMapFoundationKit/AMapFoundationKit.h>
#import <AMapSearchKit/AMapSearchKit.h>


#pragma ide diagnostic ignored "OCUnusedClassInspection"


static NSString * const kErrorCodeKey = @"errorCode";
static NSString * const kErrorInfoKey = @"errorInfo";

@interface AMapSearch () <AMapSearchDelegate>

@property (nonatomic, strong) AMapSearchAPI         *locationSearch;

@property (nonatomic, strong) NSString *eventDesc;

@end

@implementation AMapSearch

@synthesize bridge = _bridge;

RCT_EXPORT_MODULE(AMapSearch);

#pragma mark - Lifecycle
- (void)dealloc {
    self.locationSearch = nil;
}

RCT_EXPORT_METHOD(reGeocodeSearch:(NSDictionary *)options eventDesc:(NSString *)eventDesc) {
    self.eventDesc = eventDesc;
    if(options &&
       [options isKindOfClass:[NSDictionary class]]) {
    
        id longitudeValue = options[@"longitude"];
        id latitudeValue = options[@"latitude"];
        CGFloat longitude = [longitudeValue doubleValue];
        CGFloat latitude = [latitudeValue doubleValue];
        AMapReGeocodeSearchRequest *regeo = [[AMapReGeocodeSearchRequest alloc] init];
        regeo.location = [AMapGeoPoint locationWithLatitude:latitude longitude:longitude];
        regeo.requireExtension = YES;
        regeo.radius = 100;
        [self.locationSearch AMapReGoecodeSearch:regeo];
    }
    
}


- (NSDictionary *)constantsToExport {
    return nil;
}

#pragma mark - Setter & Getter
- (AMapSearchAPI *)locationSearch {
    if (!_locationSearch) {
        _locationSearch = [[AMapSearchAPI alloc] init];
        _locationSearch.delegate = self;
    }
    return _locationSearch;
}


#pragma mark - AMapSearchDelegate
- (void)AMapSearchRequest:(id)request didFailWithError:(NSError *)error
{
    NSMutableDictionary *resultDic = [NSMutableDictionary dictionary];
    NSLog(@"Error: %@", error);
    if ([request isKindOfClass:[AMapReGeocodeSearchRequest class]]) {
        resultDic[kErrorCodeKey] = @(-1);
        resultDic[kErrorInfoKey] = @"reGeocodeSearch Failed";
        [self.bridge.eventDispatcher sendAppEventWithName:self.eventDesc body:resultDic];
    }

}
/* 逆地理编码回调. */
- (void)onReGeocodeSearchDone:(AMapReGeocodeSearchRequest *)request response:(AMapReGeocodeSearchResponse *)response
{
    NSMutableDictionary *resultDic = [NSMutableDictionary dictionary];
    AMapReGeocode *regeocode = response.regeocode;
    if (regeocode != nil)
    {
        //解析response获取地址描述
        resultDic[@"address"]   = regeocode.formattedAddress ? : [NSNull null];
        /*
        ///省/直辖市
        @property (nonatomic, copy)   NSString         *province;
        ///市
        @property (nonatomic, copy)   NSString         *city;
        ///城市编码
        @property (nonatomic, copy)   NSString         *citycode;
        ///区
        @property (nonatomic, copy)   NSString         *district;
        ///区域编码
        @property (nonatomic, copy)   NSString         *adcode;
        ///乡镇街道
        @property (nonatomic, copy)   NSString         *township;
        ///乡镇街道编码
        @property (nonatomic, copy)   NSString         *towncode;
        ///社区
        @property (nonatomic, copy)   NSString         *neighborhood;
        ///建筑
        @property (nonatomic, copy)   NSString         *building;
         */
        AMapAddressComponent *addressComponent = regeocode.addressComponent;
        if (addressComponent) {
            resultDic[@"province"]  = addressComponent.province ? : [NSNull null];
            resultDic[@"city"]      = addressComponent.city ? : [NSNull null];
            resultDic[@"district"]  = addressComponent.district ? : [NSNull null];
            resultDic[@"cityCode"]  = addressComponent.citycode ? : [NSNull null];
            resultDic[@"adCode"]    = addressComponent.adcode ? : [NSNull null];
            resultDic[@"township"]    = addressComponent.township ? : [NSNull null];
            resultDic[@"towncode"]    = addressComponent.towncode ? : [NSNull null];
            resultDic[@"neighborhood"]   = addressComponent.neighborhood ? : [NSNull null];
            resultDic[@"building"]   = addressComponent.building ? : [NSNull null];
        }
    }
    [self.bridge.eventDispatcher sendAppEventWithName:self.eventDesc body:resultDic];
}
@end
