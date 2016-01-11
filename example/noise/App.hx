
import js.Browser.document;
import js.Browser.window;
import js.html.audio.AudioContext;
import js.html.audio.AudioBufferSourceNode;
import js.html.audio.ScriptProcessorNode;
import om.audio.NoiseGenerator;

class App {

    static var audio : AudioContext;
    static var noise : ScriptProcessorNode;

    static function selectNoise( type : String ) {
        if( noise != null ) noise.disconnect();
        noise = switch type {
        case 'white': NoiseGenerator.generateWhiteNoise( audio );
        case 'pink': NoiseGenerator.generatePinkNoise( audio );
        case 'brown': NoiseGenerator.generateBrownNoise( audio );
        default: null;
        }
        noise.connect( audio.destination );
    }

    static function main() {

        audio = new AudioContext();

        selectNoise( 'white' );

        var select : js.html.SelectElement = cast document.getElementById( 'noise' );
        select.onchange = function(e){
            selectNoise( e.target.value );
        }
    }
}
