package om.audio.generator;

import js.html.Float32Array;
import js.html.audio.AudioBufferSourceNode;
import js.html.audio.AudioContext;
import js.html.audio.AudioNode;
import js.html.audio.ScriptProcessorNode;

class Noise {

	/**
		Random signal with a constant power spectral density.
	*/
	public static function generateWhiteNoise( buf : Float32Array, size = 4096 ) {
		for( i in 0...size )
			buf[i] = Math.random() * 2 - 1;

	}

	/**
		Signal with a frequency spectrum such that the power spectral density (energy or power per Hz) is inversely proportional to the frequency of the signal.
		In pink noise, each octave (halving/doubling in frequency) carries an equal amount of noise power.
	*/
	public static function generatePinkNoise( buf : Float32Array, size = 4096 ) {
		var b0, b1, b2, b3, b4, b5, b6;
		b0 = b1 = b2 = b3 = b4 = b5 = b6 = 0.0;
		for( i in 0...size ) {
			var white = Math.random() * 2 - 1;
			b0 = 0.99886 * b0 + white * 0.0555179;
			b1 = 0.99332 * b1 + white * 0.0750759;
			b2 = 0.96900 * b2 + white * 0.1538520;
			b3 = 0.86650 * b3 + white * 0.3104856;
			b4 = 0.55000 * b4 + white * 0.5329522;
			b5 = -0.7616 * b5 - white * 0.0168980;
			buf[i] = b0 + b1 + b2 + b3 + b4 + b5 + b6 + white * 0.5362;
			buf[i] *= 0.11;
			b6 = white * 0.115926;
		}
	}

	/**
		Signal noise produced by Brownian motion (hence its alternative name of random walk noise).
	*/
	public static function generateBrownNoise( buf : Float32Array, size = 4096 ) {
		var last = 0.0;
		for( i in 0...size ) {
			var white = Math.random() * 2 - 1;
			buf[i] = (last + (0.02 * white)) / 1.02;
			last = buf[i];
			buf[i] *= 3.5;
		}
	}

	public static inline function createWhiteNoiseNode( audio : AudioContext, ?size : Int ) : ScriptProcessorNode
		return createNode( audio, size, generateWhiteNoise );

	public static inline function createPinkNoiseNode( audio : AudioContext, ?size : Int ) : ScriptProcessorNode
		return createNode( audio, size, generatePinkNoise );

	public static inline function createBrownNoiseNode( audio : AudioContext, ?size : Int ) : ScriptProcessorNode
		return createNode( audio, size, generateBrownNoise );

	static function createNode( audio : AudioContext, size : Int, process : Float32Array->Int->Void ) : ScriptProcessorNode {
		var n = audio.createScriptProcessor( size, 1, 1 );
		n.onaudioprocess = function(e) process( e.outputBuffer.getChannelData(0), size );
		return n;
	}
}
