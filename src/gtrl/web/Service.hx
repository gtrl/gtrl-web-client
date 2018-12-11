package gtrl.web;

import js.html.WebSocket as Socket;

class Service {

	public dynamic function onData( data : Dynamic ) {}

	public var host(default,null) : String;
	public var port(default,null) : Int;

	var socket : Socket;

	public function new( host : String, port : Int ) {
		this.host = host;
		this.port = port;
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

	public function loadData() : Promise<Dynamic> {
		//var now = Date.now();
		//var date = new Date( now.getFullYear(), now.getMonth(), now.getDate(), now.getHours(), now.getMinutes(), now.getSeconds() );
		//return fetchData( 'data', { time : date.getTime() } );
		return fetchData( 'data' );
	}

	function fetchData( ?path : String, ?data : Dynamic ) : Promise<Dynamic> {
		var url = 'http://$host:$port';
		if( path != null ) url += '/$path';
		return window.fetch( url, {
			method: (data == null) ? "GET" : "POST",
			body: (data == null) ? null : Json.stringify( data )
		} ).then( r -> return r.json() );
	}

}
