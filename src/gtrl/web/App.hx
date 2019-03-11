package gtrl.web;

import gtrl.web.gui.RoomView;

class App {

	public static var service(default,null) : Service;

	static function connectService() {

		service.connect().then( function(setup){

			document.body.innerHTML = '';
			
			var rooms = new Map<String,RoomView>();
			
			var roomsElement = document.createDivElement();
			document.body.appendChild( roomsElement );
			
			for( r in setup ) {
				var view = new RoomView( roomsElement );
				rooms.set( r.name, view );
				view.init( r );
			}

			service.onData = function(data){
				rooms.get( data.room ).update( data );
			}
			service.onDisconnect = function(){
				document.body.innerHTML = '';
				document.body.textContent = 'DISCONNECTED';
				//haxe.Timer.delay( connectService, 1000 );
			}

		}).catchError( function(e){
			document.body.innerHTML = '';
			document.body.textContent = e;
			//haxe.Timer.delay( connectService, 1000 );
		});
	}

	static function main() {

		console.info( 'GTRL' );

		service = new Service( '192.168.0.200', 9000 );
		connectService();
	}
}