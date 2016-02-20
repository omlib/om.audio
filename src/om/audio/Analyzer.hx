package om.audio;

import js.html.Float32Array;
import js.html.audio.AudioBuffer;

class Analyzer {

    /**
        Compute the max and min value of the waveform when broken into <length> subranges.
    */
    public static function getPeaks( buf : AudioBuffer, length : Int ) {
        var sampleSize = buf.length / length;
        var sampleStep = Std.int( ~~(sampleSize / 10) );
        var channels = buf.numberOfChannels;
        var splitPeaks = new Array<Array<Float>>();
        for( c in 0...channels ) {
            var peaks = splitPeaks[c] = [];
            var chan = buf.getChannelData(c);
            for( i in 0...length ) {
                var start = Std.int( ~~(i * sampleSize) );
                var end = ~~(start + sampleSize);
                var min = chan[0];
                var max = chan[0];
                var j = start;
                while( j < end ) {
                    var value = chan[j];
                    if( value > max ) max = value;
                    if( value < min ) min = value;
                    j += sampleStep;
                }
                peaks[2 * i] = max;
                peaks[2 * i + 1] = min;
            }
        }
        return splitPeaks;
    }

    public static function getMergedPeaks( buf : AudioBuffer, length : Int ) {
        var sampleSize = buf.length / length;
        var sampleStep = Std.int( ~~(sampleSize / 10) );
        var channels = buf.numberOfChannels;
        var mergedPeaks = new Array<Float>();
        for( c in 0...channels ) {
            var peaks = new Array<Float>();
            var chan = buf.getChannelData(c);
            for( i in 0...length ) {
                var start = Std.int( ~~(i * sampleSize) );
                var end = ~~(start + sampleSize);
                var min = chan[0];
                var max = chan[0];
                var j = start;
                while( j < end ) {
                    var value = chan[j];
                    if( value > max ) max = value;
                    if( value < min ) min = value;
                    j += sampleStep;
                }
                peaks[2 * i] = max;
                peaks[2 * i + 1] = min;
                if( c == 0 || max > mergedPeaks[2 * i] ) {
                    mergedPeaks[2 * i] = max;
                }
                if( c == 0 || min < mergedPeaks[2 * i + 1] ) {
                    mergedPeaks[2 * i + 1] = min;
                }
            }
        }
        return mergedPeaks;
    }

    public static function getChannelPeaks( data : Float32Array, length : Int ) : Array<Float> {
        var sampleSize = data.length / length;
        var sampleStep = Std.int( ~~(sampleSize / 10) );
        var peaks = new Array<Float>();
        for( i in 0...length ) {
            var start = Std.int( ~~(i * sampleSize) );
            var end = ~~(start + sampleSize);
            var min = data[0];
            var max = data[0];
            var j = start;
            while( j < end ) {
                var value = data[j];
                if( value > max ) max = value;
                if( value < min ) min = value;
                j += sampleStep;
            }
            peaks[2 * i] = max;
            peaks[2 * i + 1] = min;
        }
        return peaks;
    }
}
