package om.audio;

import js.html.audio.AudioBuffer;
import js.html.audio.AudioContext;
import js.html.audio.AudioNode;
import js.html.audio.AudioBufferSourceNode;
import js.html.audio.DynamicsCompressorNode;
import js.html.audio.GainNode;
import om.Time;

/**
	Basic sound effect
*/
class SoundEffect {

	public dynamic function onEnd() {}

	public var buffer(default,null) : AudioBuffer;
	public var isPlaying(default,null) = false;
	public var volume(default,set) : Float;
	public var startTime(default,null) : Float;
	public var paused(default,null) = false;

	var ctx : AudioContext;
	var out : AudioNode;
	var gain : GainNode;
	var source : AudioBufferSourceNode;
	var pauseOffset = 0.0;

	public function new( ctx : AudioContext, out : AudioNode, buf : AudioBuffer, volume = 1.0 ) {
		this.ctx = ctx;
		this.out = out;
		this.buffer = buffer;
		this.volume = volume;
	}

	function set_volume(v:Float) : Float {
		if( gain != null ) gain.gain.value = v;
		return volume = v;
	}

	public function play( when = 0.0 ) {

		if( isPlaying ) {
			return;
			//source.stop(0);
		}

		gain = ctx.createGain();
		gain.gain.value = volume;
		gain.connect( out, null, null );

		source = ctx.createBufferSource();
		source.buffer = buffer;
		source.connect( gain, null, null );
		source.onended = handleEnd;

		isPlaying = true;
		startTime = Time.now();

		//trace('play '+pauseOffset );
		source.start( when, pauseOffset );
	}

	public function pause() {
		if( isPlaying && !paused ) {
			paused = true;
			source.stop(0);
			pauseOffset += (Time.now()-startTime)/1000;
			//isPlaying = false;
		}
	}

	public function resume() {
		if( paused ) {
			paused = false;
			play();
		}
	}

	function handleEnd(e) {
		isPlaying = false;
		if( !paused ) {
			pauseOffset = 0;
		}
		//paused = false;
		onEnd();
	}
}
