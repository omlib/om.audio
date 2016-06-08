
import js.Browser.console;
import js.Browser.document;
import js.Browser.window;
import js.html.CanvasElement;
import js.html.CanvasRenderingContext2D;
import js.html.audio.AudioContext;

class App {

    static var canvas : CanvasElement;
    static var context : CanvasRenderingContext2D;

    static function drawChannel( peaks : Array<Float> ) {
        var stepSizeX = canvas.width / peaks.length;
        var i = 0;
        var halfHeight = canvas.height / 2;
        for( peak in peaks ) {
            //var l = peak[0];
            //var r = peak[1];
            context.fillRect( i * stepSizeX, halfHeight, stepSizeX, (peak * 100) );
            i++;
        }
        context.stroke();
    }

    static function main() {

        var url = '../atari.mp3';

        canvas = document.createCanvasElement();
        canvas.width = window.innerWidth;
        canvas.height = window.innerHeight;
        canvas.style.backgroundColor = '#000';
        document.body.appendChild( canvas );

        context = canvas.getContext2d();
        context.fillStyle = '#fff000';

        var audio = new AudioContext();

        om.audio.AudioBufferLoader.load( audio, url, function(e,buf){
            if( e != null ) console.error(e) else {
                //var peaks = om.audio.Analyzer.getPeaks( buf, Std.int(width/2) )[1];
                var peaks = om.audio.Analyzer.getMergedPeaks( buf, canvas.width );
                trace(peaks.length);
                drawChannel( peaks );
            }
        });
    }
}
