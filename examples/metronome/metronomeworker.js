
var timerID = null;
var interval = 100;

const WORKER_MSG_START = 0;
const WORKER_MSG_STOP = 1;
const WORKER_MSG_TICK = 2;

self.onmessage = function(e){
	if( e.data == WORKER_MSG_START ) {
		//console.log( "starting" );
		timerID = setInterval( function() { postMessage(WORKER_MSG_TICK); }, interval )
    } else if( e.data == WORKER_MSG_STOP ) {
        //console.log( "stopping" );
        clearInterval( timerID );
        timerID = null;
	} else if( e.data.interval ) {
		//console.log("setting interval");
		interval = e.data.interval;
		//console.log( "interval="+interval );
		if( timerID ) {
			clearInterval( timerID );
			timerID = setInterval(function(){postMessage(WORKER_MSG_TICK);},interval);
		}
    }
};

//postMessage('hi there');
