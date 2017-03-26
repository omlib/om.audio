package om.audio;

import js.Browser.window;
import js.Promise;
import js.html.ArrayBuffer;
import js.html.audio.AudioContext;
import js.html.audio.AudioBuffer;

class AudioBufferLoader {

	public static inline function decodeAudioData( ctx : AudioContext, buf : ArrayBuffer ) : Promise<AudioBuffer> {
		return ctx.decodeAudioData( buf );
	}

	public static function loadArrayBuffer( url : String ) : Promise<ArrayBuffer> {

		#if electron
		return new Promise( function(resolve,reject){
			js.node.Fs.readFile( url, function(e,buf){
				if( e != null )
					reject(e)
				else
					resolve( om.util.ArrayBufferUtil.buf2ab( buf ) );
			} );
		});

		#else
		return window.fetch( url ).then( function(res) {
			return res.arrayBuffer();
		});

		#end
	}

	public static function loadAudioBuffer( ctx : AudioContext, url : String ) : Promise<AudioBuffer> {
		return loadArrayBuffer( url ).then( function(buf:ArrayBuffer) {
			return ctx.decodeAudioData( buf );
		});
	}

	static function toArrayBuffer( buf : js.node.Buffer ) {
	    var ab = new ArrayBuffer(buf.length);
	    var view = new js.html.Uint8Array(ab);
		for( i in 0...buf.length ) {
	        view[i] = buf[i];
	    }
	    return ab;
	}
}
