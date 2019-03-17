package gtrl.app;

class ConnectActivity extends Activity {

	var status : Element;
	var timer : Timer;

	override function onCreate() {
		status = document.createDivElement();
		element.appendChild( status );
	}

	override function onResume() {
		connectService();
	}
	
	override function onPause() {
		if( timer != null ) {
			timer.stop();
			timer = null;
		}
	}

	function connectService() {

		status.textContent = 'connecting';

		var service = new gtrl.app.Service( '192.168.0.200', 9000 );

		service.connect().then( function(setup) {

			if( timer != null ) {
				timer.stop();
				timer = null;
			}

			status.textContent = 'connected';

			replace( new MainActivity( service, setup ) );
			//replace( new RawDataActivity( service, setup ) );

		}).catchError( function(e){
			trace(e);
			status.textContent = 'failed to connect';
			timer = new Timer( 1000 );
			timer.run = function(){
				timer.stop();
				connectService();
			}
		});

	}
}