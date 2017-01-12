package om.audio;

import js.Browser.window;
import js.html.Float32Array;
import js.html.audio.AudioBuffer;
import js.html.audio.AudioContext;
import js.html.audio.ScriptProcessorNode;

class VolumeMeter {

	/***/
	public var processor(default,null) : ScriptProcessorNode;

	/***/
	public var rms(default,null) : Float;

	/***/
	public var volume(default,null) : Float;

	/***/
	public var decibel(default,null) : Float;

	/** The level (0 to 1) considered "clipping". */
	public var clipLevel : Float;

	/** */
	public var averaging : Float;

	/** How long you would like the "clipping" indicator to show after clipping has occured, in milliseconds.  Defaults to 750ms. */
	public var clipLag : Int;

	public function new( audio : AudioContext, bufferSize = 512,
						 clipLevel = 0.98, averaging = 0.95, clipLag = 750 ) {

		this.clipLevel = clipLevel;
		this.averaging = averaging;
		this.clipLag = clipLag;

		var clipping = false;
		var lastClip = 0.0;

		processor = audio.createScriptProcessor( bufferSize );

		//TODO
		untyped processor.checkClipping = function(){
			if( !clipping )
				return false;
			if( (lastClip + clipLag) < window.performance.now() )
				clipping = false;
			return clipping;
		};

		var buf : AudioBuffer;
		var sum = 0.0;
		var x : Float;

		processor.onaudioprocess = function(e){
			buf = e.inputBuffer.getChannelData(0);
			sum = 0.0;
			for( i in 0...buf.length ) {
				untyped x = buf[i];
				if( Math.abs( x ) >= clipLevel ) {
					clipping = true;
					lastClip = window.performance.now();
				}
				sum += x * x;
			}
			rms = Math.sqrt( sum / buf.length );
			volume = Math.max( rms, volume * averaging );
			decibel = Decibel.calculate( volume );
		};

        processor.connect( audio.destination );
	}

}
