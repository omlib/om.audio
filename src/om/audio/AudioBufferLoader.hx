package om.audio;

import js.html.XMLHttpRequest;
import js.html.audio.AudioContext;
import js.html.audio.AudioBuffer;

class AudioBufferLoader {

	public static function load( context : AudioContext, url : String, callback : String->AudioBuffer->Void ) {
		var xhr = new XMLHttpRequest();
		xhr.open( "GET", url, true );
		xhr.responseType = ARRAYBUFFER;
		xhr.onerror = function(e){
			callback( e, null );
			return;
		}
		xhr.onreadystatechange = function(e){
			if( xhr.status != 200 ) {
				callback( url, null );
				return;
			}
		}
		xhr.onload = function(e){
			context.decodeAudioData( xhr.response, function(buf){
				callback( null, buf );
			});
		}
		xhr.send();
	}

}
