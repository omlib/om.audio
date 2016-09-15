package om.audio;

import js.Browser.window;
import js.html.Float32Array;
import js.html.audio.AudioBuffer;
import js.html.audio.AudioContext;
import js.html.audio.ScriptProcessorNode;

class VolumeMeter {

	public var processor(default,null) : ScriptProcessorNode;
	public var rms(default,null) : Float;
	public var vol(default,null) : Float;
	public var dec(default,null) : Float;

	public var clipLevel : Float;
	public var averaging : Float;
	public var clipLag : Int;

	public function new( audio : AudioContext, bufferSize = 512,
						 clipLevel = 0.98, averaging = 0.95, clipLag = 750 ) {

		this.clipLevel = clipLevel;
		this.averaging = averaging;
		this.clipLag = clipLag;

		var clipping = false;
		var lastClip = 0.0;

		processor = audio.createScriptProcessor( bufferSize );
		processor.onaudioprocess = function(e){
			var buf = e.inputBuffer.getChannelData(0);
			var sum = 0.0;
			var x : Float;
			for( i in 0...buf.length ) {
				untyped x = buf[i];
				if( Math.abs(x) >= clipLevel ) {
					clipping = true;
					lastClip = window.performance.now();
				}
				sum += x * x;
			}
			rms = Math.sqrt( sum / buf.length );
			vol = Math.max( rms, vol * averaging );

			dec = 10 * log10( vol );
		};

		/*
		//TODO
		untyped processor.checkClipping = function(){
			if( !clipping )
				return false;
			if( (lastClip + clipLag) < window.performance.now())
				clipping = false;
			return clipping;
		};
		*/

        processor.connect( audio.destination );
	}

	static function log10( v : Float ) : Float{
    	return Math.log(v) / Math.LN10;
	}

}
