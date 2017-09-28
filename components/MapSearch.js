'use strict';

var ReactNative = require('react-native');

var {
    NativeModules,
    DeviceEventEmitter
} = ReactNative;

const AMapSearch = NativeModules.AMapSearch;
const onReGeocodeSearchEvent = 'onReGeocodeSearchEvent';

module.exports = {
    reGeocodeSearch: (option, callback) => {
        const event = onReGeocodeSearchEvent + Math.random().toString(36).substr(2)
        const handler = (body) => {
            callback && callback(body)
            listener && DeviceEventEmitter.removeListener(listener)
        }
        const listener = DeviceEventEmitter.addListener(
            event,
            handler
        );
        AMapSearch.reGeocodeSearch(option, event)
    }
};
