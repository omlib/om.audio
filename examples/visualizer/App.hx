
import js.Browser.console;
import js.Browser.document;
import js.Browser.window;
import js.html.CanvasElement;
import js.html.DivElement;
import js.html.Uint8Array;
import js.html.CanvasRenderingContext2D;
import js.html.audio.AudioContext;
import js.html.audio.AnalyserNode;
import js.html.audio.AudioBufferSourceNode;

class App {

    static var info : DivElement;
    static var canvas : CanvasElement;
    static var context : CanvasRenderingContext2D;
    static var source : AudioBufferSourceNode;
    static var analyser : AnalyserNode;
    static var freqData : Uint8Array;
    static var timeData : Uint8Array;

    static function getAverageVolume( data : Uint8Array ) : Float {
        var t = 0;
        for( v in data ) t += v;
        return t / data.length;
    }

    static function update( time : Float ) {

        window.requestAnimationFrame( update );

        analyser.getByteFrequencyData( freqData );
        analyser.getByteTimeDomainData( timeData );

        var averageVolume = getAverageVolume( freqData );
        info.textContent = averageVolume+'';

        context.clearRect( 0, 0, canvas.width, canvas.height );
        for( i in 0...analyser.frequencyBinCount ) {
            var v = freqData[i];
            var percent = v / 256;
            var height = canvas.height * percent;
            var offset = canvas.height - height - 1;
            var barWidth = canvas.width / analyser.frequencyBinCount;
            var hue = i / analyser.frequencyBinCount * 360;
            context.fillStyle = 'hsl(' + hue + ', 100%, 50%)';
            context.fillRect(i * barWidth, offset, barWidth, height);
        }
        for( i in 0...analyser.frequencyBinCount ) {
            var v = timeData[i];
            var percent = v / 256;
            var height = canvas.height * percent;
            var offset = canvas.height - height - 1;
            var barWidth = canvas.width / analyser.frequencyBinCount;
            context.fillStyle = 'white';
            context.fillRect( i * barWidth, offset, 1, 2 );
        }
    }

    static function main() {

        var url = '../arturia.ogg';

        info = document.createDivElement();
        info.id = 'info';
        document.body.appendChild( info );

        canvas = document.createCanvasElement();
        canvas.width = window.innerWidth;
        canvas.height = window.innerHeight;
        canvas.style.backgroundColor = '#000';
        document.body.appendChild( canvas );

        context = canvas.getContext2d();
        context.fillStyle = '#fff000';

        var audio = new AudioContext();

        analyser = audio.createAnalyser();
        analyser.smoothingTimeConstant = 0.8;
        analyser.fftSize = 2048;
        analyser.minDecibels = -140;
        analyser.maxDecibels = 0;
        analyser.connect( audio.destination );

        freqData = new Uint8Array( analyser.frequencyBinCount );
        timeData = new Uint8Array( analyser.frequencyBinCount );

        om.audio.AudioBufferLoader.load( audio, url, function(e,buf){

            if( e != null ) console.error(e) else {

                source = audio.createBufferSource();
                source.connect( analyser );
                source.buffer = buf;
                source.loop = true;
                source.start();

                window.requestAnimationFrame( update );
            }
        });
    }
}
