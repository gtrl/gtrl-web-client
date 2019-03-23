package gtrl.app;

class ConnectActivity extends Activity {

	var host : String;
	var port : Int;
	var status : Element;
	var timer : Timer;

	public function new( host : String, port : Int ) {
		super();
		this.host = host;
		this.port = port;
	}

	override function onCreate() {
		status = document.createDivElement();
		status.classList.add( 'status' );
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

		status.textContent = 'connecting $host:$port';

		var service = new gtrl.app.Service( host, port );

		//TODO:: service.onDisconnect

		service.connect().then( function(setup) {

			if( timer != null ) {
				timer.stop();
				timer = null;
			}

			//eplace( new SetupActivity( service, setup ) );

			status.textContent = 'loading data';

			service.loadDataForDays( 1 ).then( function(data){
				//replace( new LoadDataActivity( service, setup ) );
				//replace( new SetupActivity( service, setup ) );
				//replace( new RawDataActivity( service, setup ) );
				replace( new MainActivity( service, setup, data ) );
				//replace( new SetupActivity( service, setup ) );
			});

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