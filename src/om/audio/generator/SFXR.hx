package om.audio.generator;

import js.html.ArrayBuffer;
import js.html.Float32Array;

@:enum abstract Shape(Int) from Int to Int {
    var Square = 0;
    var Sawtooth = 1;
    var Sine = 2;
    var Noise = 3;
}

typedef Params = {

    @:optional var wave_type : Shape;

    @:optional var base_freq : Float;
	@:optional var freq_limit : Float;
	@:optional var freq_ramp : Float;
	@:optional var freq_dramp : Float;
	@:optional var duty : Float;
	@:optional var duty_ramp : Float;

	@:optional var vib_strength : Float;
	@:optional var vib_speed : Float;
	@:optional var vib_delay : Float;

	@:optional var env_attack : Float;
	@:optional var env_sustain : Float;
	@:optional var env_decay : Float;
	@:optional var env_punch : Float;

	@:optional var lpf_resonance : Float;
	@:optional var lpf_freq : Float;
	@:optional var lpf_ramp : Float;
	@:optional var hpf_freq : Float;
	@:optional var hpf_ramp : Float;

	@:optional var pha_offset : Float;
	@:optional var pha_ramp : Float;

	@:optional var repeat_speed : Float;

	@:optional var arp_speed: Float;
	@:optional var arp_mod: Float;

    @:optional var volume : Float;
}

class SFXR {

    public function new() {}

    public function generate( desc : Params ) : Array<Float> {

        var phase = 0;
    	var fperiod = 0.0;
    	var fmaxperiod = 0.0;
    	var fslide = 0.0;
    	var fdslide = 0.0;
    	var period = 0;
    	var square_duty = 0.0;
    	var square_slide = 0.0;

        // reset filter
    	var fltp = 0.0;
    	var fltdp = 0.0;
    	var fltw = Math.pow( desc.lpf_freq, 3.0) * 0.1;
    	var fltw_d = 1.0 + desc.lpf_ramp * 0.0001;
    	var fltdmp = 5.0 / (1.0 + Math.pow(desc.lpf_resonance, 2.0) * 20.0) * (0.01 + fltw);
    	if( fltdmp > 0.8 ) fltdmp = 0.8;
    	var fltphp = 0.0;
    	var flthp = Math.pow(desc.hpf_freq, 2.0) * 0.1;
    	var flthp_d = 1.0 + desc.hpf_ramp * 0.0003;
    	// reset vibrato
    	var vib_phase = 0.0;
    	var vib_speed = Math.pow(desc.vib_speed, 2.0) * 0.01;
    	var vib_amp = desc.vib_strength * 0.5;
    	// reset envelope
    	var env_vol = 0.0;
    	var env_stage = 0;
    	var env_time = 0;
    	var env_length = [
    		Math.round( desc.env_attack * desc.env_attack * 100000.0 ),
    		Math.round( desc.env_sustain * desc.env_sustain * 100000.0 ),
    		Math.round( desc.env_decay * desc.env_decay * 100000.0 )
    	];

        var fphase = Math.pow( desc.pha_offset, 2.0 ) * 1020.0;
    	if( desc.pha_offset < 0.0 ) fphase = -fphase;
    	var fdphase = Math.pow( desc.pha_ramp, 2.0 ) * 1.0;
    	if( desc.pha_ramp < 0.0 ) fdphase = -fdphase;
    	var iphase = Math.abs( Math.round( fphase ) );
    	var ipp = 0;

    	var phaser_buffer = [for( i in 0...1024 ) 0.0];
    	var noise_buffer = [for( i in 0...32 ) Math.random() * 2.0 - 1.0];

    	var rep_time = 0;
    	var rep_limit = Math.round( Math.pow( 1.0 - desc.repeat_speed, 2.0 ) * 20000 + 32 );
    	if( desc.repeat_speed == 0.0 ) rep_limit = 0;

    	var arp_time = 0;
    	var arp_limit = 0;
    	var arp_mod = 0.0;

        function restart() {
            fperiod = 100.0 / ( desc.base_freq * desc.base_freq + 0.001 );
            period = Math.round( fperiod );
            fmaxperiod = 100.0 / ( desc.freq_limit * desc.freq_limit + 0.001 );
            fslide = 1.0 - Math.pow( desc.freq_ramp, 3.0 ) * 0.01;
            fdslide = - Math.pow( desc.freq_dramp, 3.0 ) * 0.000001;
            square_duty = 0.5 - desc.duty * 0.5;
            square_slide = -desc.duty_ramp * 0.00005;
            if( desc.arp_mod >= 0.0 ) {
                arp_mod = 1.0 - Math.pow( desc.arp_mod, 2.0 ) * 0.9;
            } else {
                arp_mod = 1.0 + Math.pow( desc.arp_mod, 2.0 ) * 10.0;
            }
            arp_time = 0;
            arp_limit = Math.round( Math.pow( 1.0 - desc.arp_speed, 2.0 ) * 20000 + 32 );
            if( desc.arp_speed == 1.0 ) {
                arp_limit = 0;
            }
        }

        restart();

        var samples = new Array<Float>();
        var synthesizing = true;

        while( synthesizing ) {

            rep_time++;

    		if( rep_limit != 0 && rep_time >= rep_limit ) {
    			rep_time = 0;
    			restart();
    		}

            // frequency envelopes / arpeggios
    		arp_time++;
    		if( arp_limit != 0 && arp_time >= arp_limit ) {
    			arp_limit = 0;
    			fperiod *= arp_mod;
    		}

    		fslide += fdslide;
    		fperiod *= fslide;
    		if( fperiod > fmaxperiod ) {
    			fperiod = fmaxperiod;
    			if( desc.freq_limit > 0.0 ) {
    				synthesizing = false;
    			}
    		}

    		var rfperiod = fperiod;
    		if( vib_amp > 0.0 ) {
    			vib_phase += vib_speed;
    			rfperiod = fperiod * ( 1.0 + Math.sin( vib_phase ) * vib_amp );
    		}

    		period = Math.round( rfperiod );
    		if( period < 8 ) period = 8;

    		square_duty += square_slide;
    		if( square_duty < 0.0 ) square_duty = 0.0;
    		if( square_duty > 0.5 ) square_duty = 0.5;

            // volume envelope
    		env_time++;
    		if( env_time > env_length[env_stage] ) {
    			env_time = 0;
    			env_stage++;
    			if( env_stage == 3 ) {
    				synthesizing = false;
    			}
    		}

    		if( env_stage == 0 ) {
    			env_vol = env_time / env_length[0];
    		}
    		if( env_stage == 1 ) {
    			env_vol = 1.0 + Math.pow( 1.0 - env_time / env_length[1], 1.0 ) * 2.0 * desc.env_punch;
    		}
    		if( env_stage == 2 ) {
    			env_vol = 1.0 - env_time / env_length[2];
    		}

    		// phaser step
    		fphase += fdphase;
    		iphase = Math.abs( Math.round( fphase ) );
    		if( iphase > 1023 ) iphase = 1023;

    		if( flthp_d != 0.0 ) {
    			flthp *= flthp_d;
    			if( flthp < 0.00001 ) flthp = 0.00001;
    			if( flthp > 0.1 ) flthp = 0.1;
    		}

            var ssample = 0.0;

            for( si in 0...8 ) {

                var sample = 0.0;
    			phase++;

    			if( phase >= period ) {
    				//phase = 0;
    				phase %= period;
    				if( desc.wave_type == Shape.Noise ) {
                        for( i in 0...32 ) {
    						noise_buffer[i] = Math.random() * 2.0 - 1.0;
    					}
    				}
    			}

    			// base waveform
    			var fp = phase / period;

    			sample = switch desc.wave_type {
    				case 0: (fp < square_duty) ? 0.5 : -0.5;
    				case 1: 1.0 - fp * 2;
    				case 2: Math.sin(fp * 2 * Math.PI);
    				case 3:	noise_buffer[Math.floor(phase * 32 / period)];
    			}

    			// lp filter
    			var pp = fltp;
    			fltw *= fltw_d;
    			if( fltw < 0.0 ) fltw = 0.0;
    			if( fltw > 0.1 ) fltw = 0.1;
    			if( desc.lpf_freq != 1.0 ) {
    				fltdp += (sample - fltp) * fltw;
    				fltdp -= fltdp * fltdmp;
    			}
    			else {
    				fltp = sample;
    				fltdp = 0.0;
    			}

    			fltp += fltdp;

    			// hp filter
    			fltphp += fltp - pp;
    			fltphp -= fltphp * flthp;
    			sample = fltphp;

    			// phaser
    			phaser_buffer[ipp & 1023] = sample;
    			sample += phaser_buffer[Std.int(ipp - iphase + 1024) & 1023];
    			ipp = (ipp + 1) & 1023;

    			// final accumulation and envelope application
    			ssample += sample * env_vol;
            }

            ssample = ssample / 8 * 2.0 * desc.volume;

            if( ssample > 1.0 ) ssample = 1.0;
            if( ssample < -1.0 ) ssample = -1.0;

            samples.push( ssample );
        }

        return samples;
    }

    public static function generatePickupCoin() {
        var desc = makeDescriptor();
        desc.base_freq = 0.4 + frnd( 0.5 );
        desc.env_attack = 0.0;
        desc.env_sustain = frnd( 0.1 );
        desc.env_decay = 0.1 + frnd( 0.4 );
        desc.env_punch = 0.3 + frnd( 0.3 );
        return desc;
    }

    public static function generatePowerup() {
        var desc = makeDescriptor();
    	if( rnd( 1 ) > 0 ) {
    		desc.wave_type = Shape.Sawtooth;
    	} else {
    		desc.duty = frnd( 0.6 );
    	}
    	if( rnd( 1 ) > 0 ) {
    		desc.base_freq = 0.2 + frnd( 0.3 );
    		desc.freq_ramp = 0.1 + frnd( 0.4 );
    		desc.repeat_speed = 0.4 + frnd( 0.4 );
    	}
    	else {
    		desc.base_freq = 0.2 + frnd( 0.3 );
    		desc.freq_ramp = 0.05 + frnd( 0.2 );
    		if( rnd( 1 ) > 0 ) {
    			desc.vib_strength = frnd( 0.7 );
    			desc.vib_speed = frnd( 0.6 );
    		}
    	}
    	desc.env_attack = 0.0;
    	desc.env_sustain = frnd( 0.4 );
    	desc.env_decay = 0.1 + frnd( 0.4 );
    	return desc;
    }

    public static function generateLaserShoot() {
        var desc = makeDescriptor();
    	desc.wave_type = pick( [ Shape.Square, Shape.Sawtooth, Shape.Sine ] );
    	if( desc.wave_type == Shape.Sine && rnd( 1 ) > 0 ) {
    		desc.wave_type = pick( [Shape.Square, Shape.Sawtooth] );
    	}
    	desc.base_freq = 0.5 + frnd( 0.5 );
    	desc.freq_limit = desc.base_freq - 0.2 - frnd( 0.6 );
    	if( desc.freq_limit < 0.2 ) {
    		desc.freq_limit = 0.2;
    	}
    	desc.freq_ramp = -0.15 - frnd( 0.2 );
    	if( rnd( 2 ) == 0 ) {
    		desc.base_freq = 0.3 + frnd( 0.6 );
    		desc.freq_limit = frnd( 0.1 );
    		desc.freq_ramp = -0.35 - frnd( 0.3 );
    	}
    	if( rnd( 1 ) > 0 ) {
    		desc.duty = frnd( 0.5 );
    		desc.duty_ramp = frnd( 0.2 );
    	}
    	else {
    		desc.duty = 0.4 + frnd( 0.5 );
    		desc.duty_ramp = -frnd( 0.7 );
    	}
    	desc.env_attack = 0.0;
    	desc.env_sustain = 0.1 + frnd( 0.2 );
    	desc.env_decay = frnd( 0.4 );
    	if( rnd( 1 ) > 0 ) {
    		desc.env_punch = frnd( 0.3 );
    	}
    	if( rnd( 2 ) == 0 ) {
    		desc.pha_offset = frnd( 0.2 );
    		desc.pha_ramp = -frnd( 0.2 );
    	}
    	if( rnd( 1 ) > 0 ) {
    		desc.hpf_freq = frnd( 0.3 );
    	}
    	return desc;
    }

    public static function generateExplosion() {
        var desc = makeDescriptor();
    	desc.wave_type = Shape.Noise;
    	if( rnd( 1 ) > 0 ) {
    		desc.base_freq = 0.1 + frnd( 0.4 );
    		desc.freq_ramp = -0.1 + frnd( 0.4 );
    	} else {
    		desc.base_freq = 0.2 + frnd( 0.7 );
    		desc.freq_ramp = -0.2 - frnd( 0.2 );
    	}
    	desc.base_freq *= desc.base_freq;
    	if( rnd( 4 ) == 0 ) {
    		desc.freq_ramp = 0.0;
    	}
    	if( rnd( 2 ) == 0 ) {
    		desc.repeat_speed = 0.3 + frnd( 0.5 );
    	}
    	desc.env_attack = 0.0;
    	desc.env_sustain = 0.1 + frnd( 0.3 );
    	desc.env_decay = frnd( 0.5 );
    	if( rnd( 1 ) == 0 ) {
    		desc.pha_offset = -0.3 + frnd( 0.9 );
    		desc.pha_ramp = -frnd( 0.3 );
    	}
    	desc.env_punch = 0.2 + frnd( 0.6 );
    	if( rnd( 1 ) > 0 ) {
    		desc.vib_strength = frnd( 0.7 );
    		desc.vib_speed = frnd( 0.6 );
    	}
    	if( rnd( 2 ) == 0 ) {
    		desc.arp_speed = 0.6 + frnd( 0.3 );
    		desc.arp_mod = 0.8 - frnd( 1.6 );
    	}
    	return desc;
    }

    public static function generateHitHurt() {
        var desc = makeDescriptor();
    	desc.wave_type = pick([Shape.Square, Shape.Sawtooth, Shape.Noise]);
    	if( desc.wave_type == 0 ) {
    		desc.duty = frnd( 0.6 );
    	}
    	desc.base_freq = 0.2 + frnd( 0.6 );
    	desc.freq_ramp = -0.3 - frnd( 0.4 );
    	desc.env_attack = 0.0;
    	desc.env_sustain = frnd( 0.1 );
    	desc.env_decay = 0.1 + frnd( 0.2 );
    	if( rnd( 1 ) > 0 ) {
    		desc.hpf_freq = frnd( 0.3 );
    	}

    	return desc;
    }

    public static function generateJump() {
        var desc = makeDescriptor();
    	desc.wave_type = Shape.Square;
    	desc.duty = frnd(0.6);
    	desc.base_freq = 0.3 + frnd(0.3);
    	desc.freq_ramp = 0.1 + frnd(0.2);
    	desc.env_attack = 0.0;
    	desc.env_sustain = 0.1 + frnd(0.3);
    	desc.env_decay = 0.1 + frnd(0.2);
    	if( rnd(1) > 0 ) {
    		desc.hpf_freq = frnd(0.3);
    	}
    	if( rnd(1) > 0 ) {
    		desc.lpf_freq = 1.0 - frnd(0.6);
    	}
    	return desc;
    }

    public static function generateBlipSelect() {
        var desc = makeDescriptor();
    	desc.wave_type = rnd(1);
    	if( desc.wave_type == Shape.Square ) {
    		desc.duty = frnd( 0.6 );
    	}
    	desc.base_freq = 0.2 + frnd( 0.4 );
    	desc.env_attack = 0.0;
    	desc.env_sustain = 0.1 + frnd( 0.1 );
    	desc.env_decay = frnd( 0.2 );
    	desc.hpf_freq = 0.1;
    	return desc;
    }

    public static function generateRandom() {
        var desc = makeDescriptor();
    	desc.base_freq = Math.pow(frnd(2.0) - 1.0, 2.0);
    	if (rnd(1)>0) {
    		desc.base_freq = Math.pow(frnd(2.0) - 1.0, 3.0) + 0.5;
    	}
    	desc.freq_limit = 0.0;
    	desc.freq_ramp = Math.pow(frnd(2.0) - 1.0, 5.0);
    	if (desc.base_freq > 0.7 && desc.freq_ramp > 0.2) {
    		desc.freq_ramp = -desc.freq_ramp;
    	}
    	if (desc.base_freq < 0.2 && desc.freq_ramp < -0.05) {
    		desc.freq_ramp = -desc.freq_ramp;
    	}
    	desc.freq_dramp = Math.pow(frnd(2.0) - 1.0, 3.0);
    	desc.duty = frnd(2.0) - 1.0;
    	desc.duty_ramp = Math.pow(frnd(2.0) - 1.0, 3.0);
    	desc.vib_strength = Math.pow(frnd(2.0) - 1.0, 3.0);
    	desc.vib_speed = frnd(2.0) - 1.0;
    	desc.vib_delay = frnd(2.0) - 1.0;
    	desc.env_attack = Math.pow(frnd(2.0) - 1.0, 3.0);
    	desc.env_sustain = Math.pow(frnd(2.0) - 1.0, 2.0);
    	desc.env_decay = frnd(2.0) - 1.0;
    	desc.env_punch = Math.pow(frnd(0.8), 2.0);
    	if (desc.env_attack + desc.env_sustain + desc.env_decay < 0.2) {
    		desc.env_sustain += 0.2 + frnd(0.3);
    		desc.env_decay += 0.2 + frnd(0.3);
    	}
    	desc.lpf_resonance = frnd(2.0) - 1.0;
    	desc.lpf_freq = 1.0 - Math.pow(frnd(1.0), 3.0);
    	desc.lpf_ramp = Math.pow(frnd(2.0) - 1.0, 3.0);
    	if (desc.lpf_freq < 0.1 && desc.lpf_ramp < -0.05) {
    		desc.lpf_ramp = -desc.lpf_ramp;
    	}
    	desc.hpf_freq = Math.pow(frnd(1.0), 5.0);
    	desc.hpf_ramp = Math.pow(frnd(2.0) - 1.0, 5.0);
    	desc.pha_offset = Math.pow(frnd(2.0) - 1.0, 3.0);
    	desc.pha_ramp = Math.pow(frnd(2.0) - 1.0, 3.0);
    	desc.repeat_speed = frnd(2.0) - 1.0;
    	desc.arp_speed = frnd(2.0) - 1.0;
    	desc.arp_mod = frnd(2.0) - 1.0;
    	return desc;
    }

    public static function mutate( base : Params ) {
        var desc = makeDescriptor( base );
    	if( rnd( 1 ) > 0 ) desc.base_freq += frnd(0.1) - 0.05;
    	// if (rnd(1)) desc.freq_limit += frnd(0.1) - 0.05;
    	if( rnd( 1 ) > 0 ) desc.freq_ramp += frnd(0.1) - 0.05;
    	if( rnd( 1 ) > 0 ) desc.freq_dramp += frnd(0.1) - 0.05;
    	if( rnd( 1 ) > 0 ) desc.duty += frnd(0.1) - 0.05;
    	if( rnd( 1 ) > 0 ) desc.duty_ramp += frnd(0.1) - 0.05;
    	if( rnd( 1 ) > 0 ) desc.vib_strength += frnd(0.1) - 0.05;
    	if( rnd( 1 ) > 0 ) desc.vib_speed += frnd(0.1) - 0.05;
    	if( rnd( 1 ) > 0 ) desc.vib_delay += frnd(0.1) - 0.05;
    	if( rnd( 1 ) > 0 ) desc.env_attack += frnd(0.1) - 0.05;
    	if( rnd( 1 ) > 0 ) desc.env_sustain += frnd(0.1) - 0.05;
    	if( rnd( 1 ) > 0 ) desc.env_decay += frnd(0.1) - 0.05;
    	if( rnd( 1 ) > 0 ) desc.env_punch += frnd(0.1) - 0.05;
    	if( rnd( 1 ) > 0 ) desc.lpf_resonance += frnd(0.1) - 0.05;
    	if( rnd( 1 ) > 0 ) desc.lpf_freq += frnd(0.1) - 0.05;
    	if( rnd( 1 ) > 0 ) desc.lpf_ramp += frnd(0.1) - 0.05;
    	if( rnd( 1 ) > 0 ) desc.hpf_freq += frnd(0.1) - 0.05;
    	if( rnd( 1 ) > 0 ) desc.hpf_ramp += frnd(0.1) - 0.05;
    	if( rnd( 1 ) > 0 ) desc.pha_offset += frnd(0.1) - 0.05;
    	if( rnd( 1 ) > 0 ) desc.pha_ramp += frnd(0.1) - 0.05;
    	if( rnd( 1 ) > 0 ) desc.repeat_speed += frnd(0.1) - 0.05;
    	if( rnd( 1 ) > 0 ) desc.arp_speed += frnd(0.1) - 0.05;
    	if( rnd( 1 ) > 0 ) desc.arp_mod += frnd(0.1) - 0.05;
    	return desc;
    }

    public static function makeDescriptor( ?base : Params ) : Params {

        var desc = {

            wave_type: 0,

            base_freq: 0.3,
            freq_limit: 0.0,

    		freq_dramp: 0.0,
    		duty: 0.0,
    		duty_ramp: 0.0,

    		vib_strength: 0.0,
    		vib_speed: 0.0,
    		vib_delay: 0.0,

    		env_attack: 0.0,
    		env_sustain: 0.3,
    		env_decay: 0.4,
    		env_punch: 0.0,

    		lpf_resonance: 0.0,
    		lpf_freq: 1.0,
    		lpf_ramp: 0.0,
    		hpf_freq: 0.0,
    		hpf_ramp: 0.0,

    		pha_offset: 0.0,
    		pha_ramp: 0.0,

    		repeat_speed: 0.0,

    		arp_speed: 0.0,
    		arp_mod: 0.0,

            volume: 0.5
        };

        if( base != null ) {
            for( f in Reflect.fields( base ) ) {
                Reflect.setField( desc, f, Reflect.field( base, f ) );
            }
        }

        return desc;
    }

    static inline function rnd( n : Float ) : Int {
        return Math.floor( Math.random() * (n + 1) );
    }

    static inline function frnd( n : Float ) : Float {
        return Math.random() * n;
    }

    static inline function pick( choices : Array<Any> ) {
        return choices[Math.floor(Math.random() * choices.length)];
    }
}
