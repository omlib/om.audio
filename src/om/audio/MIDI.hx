package om.audio;

/**
    Musical Instrument Digital Interface.

    Communications protocol that allows a wide variety of electronic musical instruments, computers and other related music and audio devices to connect and communicate with one another.
**/
class MIDI {

    /**
        MIDI Tuning Standard (MTS) is a specification of precise musical pitch agreed to by the MIDI Manufacturers Association in the MIDI protocol.
        MTS allows for both a bulk tuning dump message, giving a tuning for each of 128 notes, and a tuning message for individual notes as they are played.

        The quantity `log2 (ƒ / 440 Hz)` is the number of octaves above the 440-Hz concert A (it is negative if the frequency is below that pitch).
        Multiplying it by 12 gives the number of semitones above that frequency.
        Adding 69 gives the number of semitones above the C five octaves below middle C.
    */
    public static function noteToFrequency( note : Int, tune = 440 ) : Float {
        return (note >= 0 && note < 128) ? Math.pow( 2, (note - 69) / 12) * tune : null;
    }

}
