package gtrl.web;

class App {

	static inline var HOST = '192.168.0.241';
	static inline var PORT = 9000;

	static function fetchData() {
		return window.fetch( 'http://$HOST:$PORT' );
	}

	static function fetchJson() {
		return fetchData().then( r -> return r.json() );
	}

	static function main() {
		/*
		window.onload = function(){
			fetchJson().then( function(data:Array<Dynamic>){
				trace( data.length );

				for( i in 0...data.length ) {
					var d = data[i];
					var e = document.createDivElement();
					e.textContent = i+' '+' '+d.sensor+' '+d.time+' '+d.temperature+' '+d.humidity;
					document.body.appendChild( e );
				}

				//var ctx = document.getElementById('canvas').getContext('2d');
				//printChart();
			});
		}
		*/
	}
}
