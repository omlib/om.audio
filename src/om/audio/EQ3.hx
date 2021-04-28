package om.audio;

#if js

import js.html.audio.AudioContext;
import js.html.audio.AudioNode;
import js.html.audio.AudioBufferSourceNode;
import js.html.audio.BiquadFilterNode;
import js.html.audio.GainNode;

enum abstract Band(Int) from Int to Int {
    var low;
    var mid;
    var hi;
}
class EQ3 {

    public var hi(get,set) : Float;
    inline function get_hi() return hGain.gain.value;
    inline function set_hi(v:Float) return hGain.gain.value = v;

    public var mid(get,set) : Float;
    inline function get_mid() return mGain.gain.value;
    inline function set_mid(v:Float) return mGain.gain.value = v;

    public var low(get,set) : Float;
    inline function get_low() return lGain.gain.value;
    inline function set_low(v:Float) return lGain.gain.value = v;

    public var hBand : BiquadFilterNode;
    public var mBand : GainNode;
    public var lBand : BiquadFilterNode;

    public var hInvert : GainNode;
    public var lInvert : GainNode;

    public var hGain : GainNode;
    public var mGain : GainNode;
    public var lGain : GainNode;

    public var sum : GainNode;

    public function new( context : AudioContext, gainDb = -40.0, ?split : Array<Int> ) {

        if( split == null ) split = [360,3600];

        hBand = context.createBiquadFilter();
        hBand.type = LOWSHELF;
        hBand.frequency.value = split[0];
        hBand.gain.value = gainDb;

        hInvert = context.createGain();
        hInvert.gain.value = -1.0;

        mBand = context.createGain();

        lBand = context.createBiquadFilter();
        lBand.type = HIGHSHELF;
        lBand.frequency.value = split[1];
        lBand.gain.value = gainDb;

        lInvert = context.createGain();
        lInvert.gain.value = -1.0;

        lGain = context.createGain();
        mGain = context.createGain();
        hGain = context.createGain();

        lBand.connect( lGain );
        mBand.connect( mGain );
        hBand.connect( hGain );

        hBand.connect( hInvert );
        lBand.connect( lInvert );

        hInvert.connect( mBand );
        lInvert.connect( mBand );

        sum = context.createGain();
        lGain.connect( sum );
        mGain.connect( sum );
        hGain.connect( sum );
    }

    public function connectInput( input : AudioNode ) {
        input.connect( lBand );
        input.connect( mBand );
        input.connect( hBand );
    }


    public function connectOutput( node : AudioNode ) {
        sum.connect( node );
    }

    public function get( band : Band ) : Float {
        return switch band {
        case low: lGain.gain.value;
        case mid: mGain.gain.value;
        case hi: hGain.gain.value;
        }
    }

    public function set( band : Band, value : Float ) {
        switch band {
        case low: lGain.gain.value = value;
        case mid: mGain.gain.value = value;
        case hi: hGain.gain.value = value;
        }
    }

}

#end
