package om.audio;

#if js

import js.Promise;
import js.html.MediaStream;

class Microphone {

    public static inline function get() : Promise<MediaStream> {
        return untyped navigator.mediaDevices.getUserMedia( { audio: true } );
    }

}

#end
