package om.audio.synth;

import js.html.audio.AudioNode;
import js.html.audio.AudioContext;
import js.html.audio.BiquadFilterNode;
import js.html.audio.GainNode;
import js.html.audio.OscillatorNode;
import js.html.audio.OscillatorType;

/**
    http://www.korg.com/us/products/dj/monotron/
*/
class Monotron {

    public var context(default,null) : AudioContext;
    public var vco(default,null) : OscillatorNode;
    public var lfo(default,null) : OscillatorNode;
    public var lfoGain(default,null) : GainNode;
    public var vcf(default,null) : BiquadFilterNode;

    var output : GainNode;

    public function new( context : AudioContext ) {

        this.context = context;

        vco = context.createOscillator();
        lfo = context.createOscillator();
        lfoGain = context.createGain();
        vcf = context.createBiquadFilter();
        output = context.createGain();

        vco.connect( vcf );
        lfo.connect( lfoGain );
        lfoGain.connect( vcf.frequency );
        vcf.connect( output );

        output.gain.value = 0;

        vco.type = SAWTOOTH;
        lfo.type = SAWTOOTH;

        vco.start( context.currentTime );
        lfo.start( context.currentTime );
    }

    public function connect( target : AudioNode ) : AudioNode {
        return output.connect( target );
    }

    public function noteOn( frequency : Float, ?time : Float ) {
        if( time == null ) time = context.currentTime;
        vco.frequency.setValueAtTime( frequency, time );
        output.gain.linearRampToValueAtTime( 1.0, time + 0.1 );
    }

    public function noteOff( ?time : Float ) {
        if( time == null ) time = context.currentTime;
        output.gain.linearRampToValueAtTime( 0.0, time + 0.1 );
    }

}
