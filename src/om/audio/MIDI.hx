package om.audio;

/**
    Musical Instrument Digital Interface.

    MIDI Tuning Standard (MTS) is a specification of precise musical pitch agreed to by the MIDI Manufacturers Association in the MIDI protocol.
    MTS allows for both a bulk tuning dump message, giving a tuning for each of 128 notes, and a tuning message for individual notes as they are played.
**/
class MIDI {

    /**
    */
    public static function keyCodeToNote( code : Int ) : Int {
        var note = '1234567890qwertyuiopasdfghjklzxcvbnm'.indexOf( String.fromCharCode( code ).toLowerCase() ) % 18;
        if( note < 0 ) note = code % 18;
        return note;
    }

    /**
        Get the pitch frequency in hz (with custom concert tuning) from a midi number.

        The quantity `log2 (ƒ / 440 Hz)` is the number of octaves above the 440-Hz concert A (it is negative if the frequency is below that pitch).
        Multiplying it by 12 gives the number of semitones above that frequency.
        Adding 69 gives the number of semitones above the C five octaves below middle C.

        `MIDI.noteToFrequency(69); // 440`
    */
    public static function noteToFrequency( note : Int, tune = 440 ) : Float {
        return (note >= 0 && note < 128) ? Math.pow( 2, (note - 69) / 12) * tune : null;
    }

}
