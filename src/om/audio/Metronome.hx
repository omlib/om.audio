package om.audio;

import js.html.Worker;
import js.html.audio.AudioContext;

typedef Note = {
    var note : Float;
    var time : Float;
}

/**
    http://www.html5rocks.com/en/tutorials/audio/scheduling/
*/
class Metronome {

    static inline var WORKER_MSG_START = 0;
    static inline var WORKER_MSG_STOP = 1;
    static inline var WORKER_MSG_TICK = 2;

    public var tempo : Float; // BPM
    public var isPlaying(default,null) : Bool;
    public var scheduleAheadTime = 0.1;
    public var noteLength = 0.05;
    public var noteResolution = 0;
    public var notesInQueue : Array<Note>;
    public var context : AudioContext;

    var worker : Worker;
    var lookahead : Float;
    var startTime : Float;
    var current16thNote : Int;
    var nextNoteTime : Float;

    public function new( context : AudioContext, tempo : Float,
                         scheduleAheadTime = 0.1, noteLength = 0.05, lookahead = 25.0 ) {

        this.context = context;
        this.tempo = tempo;
        this.scheduleAheadTime = scheduleAheadTime;
        this.noteLength = noteLength;
        this.lookahead = lookahead;

        isPlaying = false;
        notesInQueue = [];
        nextNoteTime = 0.0;

        worker = new Worker( "metronomeworker.js" );
        worker.onmessage = function(e) {
            if( e.data == WORKER_MSG_TICK ) {
                scheduler();
            } else
                trace( "message: " + e.data );
        }
        worker.postMessage( { interval:lookahead } );
    }

    public function play() {
        current16thNote = 0;
        nextNoteTime = context.currentTime;
        worker.postMessage( WORKER_MSG_START );
        isPlaying = true;
    }

    public function stop() {
        worker.postMessage( WORKER_MSG_STOP );
        isPlaying = false;
    }

    function scheduleNote( beatNumber : Int, time : Float ) {

        notesInQueue.push( { note: beatNumber, time: time } );

        if( noteResolution == 1 && beatNumber % 2 == 0 )
            return; // we're not playing non-8th 16th notes
        if( noteResolution == 2 && beatNumber % 4 == 0 )
            return; // we're not playing non-quarter 8th notes

        var osc = context.createOscillator();
        osc.connect( context.destination );
        osc.frequency.value = 0;
        if( beatNumber % 16 == 0 ) // beat 0
            osc.frequency.value = 1760.0;
        else if( beatNumber % 4 == 0 ) // quarter notes
            osc.frequency.value = 880.0;
        else // other 16th notes = high pitch
            osc.frequency.value = 440.0;
        osc.start( time );
        osc.stop( time + noteLength );
    }

    function nextNote() {
        var secondsPerBeat = 60.0 / tempo;
        nextNoteTime += 0.25 * secondsPerBeat;
        if( ++current16thNote == 16 ) current16thNote = 0;
    }

    function scheduler() {
        while( nextNoteTime < context.currentTime + scheduleAheadTime ) {
            scheduleNote( current16thNote, nextNoteTime );
            nextNote();
        }
    }
}
