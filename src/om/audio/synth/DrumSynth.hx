package om.audio.synth;

import js.html.audio.AudioContext;
import js.html.audio.AudioNode;
import js.html.audio.GainNode;

class DrumSynth {

    var context : AudioContext;
    var mixGain : GainNode;
    var filterGain : GainNode;

    public function new( context : AudioContext ) {

        this.context = context;

        filterGain = context.createGain();
        filterGain.gain.value = 0;

        mixGain = context.createGain();
        mixGain.gain.value = 0;
        //mixGain.connect( context.destination );
    }

    public function connect( node : AudioNode ) {
        mixGain.connect( node );
    }

    public function kick() {

        var osc = context.createOscillator();
        var osc2 = context.createOscillator();
        var gainOsc = context.createGain();
        var gainOsc2 = context.createGain();

        osc.type = TRIANGLE;
        osc2.type = SINE;

        gainOsc.gain.setValueAtTime( 1, context.currentTime );
        gainOsc.gain.exponentialRampToValueAtTime( 0.001, context.currentTime + 0.5 );

        gainOsc2.gain.setValueAtTime( 1, context.currentTime );
        gainOsc2.gain.exponentialRampToValueAtTime( 0.001, context.currentTime + 0.5 );

        osc.frequency.setValueAtTime( 120, context.currentTime );
        osc.frequency.exponentialRampToValueAtTime( 0.001, context.currentTime + 0.5 );

        osc2.frequency.setValueAtTime( 50, context.currentTime );
        osc2.frequency.exponentialRampToValueAtTime( 0.001, context.currentTime + 0.5 );

        osc.connect( gainOsc );
        osc2.connect( gainOsc2 );
        gainOsc.connect( context.destination );
        gainOsc2.connect( context.destination );

        osc.start( context.currentTime );
        osc2.start( context.currentTime );

        osc.stop( context.currentTime + 0.5 );
        osc2.stop( context.currentTime + 0.5 );
    }

    public function snare() {

        var osc3 = context.createOscillator();
        var gainOsc3 = context.createGain();

        filterGain.gain.setValueAtTime( 1, context.currentTime );
        filterGain.gain.exponentialRampToValueAtTime( 0.01, context.currentTime + 0.2 );

        osc3.type = TRIANGLE;
        osc3.frequency.value = 100;
        gainOsc3.gain.value = 0;

        gainOsc3.gain.setValueAtTime( 0, context.currentTime );
        gainOsc3.gain.exponentialRampToValueAtTime( 0.01, context.currentTime + 0.1 );

        osc3.connect(gainOsc3);
        gainOsc3.connect(mixGain);

        mixGain.gain.value = 1;

        osc3.start( context.currentTime );
        osc3.stop( context.currentTime + 0.2 );

        var node = context.createBufferSource(),
        buffer = context.createBuffer( 1, 4096, context.sampleRate ),
        data = buffer.getChannelData( 0 );

        var filter = context.createBiquadFilter();
        filter.type = HIGHPASS;
        filter.frequency.setValueAtTime( 100, context.currentTime);
        filter.frequency.linearRampToValueAtTime( 1000, context.currentTime + 0.2 );

        for( i in 0...4096 ) data[i] = Math.random();

        node.buffer = buffer;
        node.loop = true;
        node.connect( filter );

        filter.connect( filterGain );
        filterGain.connect( mixGain );

        node.start( context.currentTime );
        node.stop( context.currentTime + 0.2 );
    }

    public function hihat() {

        var gainOsc4 = context.createGain();
        var fundamental = 40;
        var ratios = [ 2, 3, 4.16, 5.43, 6.79, 8.21 ];

        var bandpass = context.createBiquadFilter();
        bandpass.type = BANDPASS;
        bandpass.frequency.value = 10000;

        var highpass = context.createBiquadFilter();
        highpass.type = HIGHPASS;
        highpass.frequency.value = 7000;

        for( ratio in ratios ) {

            var osc4 = context.createOscillator();
            osc4.type = SQUARE;
            osc4.frequency.value = fundamental * ratio;
            osc4.connect(bandpass);

            osc4.start( context.currentTime );
            osc4.stop( context.currentTime + 0.05 );
        }

        gainOsc4.gain.setValueAtTime( 1, context.currentTime );
        gainOsc4.gain.exponentialRampToValueAtTime( 0.01, context.currentTime + 0.05 );

        bandpass.connect( highpass );
        highpass.connect( gainOsc4 );
        gainOsc4.connect( mixGain );

        mixGain.gain.value = 1;
    }

}
