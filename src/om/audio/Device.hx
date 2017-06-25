package om.audio;

import js.Promise;

class Device {

    public static inline function get() : Promise<Dynamic> {
        return untyped navigator.mediaDevices.enumerateDevices();
    }
}
