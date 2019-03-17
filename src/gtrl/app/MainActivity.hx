package gtrl.app;

import gtrl.Setup;
import gtrl.Setup.SensorSetup;

class MainActivity extends Activity {

	var service : Service;
	var setup : Setup;
	var rooms = new Map<String,RoomView>();

	public function new( service : Service, setup : Setup ) {
		super();
		this.service = service;
		this.setup = setup;
	}

	override function onCreate() {
		for( r in setup ) {
			var view = new RoomView( element, r );
			rooms.set( r.name, view );
		}
	}

	override function onStart() {
		var roomNName = 'BOX';
		return new Promise( function(resolve,reject){
			service.loadSensorData( 1 ).then( function(data){
				trace(data);
				rooms.get( roomNName ).init( data );
				resolve(null);
			});
		});
	}

	override function onResume() {
		service.onDisconnect = function(){
			replace( new gtrl.app.ConnectActivity() );
			//document.body.innerHTML = '';
			//document.body.textContent = 'DISCONNECTED';
				//haxe.Timer.delay( connectService, 1000 );
		}
	}

	override function onPause() {
		service.onDisconnect = null;
	}
}

private class RoomView {

	static var COLORS_TEMPERATURE = [
		'rgba(245, 55, 148, 0.8)',
		'rgba(246, 112, 25, 0.8)',
		'rgba(77, 201, 246, 0.8)',
	];
	static var COLORS_HUMIDITY = [
		'rgba(245, 55, 148, 0.2 )',
		'rgba(246, 112, 25, 0.2 )',
		'rgba(77, 201, 246, 0.2 )',
	];

	var element : DivElement;
	var numSensors : Int;
	var sensors : Map<String,SensorView>;
	var chart : Dynamic;

	public function new( container : Element, setup : RoomSetup ) {

		element = document.createDivElement();
		element.classList.add( 'room' );
		container.appendChild( element );

		numSensors = setup.sensors.length;

		var name = document.createDivElement();
		name.classList.add( 'name' );
		name.textContent = setup.name;
		element.appendChild( name );
	
		var sensorsElement = document.createDivElement();
		sensorsElement.classList.add( 'sensors' );
		element.appendChild( sensorsElement );

		sensors = [];

		for( i in 0...setup.sensors.length ) {
			var sensor = setup.sensors[i];
			var view = new SensorView( sensorsElement, sensor, COLORS_TEMPERATURE[i] );
			view.onActivate = function(active){
				chart.data.datasets[i].hidden = chart.data.datasets[i+numSensors].hidden = !active;
				chart.update();
			}
			sensors.set( sensor.name, view );
		}

		var canvas = document.createCanvasElement();
		canvas.classList.add( 'chart' );
		element.appendChild( canvas );

		var datasets = new Array<Dynamic>();
		for( i in 0...setup.sensors.length ) {
			var sensor = setup.sensors[i];
			datasets.push({
				//type: 'line',
				label: sensor.name,
				yAxisID: 'y-axis-1',
				borderColor: COLORS_TEMPERATURE[i],
				//backgroundColor: 'rgba(100,100,100,0.2)',
				//pointRadius: 2,
				//lineTension: 0,
				//display: false,
				//hidden: true,
				data: [],
				//type: 'bar'
			});
		}

		for( i in 0...setup.sensors.length ) {
			var sensor = setup.sensors[i];
			datasets.push({
				label: sensor.name,
				yAxisID: 'y-axis-2',
				borderColor: COLORS_HUMIDITY[i],
				borderDash: [10,4],
				pointRadius: 0,
				//lineTension: 0,
				data: []
			});
		}

		chart = untyped __js__( "new Chart({0},{1})", canvas.getContext2d(), {
			type: 'line',
			data: {
				labels: [],
				datasets: datasets,
			},
			options: {
				responsive: true,
				tooltips: {
					mode: 'index',
					//intersect: false,
				},
				hover: {
					mode: 'nearest',
					//intersect: true
				},
				elements: {
					line: {
						borderWidth: 2,
						tension: 0.1
						//stepped: true
					},
					point: {
						//backgroundColor:
						pointStyle: 'circle',
						radius: 1
					}
				},
				legend: {
					display: false
				},
				scales: {
					xAxes: [{
						gridLines: {
							display: true
						},
						time: {
							//format: 'MM/DD/YYYY HH:mm',
							parser: 'MM/DD/YYYY HH:mm',
							// round: 'day'
							tooltipFormat: 'll HH:mm',
							//unit: 'month'
						},
						type: 'time',
					}],
					yAxes: [
						{
							type: 'linear',
							id: 'y-axis-1',
							position: 'right',
							display: true,
							scaleLabel: {
								display: true,
								labelString: 'TEMPERATURE'
							},
							/*
							gridLines: {
								display: true,
								drawBorder: true,
								drawOnChartArea: true,
								drawTicks: true,
							}
							*/
							ticks: {
								callback: function(value,index,values){
									return value+'°';
								}
							}
						},
						{
							display: true,
							gridLines: {
								drawOnChartArea: false
							},
							id: 'y-axis-2',
							position: 'left',
							scaleLabel: {
								display: true,
								labelString: 'HUMIDITY'
							},
							ticks: {
								callback: function(value,index,values){
									return value+'%';
								}
							},
							type: 'linear',
						}
					]
				},
			}
		});
	}

	public function init( data : Array<Dynamic> ) {

		for( s in sensors.keys() ) {
			var view = sensors.get( s );
			for( i in 0...data.length ) {
				var index = data.length-1-i;
				if( data[index].sensor == s ) {
					view.update( data[index].time, data[index].temperature, data[index].humidity );
					break;
				}
			}
		}

		for( i in 0...data.length ) {
			var row = data[i];
			chart.data.labels.push( Date.fromTime( row.time ) );
			var j = 0;
			for( key in sensors.keys() ) {
				if( key == row.sensor ) {
					chart.data.datasets[j].data.push( row.temperature );
					chart.data.datasets[j+numSensors].data.push( row.humidity );
				} else {
					var data : Array<Float> = chart.data.datasets[j].data;
					var v = (data.length == 0) ? null : data[data.length-1];
					data.push( v );
					var data : Array<Float> = chart.data.datasets[j+numSensors].data;
					var v = (data.length == 0) ? null : data[data.length-1];
					data.push( v );
				}
				j++;
			}
		}
		chart.update();
	}

	public function update( entry : Dynamic ) {
		
		trace(entry);
		var time = entry.time; //Date.fromTime( data.time );

		var view = sensors.get( entry.sensor.name );
		view.update( time, entry.data.temperature, entry.data.humidity );

		chart.data.labels.push( Date.fromTime( entry.time ) );
		var j = 0;
		for( key in sensors.keys() ) {
			if( key == entry.sensor.name ) {
				//trace(key);
				chart.data.datasets[j].data.push( entry.data.temperature );
				chart.data.datasets[j+numSensors].data.push( entry.data.humidity );
			} else {
				var data : Array<Float> = chart.data.datasets[j].data;
				var v = (data.length == 0) ? null : data[data.length-1];
				data.push( v );
				var data : Array<Float> = chart.data.datasets[j+numSensors].data;
				var v = (data.length == 0) ? null : data[data.length-1];
				data.push( v );
			}
			j++;
		}
		chart.update();	
	}
	
	function getSensorIndex( name : String ) : Int {
		var i = 0;
		for( k in sensors.keys() ) {
			if( k == name )
				return i;
			i++;
		}
		return null;
	}
}

private class SensorView {

	public dynamic function onActivate( active : Bool ) {}
	
	public var active(default,null) = true;

	var element : Element;
	var temperature : Element;
	var humidity : Element;

	public function new( container : Element, setup : SensorSetup, color : String ) {

		element = document.createDivElement();
		element.classList.add( 'sensor' );
		element.style.color = color;
		container.appendChild( element );
		
		/*
		trace(setup.name, setup.enabled,!setup.enabled);
		if( setup.enabled != null && !setup.enabled ) {
			element.classList.add( 'disabled' );
		}
		*/

		var name = document.createElement('h5');
		name.classList.add( 'name' );
		name.textContent = setup.name;
		element.appendChild( name );
		
		var values = document.createElement('h5');
		values.classList.add( 'values' );
		element.appendChild( values );

		temperature = document.createElement('h5');
		temperature.classList.add( 'temperature', 'value' );
		values.appendChild( temperature );

		humidity = document.createElement('h5');
		humidity.classList.add( 'humidity', 'value' );
		values.appendChild( humidity );

		element.addEventListener( 'click', handleClick, false );
	}
	
	public function update( time : Float, temperature : Float, humidity : Float ) {

		//trace(this.temperature.textContent.length==0,temperature);

		if( this.temperature.textContent.length > 0 ) {
			var lastTemperature = Std.parseFloat( this.temperature.textContent );
			var diff = temperature - lastTemperature;
			//trace(temperature,lastTemperature,diff);
		}

		this.temperature.textContent = ''+temperature;
		this.humidity.textContent = ''+Std.int( humidity );

		element.title = Date.fromTime( time ).toString(); //.now().toString();
	}

	function handleClick(e) {
		active = !active;
		if( active ) {
			element.classList.remove( 'inactive' );
		} else {
			element.classList.add( 'inactive' );
		}
		onActivate( active );
	}
}
