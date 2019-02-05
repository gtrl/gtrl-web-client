package gtrl.web;

import js.html.WebSocket as Socket;

class Service {

	public dynamic function onData( data : Dynamic ) {}

	public var host(default,null) : String;
	public var port(default,null) : Int;

	var socket : Socket;
	var url : String;

	public function new( host : String, port : Int ) {
		this.host = host;
		this.port = port;
		url = 'http://$host:$port';
	}

	public function connect( callback : ?Error->Void ) {
		socket = new Socket( 'ws://$host:$port' );
		socket.onopen = function(e) {
			console.debug( e );
			callback();
		}
		socket.onerror = function(e) {
			console.error(e);
		}
		socket.onclose = function(e) {
			console.debug(e);
		}
		socket.onmessage = function(e) {
			//trace(e);
			onData( Json.parse( e.data ) );
		}
	}

	public function disconnect() {
		socket.close();
	}

	public function loadSetup() : Promise<gtrl.Setup> {
		return fetch( 'setup' );
	}

	public function loadData( ?numDays : Int ) : Promise<Array<gtrl.db.Entry>> {
		var now = Date.now();
		var days = now.getDate();
		if( numDays != null ) days -= numDays;
		var date = new Date( now.getFullYear(), now.getMonth(), days, now.getHours(), now.getMinutes(), now.getSeconds() );
		return fetch( 'data', { time : date.getTime() } );
	}

	function fetch<T>( path : String, ?data : Dynamic ) : Promise<T> {
		return FetchTools.fetchJson( '$url/$path', {
			method: (data == null) ? "GET" : "POST",
			body: (data == null) ? null : Json.stringify( data )
		} );
	}

}
