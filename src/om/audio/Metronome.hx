package om.audio;

import js.html.audio.AudioContext;
import om.Worker;

typedef Note = {
    var note : Float;
    var time : Float;
}

/**
    Rock-Solid Timing by looking ahead.

    http://www.html5rocks.com/en/tutorials/audio/scheduling/
*/
class Metronome {

    public static inline var WORKER_MSG_START = 0;
    public static inline var WORKER_MSG_STOP = 1;
    public static inline var WORKER_MSG_TICK = 2;

	public dynamic function onTick( n : Int, time : Float ) {}

    public var isPlaying(default,null) : Bool;
    public var tempo : Float; // BPM
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

        worker = Worker.fromScript( 'var timerID=null;
        var interval=100;
        const WORKER_MSG_START=0;
        const WORKER_MSG_STOP=1;
        const WORKER_MSG_TICK=2;
        self.onmessage=function(e){
        	if(e.data==WORKER_MSG_START){
        		timerID = setInterval(function(){postMessage(WORKER_MSG_TICK);},interval)
            } else if(e.data==WORKER_MSG_STOP){
                clearInterval(timerID);
                timerID=null;
        	} else if(e.data.interval){
        		interval=e.data.interval;
        		if(timerID){
        			clearInterval(timerID);
        			timerID=setInterval(function(){postMessage(WORKER_MSG_TICK);},interval);
        		}
            }
        };
' );
        worker.onmessage = function(e) {
            if( e.data == WORKER_MSG_TICK )
                scheduler();
            //else trace( "message: " + e.data );
        }
        worker.postMessage( { interval:lookahead }, [] );
    }

    public function start() {
        current16thNote = 0;
        nextNoteTime = context.currentTime;
        worker.postMessage( WORKER_MSG_START, [] );
        isPlaying = true;
    }

    public function stop() {
        worker.postMessage( WORKER_MSG_STOP, [] );
        isPlaying = false;
    }

	public function dispose() {
		if( isPlaying ) stop();
		if( worker != null ) worker.terminate();
	}

    function scheduleNote( beatNumber : Int, time : Float ) {

        notesInQueue.push( { note: beatNumber, time: time } );

        if( noteResolution == 1 && beatNumber % 2 == 0 )
            return; // do not play non-8th 16th notes
        if( noteResolution == 2 && beatNumber % 4 == 0 )
            return; // do not play non-quarter 8th notes

		onTick( beatNumber, time );
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
