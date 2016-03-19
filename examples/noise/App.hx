
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

		window.onload = function(){

			audio = new AudioContext();

			var noise = [
				'white' => NoiseGenerator.generateWhiteNoise( audio ),
				'pink' => NoiseGenerator.generatePinkNoise( audio ),
				'brown' => NoiseGenerator.generateBrownNoise( audio )
			];

			//selectNoise( 'white' );

			for( type in noise.keys() ) {
				var e = document.getElementById( type );
				//e.setAttribute( 'active', 'false' );
				e.style.textDecoration = 'line-through';
				e.onclick = function(){
					//e.setAttribute( (e.getAttribute('active')=='false') ? 'true' : 'false' );
					if( e.style.textDecoration == 'none' ) {
						e.style.textDecoration = 'line-through';
						noise.get( type ).disconnect();
					} else {
						e.style.textDecoration = 'none';
						noise.get( type ).connect( audio.destination );
					}
					//e.style.textDecoration = (e.style.textDecoration == 'none') ? 'line-through':'none';

				}

			}
		}
    }
}
