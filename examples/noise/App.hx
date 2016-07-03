
import js.Browser.document;
import js.Browser.window;
import js.html.Float32Array;
import js.html.Uint8Array;
import js.html.CanvasElement;
import js.html.CanvasRenderingContext2D;
import js.html.audio.AnalyserNode;
import js.html.audio.AudioContext;
import js.html.audio.AudioBufferSourceNode;
import js.html.audio.ScriptProcessorNode;
import om.audio.generator.Noise;

class App {

    static inline var FFT_SIZE = 512;
    static inline var SMOOTHING = 0.8;

    static var audio : AudioContext;
    static var noise : String;
    static var analyser : AnalyserNode;

    static var canvas : CanvasElement;
    static var ctx : CanvasRenderingContext2D;
    static var freqs : Uint8Array;
    static var times : Uint8Array;
    static var dirtySpectrum = false;

    static function update( time : Float ) {

        window.requestAnimationFrame( update );

        analyser.getByteFrequencyData( freqs );
        analyser.getByteTimeDomainData( times );

        if( dirtySpectrum ) {

            ctx.clearRect( 0, 0, canvas.width, canvas.height );
            ctx.fillStyle = '#313131';

            var barWidth = canvas.width / analyser.frequencyBinCount;

            for( i in 0...analyser.frequencyBinCount ) {
                var value = freqs[i];
                var percent = value / 256;
                var height = canvas.height * percent;
                var offset = canvas.height - height - 1;
                var hue = i / analyser.frequencyBinCount * 60;
                ctx.fillStyle = 'hsl(' + hue + ', 100%, 50%)';
                ctx.fillRect( Std.int( i * barWidth ), offset, barWidth, height );
            }

            for( i in 0...analyser.frequencyBinCount ) {
                var value = times[i];
                var percent = value / 256;
                var height = canvas.height * percent;
                var offset = canvas.height - height - 1;
                ctx.fillStyle = 'white';
                ctx.fillRect( Std.int( i * barWidth ), offset, 1, 2 );
            }

            dirtySpectrum = false;
        }
    }

    static function handleWindowResize(e) {
        canvas.width = window.innerWidth;
        canvas.height = window.innerHeight;
    }

    static function main() {

		window.onload = function(){

            canvas = cast document.getElementById( 'spectrum' );
            canvas.style.backgroundColor = '#000';
            canvas.width = window.innerWidth;
            canvas.height = window.innerHeight;

            ctx = canvas.getContext2d();
            ctx.strokeStyle = '#fff';
            ctx.fillStyle = '#fff';

			audio = new AudioContext();

            var gain = audio.createGain();
            gain.gain.value = 0.5;
            gain.connect( audio.destination );

            analyser = audio.createAnalyser();
            analyser.smoothingTimeConstant = SMOOTHING;
            analyser.fftSize = FFT_SIZE;
            //analyser.minDecibels = -140;
            //analyser.maxDecibels = 0;
            analyser.connect( gain );

            freqs = new Uint8Array( analyser.frequencyBinCount );
            times = new Uint8Array( analyser.frequencyBinCount );

            var noiseBufferSize = 4096;

            var whiteNoise = audio.createScriptProcessor( noiseBufferSize, 1, 1 );
    		whiteNoise.onaudioprocess = function(e) {
                Noise.generateWhiteNoise( e.outputBuffer.getChannelData(0), noiseBufferSize );
                dirtySpectrum = true;
            };

            var brownNoise = audio.createScriptProcessor( noiseBufferSize, 1, 1 );
    		brownNoise.onaudioprocess = function(e) {
                Noise.generateBrownNoise( e.outputBuffer.getChannelData(0), noiseBufferSize );
                dirtySpectrum = true;
            };

            var pinkNoise = audio.createScriptProcessor( noiseBufferSize, 1, 1 );
    		pinkNoise.onaudioprocess = function(e) {
                Noise.generatePinkNoise( e.outputBuffer.getChannelData(0), noiseBufferSize );
                dirtySpectrum = true;
            };

            var noises = [
                'white' => whiteNoise,
                'pink' => pinkNoise,
                'brown' => brownNoise
            ];

            var noiseTypes = ['white','brown','pink'];
            for( type in noiseTypes ) {
				var e = document.getElementById( type );
				//e.setAttribute( 'active', 'false' );
				e.style.textDecoration = 'line-through';
				e.onclick = function(){
                    if( e.style.textDecoration == 'none' ) {
                        e.style.textDecoration = 'line-through';
                        noises.get( type ).disconnect();
                    } else {
                        e.style.textDecoration = 'none';
                        noises.get( type ).connect( analyser );
                    }
				}
			}

            window.addEventListener( 'resize', handleWindowResize, false );
            window.requestAnimationFrame( update );
        }
    }
}
