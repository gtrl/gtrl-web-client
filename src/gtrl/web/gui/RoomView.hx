package gtrl.web.gui;

import gtrl.Setup.RoomSetup;
import gtrl.Setup.SensorSetup;

class RoomView {

	static var COLORS_TEMPERATURE = [
		'rgba(245, 55, 148, 1 )',
		'rgba(246, 112, 25, 1 )',
		'rgba(77, 201, 246, 1 )',
	];
	static var COLORS_HUMIDITY = [
		'rgba(245, 55, 148, 0.2 )',
		'rgba(246, 112, 25, 0.2 )',
		'rgba(77, 201, 246, 0.2 )',
	];

	var element : DivElement;
	var sensors : Map<String,SensorView>;
	var chart : Dynamic;

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

		for( i in 0...setup.sensors.length ) {
			var sensor = setup.sensors[i];
			var view = new SensorView( sensorsElement, sensor, COLORS_TEMPERATURE[i] );
			sensors.set( sensor.name, view );
		}

		var canvasTemperature = document.createCanvasElement();
		element.appendChild( canvasTemperature );

		var datasets = new Array<Dynamic>();
		for( i in 0...setup.sensors.length ) {
			var sensor = setup.sensors[i];
			datasets.push({
				label: sensor.name,
				yAxisID: 'y-axis-1',
				borderColor: COLORS_TEMPERATURE[i],
				//backgroundColor: COLORS_HUMIDITY[i],
				pointRadius: 2,
				lineTension: 0,
				data: []
			});
		}
		for( i in 0...setup.sensors.length ) {
			var sensor = setup.sensors[i];
			datasets.push({
				label: sensor.name,
				yAxisID: 'y-axis-2',
				borderColor: COLORS_HUMIDITY[i],
				borderDash: [2,2],
				pointRadius: 0,
				lineTension: 0,
				data: []
			});
		}

		chart = untyped __js__( "new Chart({0},{1})", canvasTemperature.getContext2d(), {
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
						tension: 0.000001
					},
					point: {
						pointStyle: 'circle'
					}
				},
				scales: {
					xAxes: [{
						type: 'time',
						time: {
							format: 'MM/DD/YYYY HH:mm',
							// round: 'day'
							tooltipFormat: 'll HH:mm'
						}
					}],
					yAxes: [
						{
							type: 'linear',
							id: 'y-axis-1',
							position: 'left',
							display: true,
							scaleLabel: {
								display: true,
								labelString: 'TEMPERATURE'
							}
						},
						{
							type: 'linear',
							id: 'y-axis-2',
							position: 'right',
							display: true,
							scaleLabel: {
								display: true,
								labelString: 'HUMIDITY'
							},
							gridLines: {
								drawOnChartArea: false
							}
						}
					]
				},
			}
		});

		App.service.loadSensorData( 1 ).then( function(data){

			
			for( i in 0...setup.sensors.length ) {
				var sensor = setup.sensors[i];
				trace(sensor.name);
				var view = sensors.get( sensor.name );
				for( i in 0...data.length ) {
					var index = data.length-1-i;
					if( data[index].sensor == sensor.name ) {
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
						chart.data.datasets[j+setup.sensors.length].data.push( row.humidity );
					} else {
						
						var data : Array<Float> = chart.data.datasets[j].data;
						var v = (data.length == 0) ? 20 : data[data.length-1];
						data.push( v );

						var data : Array<Float> = chart.data.datasets[j+setup.sensors.length].data;
						var v = (data.length == 0) ? 50 : data[data.length-1];
						data.push( v );
					}
					j++;
				}
			}

			chart.update();
		});
	}

	public function update( data : Dynamic ) {
		
		var time = data.time; //Date.fromTime( data.time );
		//trace(time);

		var view = sensors.get( data.sensor.name );
		view.update( data.time, data.data.temperature, data.data.humidity );

		//TODO

		/*
		chartTemperature.data.labels.push( time );
		chartTemperature.data.datasets[getSensorIndex( data.sensor.name )].data.push( data.data.temperature );
		chartTemperature.update();

		chartHumidity.data.labels.push( time );
		chartHumidity.data.datasets[getSensorIndex( data.sensor.name )].data.push( data.data.humidity );
		chartHumidity.update();
		*/

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

	/*
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
	*/
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
		
		/*
		trace(setup.name, setup.enabled,!setup.enabled);
		if( setup.enabled != null && !setup.enabled ) {
			element.classList.add( 'disabled' );
		}
		*/

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