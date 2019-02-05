package gtrl.web;

import gtrl.web.ui.ChartView;
import gtrl.web.ui.SettingsView;

class App {

	//static inline var HOST = '192.168.0.10';
	static inline var HOST = '192.168.0.200';
	static inline var PORT = 9000;

	static var service : Service;

	static var status : DivElement;
	static var chart : ChartView;
	static var settings : SettingsView;
	static var reload : ButtonElement;
	static var realtime : DivElement;

	static function reloadData() {
		var daysElement = cast document.querySelector( 'input[name=days]' );
		var days = Std.parseInt( daysElement.value );
		reload.style.display = 'none';
		status.textContent = 'loading data';
		chart.clear();
		service.loadData( days ).then( function(data){
			reload.style.display = 'block';
			status.textContent = '';
			chart.print( data );
		}).catchError( function(e){
			console.error(e);
		});
	}

	static function main() {

		settings = new SettingsView( document.getElementById('settings') );
		reload = cast document.getElementById( 'reload' );
		chart = new ChartView( cast document.getElementById('chart') );
		status = cast document.getElementById( 'status' );
		realtime = cast document.getElementById( 'realtime' );

		service = new Service( HOST, PORT );
		
		service.loadSetup().then( function(setup){

			trace(setup);
			//TODO

			status.textContent = 'Connecting to ${service.host}:${service.port}';

			service.connect( function(?e){
				if( e != null ) {
					trace(e);
					status.textContent = 'Failed to connect to service ${service.host}:${service.port}';
				} else {
					reload.style.display = 'block';
					//status.textContent = '';
					reload.onclick = function(){
						reloadData();
					}
					reloadData();
				}
			});

			service.onData = function(data){
				//trace(data);
				var time = Date.fromTime( data.time );
				var e = document.createDivElement();
				e.textContent = DateTools.format( time, "%H:%M:%S" )+' '+data.room+':'+data.sensor.name+' '+data.data.temperature+' '+data.data.humidity;
				if( realtime.children.length == 0 ) {
					realtime.appendChild( e );
				} else {
					realtime.insertBefore( e, realtime.firstChild );
					if( realtime.children.length > 50 ) {
						realtime.removeChild( realtime.lastChild );
					}
				}
			}
		});
	}
}
