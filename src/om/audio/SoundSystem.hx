package om.audio;

import js.Error;
import js.html.ArrayBuffer;
import js.html.XMLHttpRequest;
import js.html.audio.AudioNode;
import js.html.audio.AudioContext;
import js.html.audio.AudioBuffer;
import js.html.audio.AudioBufferSourceNode;
import js.html.audio.GainNode;
import js.html.audio.DynamicsCompressorNode;

/**
*/
class SoundSystem {

	public var context(default,null) : AudioContext;
	public var master(default,null) : AudioNode;
	public var volume(get,set) : Float;
	public var muted(default,null) : Bool;

	var gain : GainNode;

    public function new() {
        context = new AudioContext();
		muted = false;
		init();
    }

	inline function get_volume() : Float return gain.gain.value;
	inline function set_volume(v:Float) : Float return gain.gain.value = v;

	function init() {

        gain = context.createGain();
        gain.gain.value = volume;
		gain.connect( context.destination, null, null );

        master = gain;
	}

	public function load( url : String, callback : Error->AudioBuffer->Void ) {
		AudioBufferLoader.load( context, url, callback );
	}

}
