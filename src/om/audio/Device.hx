package om.audio;

#if js

import js.html.MediaDeviceInfo;
import js.lib.Promise;

class Device {

    public static inline function list() : Promise<Array<MediaDeviceInfo>> {
        return js.Browser.navigator.mediaDevices.enumerateDevices();
    }
}

#end
