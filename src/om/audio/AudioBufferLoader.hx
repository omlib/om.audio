package om.audio;

import js.Browser.window;
import js.Promise;
import js.html.ArrayBuffer;
import js.html.audio.AudioContext;
import js.html.audio.AudioBuffer;

class AudioBufferLoader {

	public static inline function decodeAudioData( context : AudioContext, buf : ArrayBuffer ) : Promise<AudioBuffer> {
		return context.decodeAudioData( buf );
	}

	public static function loadArrayBuffer( url : String ) : Promise<ArrayBuffer> {
		return window.fetch( url ).then( function(res) {
			return res.arrayBuffer();
		});
	}

	public static function loadAudioBuffer( context : AudioContext, url : String ) : Promise<AudioBuffer> {
		return loadArrayBuffer( url ).then( function(buf:ArrayBuffer) {
			return context.decodeAudioData( buf );
		});
	}
}
