package gtrl.web.gui;

import gtrl.Setup.RoomSetup;
import gtrl.Setup.SensorSetup;

class RoomView {

	static var COLORS = [
		'rgba(255,255,255,0.8)',
		'rgba(255,0,0,0.8)',
		'rgba(255,255,0,1)'
		/*
		{ border: 'rgba(255,255,255,0.8)', background: 'rgba(255,255,255,0.1)' },
		{ border: 'rgba(255,0,0,0.8)', background: 'rgba(255,0,0,0.1)' },
		{ border: 'rgba(255,255,0,1)', background: 'rgba(0,0,0,0.2)' }
		*/
	];

	var element : DivElement;
	var sensors : Map<String,SensorView>;
	var chartTemperature : Dynamic;
	var chartHumidity : Dynamic;

	public function new( container : Element ) {
		element = document.createDivElement();
		element.classList.add( 'room' );
		container.appendChild( element );
	}

	public function init( setup : RoomSetup ) {

		var name = document.createDivElement();
		name.classList.add( 'name' );
		name.textContent = setup.name;
		element.appendChild( name );
	
		var sensorsElement = document.createDivElement();
		sensorsElement.classList.add( 'sensors' );
		element.appendChild( sensorsElement );

		sensors = [];

		//function randValue() : Float return 20 + Math.random()*5;

		var canvasTemperature = document.createCanvasElement();
		canvasTemperature.height = 100;
		canvasTemperature.classList.add( 'chart' );
		element.appendChild( canvasTemperature );

		chartTemperature = untyped __js__( "new Chart({0},{1})", canvasTemperature.getContext2d(), {
			type: 'line',
			data: {
				labels: [],
				datasets: [for( i in 0...setup.sensors.length ) {
					var sensor = setup.sensors[i];
					{
						label: sensor.name,
						//borderColor: 'rgba('+int( Math.random()*255 )+','+int( Math.random()*255 )+','+int( Math.random()*255 )+',0.8)',
						borderColor: COLORS[i],
						data: []
					};
				}],
			},
			options: {
				responsive: true,
				title: {
					display: true,
					text: 'TEMPERATURE'
				},
				tooltips: {
					mode: 'index',
					//intersect: false,
				},
				/*
				hover: {
					mode: 'nearest',
					//intersect: true
				},
				*/
				/*
				scales: {
					xAxes: [{
						type: 'time'
					}],
					yAxes: [{
						display: true,
						scaleLabel: {
							//display: true,
							//labelString: 'TEMPERATURE'
						}
					}]
				}
				*/
				scales: {
					xAxes: [{
						type: 'time',
						display: true,
						time: {
							format: 'MM/DD/YYYY HH:mm',
							// round: 'day'
						}
					}],
				},
			}
		} );

		var canvasHumidity = document.createCanvasElement();
		canvasHumidity.classList.add( 'chart' );
		canvasHumidity.height = 100;
		element.appendChild( canvasHumidity );

		chartHumidity = untyped __js__( "new Chart({0},{1})", canvasHumidity.getContext2d(), {
			type: 'line',
			data: {
				labels: [],
				datasets: [for( i in 0...setup.sensors.length ) {
					var sensor = setup.sensors[i];
					{
						label: sensor.name,
						//borderColor: 'rgba('+int( Math.random()*255 )+','+int( Math.random()*255 )+','+int( Math.random()*255 )+',0.8)',
						borderColor: COLORS[i],
						data: []
					};
				}],
			},
			options: {
				responsive: true,
				title: {
					display: true,
					text: 'HUMIDITY'
				},
				tooltips: {
					mode: 'index',
				},
				/*
				scales: {
					xAxes: [{
						type: 'time',
						time: {
							format: 'MM/DD/YYYY HH:mm',
							// round: 'day'
							tooltipFormat: 'll HH:mm'
						},
						scaleLabel: {
							display: true,
							labelString: 'Date'
						}
					}],
					yAxes: [{
						display: true,
						labelString: 'value'
					}]
				}
				*/
				scales: {
					xAxes: [{
						type: 'time',
						time: {
							format: 'MM/DD/YYYY HH:mm',
							// round: 'day'
							tooltipFormat: 'll HH:mm'
						}
					}],
					yAxes: [{
						scaleLabel: {
							display: true,
							labelString: 'value'
						}
					}]
				}
			}
		} );

		
		for( i in 0...setup.sensors.length ) {

			var sensor = setup.sensors[i];

			var view = new SensorView( sensorsElement, sensor, COLORS[i] );
			sensors.set( sensor.name, view );

			/*
			App.service.loadSensorData( sensor.name, 1 ).then( function(data){

				var last = data[data.length-1];
				var view = sensors.get( last.sensor );
				view.update( last.temperature, last.humidity );

				//trace(chart.data.datasets[1]);
				for( row in data ) {
					//trace(row.time);
					//chart.data.labels.push( row.time );
					chartTemperature.data.labels.push( row.time );
					//chart.data.datasets[i].data.push( row.temperature );
					chartTemperature.data.datasets[getSensorIndex( sensor.name )].data.push( row.temperature );
					/*
					if( i > 0 && chart.data.labels.length > 2 ) {

					}
					* /

					chartHumidity.data.labels.push( row.time );
					chartHumidity.data.datasets[getSensorIndex( sensor.name )].data.push( row.humidity );

				}
				chartTemperature.update();
				chartHumidity.update();
			});
			*/
			
		}

		App.service.loadSensorData( 1 ).then( function(data){
		
			for( i in 0...setup.sensors.length ) {
				var sensor = setup.sensors[i];
				var view = sensors.get( sensor.name );
				for( i in 0...data.length ) {
					if( data[data.length-1-i].sensor == sensor.name ) {
						view.update( data[i].temperature, data[i].humidity );
						break;
					}
				}
			}

			var i = 0;
			for( row in data ) {

				chartTemperature.data.labels.push( Date.fromTime( row.time ) );
				chartTemperature.data.datasets[getSensorIndex( row.sensor )].data.push( row.temperature );
				//chartTemperature.data.datasets[getSensorIndex( row.sensor )].data.push( {x:row.temperature,y:row.humidity} );

				chartHumidity.data.labels.push( Date.fromTime( row.time ) );
				chartHumidity.data.datasets[getSensorIndex( row.sensor )].data.push( row.humidity );

				//if( i > 0 ) trace( row.time> data[i-1].time, row.sensor );
				i++;
			}
			chartTemperature.update();
			chartHumidity.update();
		});

				
					/*
		App.service.loadSensorData( 1 ).then( function(data){
				trace(data);
				
				for( row in data ) {
					trace(row);
					//trace(getSensorIndex( row.sensor ));
					//trace(chart.data.datasets[getSensorIndex( row.sensor.name )]);
					chart.data.labels.push( row.time );
					//chart.data.labels.push( row.time );
					chart.data.datasets[getSensorIndex( row.sensor )].data.push( row.temperature );
				}
				
				chart.update();


				//trace(chart.data.datasets[1]);
				for( row in data ) {
					trace(row.time);
					//chart.data.labels.push( row.time );
					chart.data.labels.push( row.time );
					chart.data.datasets[i].data.push( row.temperature );
					if( i > 0 && chart.data.labels.length > 2 ) {

					}
				}
				chart.update();
		});

					*/
	}

	public function update( data : Dynamic ) {

		var view = sensors.get( data.sensor.name );
		view.update( data.data.temperature, data.data.humidity );

		chartTemperature.data.labels.push( Date.fromTime( data.time ) );
		chartTemperature.data.datasets[getSensorIndex( data.sensor.name )].data.push( data.data.temperature );
		chartTemperature.update();

		chartHumidity.data.labels.push( Date.fromTime( data.time ) );
		chartHumidity.data.datasets[getSensorIndex( data.sensor.name )].data.push( data.data.humidity );
		chartHumidity.update();

		/*
		trace(data);

		var time = data.time; //Date.now().getTime();

		chartTemperature.data.labels.push( time );
		chartTemperature.data.datasets[getSensorIndex( data.sensor.name )].data.push( data.data.temperature );
		chartTemperature.update();

		chartHumidity.data.labels.push( time );
		chartHumidity.data.datasets[getSensorIndex( data.sensor.name )].data.push( data.data.humidity );
		chartHumidity.update();
		*/

		/*
		//chart.data.labels.push( data.time );
		for( i in 0...chart.data.labels.length ) {
			//trace(Std.is( chart.data.labels[i], Float));
		//trace( cast( chart.data.labels[i], Float ) < data.time );
			//trace( cast( chart.data.labels[i], Float ), data.time, cast( chart.data.labels[i], Float ) < data.time );
			/*
			if( chart.data.labels[i] < data.time ) {
				chart.data.labels.insert( i, data.time );
				break;
			}
		}
			*/

		//var sensorIndex = getSensorIndex( data.sensor.name );
		
		//chart.data.labels.shift();
		//chart.data.datasets[getSensorIndex( data.sensor.name )].data.shift();

	

			/*
		for( i in 0...chart.data.datasets.length ) {
			var dataset = chart.data.datasets[i];
			if( i == sensorIndex ) {
				dataset.data.push( data.data.temperature );
			} else {
				dataset.data.push( data.data[Std.int(data.data.length-1)] );
			}
		}
		*/
		
		//chart.data.datasets[getSensorIndex( data.sensor.name )].data.push( data.data.temperature );

	}

	function getSensorIndex( name : String ) : Int {
		//for( i in 0...sensors.length ) if( sensors[i] == name ) return i;
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
	
	public var active(default,null) = false;

	var element : Element;
	var temperature : Element;
	var humidity : Element;

	public function new( container : Element, setup : SensorSetup, color : String ) {

		element = document.createDivElement();
		element.classList.add( 'sensor' );
		element.style.color = color;
		container.appendChild( element );

		var name = document.createDivElement();
		name.classList.add( 'name' );
		name.textContent = setup.name;
		element.appendChild( name );
		
		var values = document.createDivElement();
		values.classList.add( 'values' );
		element.appendChild( values );

		temperature = document.createDivElement();
		temperature.classList.add( 'temperature', 'value' );
		values.appendChild( temperature );

		humidity = document.createDivElement();
		humidity.classList.add( 'humidity', 'value' );
		values.appendChild( humidity );

		element.addEventListener( 'click', handleClick, false );
	}
	
	public function update( temperature : Float, humidity : Float ) {

		//trace(this.temperature.textContent.length==0,temperature);

		if( this.temperature.textContent.length > 0 ) {
			var lastTemperature = Std.parseFloat( this.temperature.textContent );
			var diff = temperature - lastTemperature;
			//trace(temperature,lastTemperature,diff);
		}

		this.temperature.textContent = ''+temperature;
		this.humidity.textContent = ''+humidity;
	}

	function handleClick(e) {
		if( active ) {
			active = false;
			element.classList.remove( 'active' );
		} else {
			active = true;
			element.classList.add( 'active' );
		}
		onActivate( active );
	}
}