'use strict';

var ReactNative = require('react-native');

var {
    NativeModules,
    DeviceEventEmitter
} = ReactNative;

const AMapLocation = NativeModules.AMapLocation;
const onLocationUpdatingEvent = 'onLocationUpdatingEvent';
let listener
module.exports = {
    startUpdatingLocation: (option, callback) => {
        const event = onLocationUpdatingEvent + Math.random().toString(36).substr(2)
        const handler = (body) => {
            callback && callback(body)
        }
        listener = DeviceEventEmitter.addListener(
            event,
            handler
        );
        AMapLocation.startUpdatingLocation(option, event)
    },
    stopUpdatingLocatoin: () => {
        listener && DeviceEventEmitter.removeListener(listener)
        AMapLocation.stopUpdatingLocatoin()
    },
    getCurrentLocation: (callback) => {
        const event = onLocationUpdatingEvent + Math.random().toString(36).substr(2)
        let listener1;
        const handler = (body) => {
            callback && callback(body)
            listener1 && DeviceEventEmitter.removeListener(listener1)
        }
        listener1 = DeviceEventEmitter.addListener(
            event,
            handler
        );
        AMapLocation.getCurrentLocation(event)
    }
};
