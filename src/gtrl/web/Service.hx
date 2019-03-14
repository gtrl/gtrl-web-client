package gtrl.web;

import js.html.WebSocket as Socket;

class Service {

	public dynamic function onDisconnect() {}
	public dynamic function onData( data : Dynamic ) {}

	public var host(default,null) : String;
	public var port(default,null) : Int;

	var socket : Socket;

	public function new( host : String, port : Int ) {
		this.host = host;
		this.port = port;
	}

	public function connect() : Promise<Setup> {
		return new Promise( function(resolve,reject){
			socket = new Socket( 'ws://$host:$port' );
			socket.onopen = function(e) {
				return fetch( 'setup' ).then( function(r){
					return resolve(r);
				});
			}
			socket.onclose = function(e) {
				reject( e.message );
				onDisconnect();
			}
			socket.onmessage = function(e) {
				onData( Json.parse( e.data ) );
			}
		});
	}

	public function loadSensorData( ?sensor : String, ?numDays = 1 ) : Promise<Array<gtrl.db.Entry>> {
		var now = Date.now();
		var days = now.getDate();
		if( numDays != null ) days -= numDays;
		var date = new Date( now.getFullYear(), now.getMonth(), days, now.getHours(), now.getMinutes(), now.getSeconds() );
		var filter : Dynamic = { sensor: sensor, time : date.getTime() };
		return fetch( 'data', filter );
	}

	function fetch<T>( path : String, ?data : Dynamic ) : Promise<T> {
		return FetchTools.fetchJson( 'http://$host:$port/$path', {
			method: (data == null) ? "GET" : "POST",
			body: (data == null) ? null : Json.stringify( data )
		} );
	}
	
}
