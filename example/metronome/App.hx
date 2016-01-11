
import js.Browser.document;
import js.Browser.window;
import js.html.CanvasElement;
import js.html.audio.AudioContext;
import om.audio.Metronome;

class App {

    static var canvas : CanvasElement;
    static var audio : AudioContext;
    static var metronome : Metronome;
    static var last16thNoteDrawn = -1.0;

    static function update( time : Float ) {

        window.requestAnimationFrame( update );

        var currentNote = last16thNoteDrawn;
        var currentTime = audio.currentTime;

        while( metronome.notesInQueue.length > 0 &&  metronome.notesInQueue[0].time < currentTime ) {
            currentNote =  metronome.notesInQueue[0].note;
            metronome.notesInQueue.splice( 0, 1 );
        }

        var ctx = canvas.getContext2d();
        if( last16thNoteDrawn != currentNote ) {
            var x = Math.floor( canvas.width / 18 );
            ctx.clearRect( 0, 0, canvas.width, canvas.height );
            for( i in 0...16 ) {
                ctx.fillStyle = (currentNote == i) ? ((currentNote%4 == 0)?"yellow":"blue") : "black";
                ctx.fillRect( x * (i+1), x, x/2, x/2 );
            }
            last16thNoteDrawn = currentNote;
        }
    }

    static function main() {

        canvas = document.createCanvasElement();
        canvas.width = 300;
        canvas.height = 200;
        document.body.appendChild( canvas );

        audio = new AudioContext();

        metronome = new Metronome( audio, 120 );
        metronome.play();

        window.requestAnimationFrame( update );

        window.addEventListener( 'mousedown', function(e){
            //metronome.tempo = Std.int( e.clientX);
            //metronome.stop();
        }, false );

    }
}
