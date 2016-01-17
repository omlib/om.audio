package om.audio;

import js.html.ArrayBuffer;
import js.html.XMLHttpRequest;
import js.html.audio.AudioContext;
import js.html.audio.AudioBuffer;

class AudioBufferLoader {

	public static function load( context : AudioContext, url : String, callback : String->AudioBuffer->Void ) {
		loadArrayBuffer( context, url, function(e,data){
			if( e != null ) callback( e, null ) else {
				context.decodeAudioData( data, function(buf) callback( null, buf ) );
			}
		});
	}

	public static function loadArrayBuffer( context : AudioContext, url : String, callback : String->ArrayBuffer->Void ) {
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
			callback( null, xhr.response );
		}
		xhr.send();
	}

}
