package om.audio;

import js.html.audio.AudioBufferSourceNode;
import js.html.audio.AudioContext;
import js.html.audio.AudioNode;
import js.html.audio.ScriptProcessorNode;

class NoiseGenerator {

	/*
	public static function generateWhiteNoise( ctx : AudioContext ) : AudioBufferSourceNode {
		var size = Std.int( 2 * ctx.sampleRate );
		var buf = ctx.createBuffer( 1, size, ctx.sampleRate );
		var out = buf.getChannelData(0);
		for( i in 0...size )
			out[i] = Math.random() * 2 - 1;
		var src = ctx.createBufferSource();
		src.buffer = buf;
		src.loop = true;
		//src.connect( destination, null, null );
		return src;
	}
	*/

	public static function generateWhiteNoise( ctx : AudioContext, bufferSize = 4096 ) : ScriptProcessorNode {
		var node = ctx.createScriptProcessor( bufferSize, 1, 1 );
		node.onaudioprocess = function(e) {
			var output = e.outputBuffer.getChannelData(0);
			for( i in 0...bufferSize ) {
				output[i] = Math.random() * 2 - 1;
			}
		}
		return node;
	}

	public static function generatePinkNoise( ctx : AudioContext, bufferSize = 4096 ) : ScriptProcessorNode {
		var b0, b1, b2, b3, b4, b5, b6;
    	b0 = b1 = b2 = b3 = b4 = b5 = b6 = 0.0;
    	var node = ctx.createScriptProcessor( bufferSize, 1, 1 );
    	node.onaudioprocess = function(e) {
	        var output = e.outputBuffer.getChannelData(0);
	        for( i in 0...bufferSize ) {
	            var white = Math.random() * 2 - 1;
	            b0 = 0.99886 * b0 + white * 0.0555179;
	            b1 = 0.99332 * b1 + white * 0.0750759;
	            b2 = 0.96900 * b2 + white * 0.1538520;
	            b3 = 0.86650 * b3 + white * 0.3104856;
	            b4 = 0.55000 * b4 + white * 0.5329522;
	            b5 = -0.7616 * b5 - white * 0.0168980;
	            output[i] = b0 + b1 + b2 + b3 + b4 + b5 + b6 + white * 0.5362;
	            output[i] *= 0.11; // (roughly) compensate for gain
	            b6 = white * 0.115926;
	        }
	    }
	    return node;
	}

	public static function generateBrownNoise( ctx : AudioContext, bufferSize = 4096 ) : ScriptProcessorNode {
		var lastOut = 0.0;
		var node = ctx.createScriptProcessor( bufferSize, 1, 1 );
    	node.onaudioprocess = function(e) {
	        var output = e.outputBuffer.getChannelData(0);
	        for( i in 0...bufferSize ) {
				var white = Math.random() * 2 - 1;
	            output[i] = (lastOut + (0.02 * white)) / 1.02;
	            lastOut = output[i];
	            output[i] *= 3.5; // (roughly) compensate for gain
	        }
	    }
	    return node;
	}
}
