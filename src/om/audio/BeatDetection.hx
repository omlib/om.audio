package om.audio;

import js.Promise;
import js.html.Float32Array;
import js.html.audio.AudioBuffer;
import js.html.audio.AudioBufferSourceNode;
import js.html.audio.BiquadFilterType;
import js.html.audio.OfflineAudioContext;

class BeatDetection {

    public static function detectBeats( buf : AudioBuffer, threshold : Float, frequency = 350 ) : Promise<Array<Int>> {

        var ctx = new OfflineAudioContext( 1, buf.length, buf.sampleRate );

        var filter = ctx.createBiquadFilter();
        filter.type = LOWPASS;
        filter.frequency.value = frequency;
        filter.connect( ctx.destination );

        var source = ctx.createBufferSource();
        source.buffer = buf;
        source.connect( filter );
        source.start();

        return ctx.startRendering().then( function( buf ) {
            var beats = getPeaks( buf.getChannelData( 0 ), threshold );
            return Promise.resolve( beats );
        });
    }

    /**
    */
    public static function getPeaks( data : Float32Array, threshold : Float, skipForward = 11025 ) : Array<Int> {
        var peaks = new Array<Int>();
        var i = 0;
        while( i < data.length ) {
            if( data[i] > threshold ) {
                peaks.push( i );
                // Skip forward ~ 1/4s to get past this peak.
                i += skipForward;
            }
            i++;
        }
        return peaks;
    }

    /*
    */
    public static function countIntervalsBetweenNearbyPeaks( peaks : Array<Int> ) {
        var map = new Map<String,Int>();
        for( peak in peaks ) {
            var str = Std.string( peak );
            if( map.exists( str ) ) {
                map.set( str, map.get( str )+1 );
            } else {
                map.set( str, 1 );
            }

        }
        trace(map);

        /*
        var intervalCounts = new Array<{interval:Int,count:Int}>();
        var index = 0;
        for( peak in peaks ) {
            var i = 0;
            while( i < 10 ) {
                var interval = peaks[index + i] - peak;
                for( foundInterval in intervalCounts ) {
                    if( foundInterval.interval == interval )
                        foundInterval.interval++;
                }
                i++;
            }
            if( )
            index++;
        }
        */
    }
        /*
  peaks.forEach(function(peak, index) {
    for(var i = 0; i < 10; i++) {
      var interval = peaks[index + i] - peak;
      var foundInterval = intervalCounts.some(function(intervalCount) {
        if (intervalCount.interval === interval)
          return intervalCount.count++;
      });
      if (!foundInterval) {
        intervalCounts.push({
          interval: interval,
          count: 1
        });
      }
    }
  });
  return intervalCounts;
}
*/

}
