package gtrl.app;

import gtrl.Setup;
import gtrl.Setup.SensorSetup;

class MainActivity extends Activity {

	var service : Service;
	var setup : Setup;
	var data : Array<Dynamic>;
	var rooms = new Map<String,RoomView>();

	public function new( service : Service, setup : Setup, data : Array<Dynamic> ) {
		super();
		this.service = service;
		this.setup = setup;
		this.data = data;
	}

	override function onCreate() {
		
		//var last = data[data.length-1];
		//document.title = 'MID '+data.temperature+'° '+data.humidity+'%';

		for( r in setup ) {
			var view = new RoomView( element, r );
			rooms.set( r.name, view );
		}

		var meta = document.createElement( 'aside' );
		meta.classList.add( 'meta' );
		
		

		var sync = document.createElement('i');
		sync.classList.add( 'fas', 'fa-sync' );
		meta.appendChild( sync );

		/*
		var syncWeek = document.createButtonElement();
		syncWeek.classList.add( 'week' );
		syncWeek.textContent = 'week';
		meta.appendChild( syncWeek ); */
		
		/*
		var cam = document.createElement('i');
		cam.classList.add( 'fas', 'fa-video' );
		cam.onclick = function() push( new CameraActivity() ); //TODO
		meta.appendChild( cam );
		*/

		var settings = document.createElement('i');
		settings.classList.add( 'fas', 'fa-cog' );
		meta.appendChild( settings );
		
		/*
		var database = document.createElement('i');
		database.classList.add( 'fas', 'fa-database' );
		meta.appendChild( database );
		*/

		var timeDay = document.createButtonElement();
		timeDay.textContent = 'day';
		timeDay.classList.add( 'day' );
		meta.appendChild( timeDay );
		
		var timeWeek = document.createButtonElement();
		timeWeek.textContent = 'week';
		timeWeek.classList.add( 'week' );
		meta.appendChild( timeWeek );
	
		var timeMonth = document.createButtonElement();
		timeMonth.textContent = 'month';
		timeMonth.classList.add( 'month' );
		meta.appendChild( timeMonth );
	
		var timeGrow = document.createButtonElement();
		timeGrow.textContent = 'grow';
		timeGrow.classList.add( 'grow' );
		meta.appendChild( timeGrow );
		
		element.appendChild( meta );

		/*
		var camera = document.createImageElement();
		camera.classList.add( 'camera' );
		camera.src = 'http://192.168.0.200:8000/stream.mjpg';
		element.appendChild( camera );
		*/
		
	}

	override function onResume() {

		var roomNName = 'BOX'; //TODO
		rooms.get( roomNName ).init( data );

		service.onDisconnect = function(){
			replace( new gtrl.app.ConnectActivity( Service.HOST, Service.PORT ) );
		}
		service.onData = function(entry){
			trace(entry);
			if( entry.sensor.name == 'TOP' )
				document.title = 'TOP '+entry.data.temperature+'° '+entry.data.humidity+'%';
			rooms.get( entry.room ).update( entry );
		}

		document.querySelector( 'i.fa-sync' ).onclick = function(){
			requestSensorRead();
		}
		
		document.querySelector( 'button.day' ).onclick = function(){
			loadSensorData( 1 );
		}
		document.querySelector( 'button.week' ).onclick = function(){
			loadSensorData( 7 );
		}
		document.querySelector( 'button.month' ).onclick = function(){
			loadSensorData( 31 );
		}
		document.querySelector( 'button.grow' ).onclick = function(){
			loadSensorData( 63 );
		}
		
		document.querySelector( 'i.fa-cog' ).onclick = function(){
			push( new SetupActivity( service, setup ) );
		}

		//for( view in rooms ) view.render();

		window.addEventListener( 'keydown', handleKeyDown, false );
	}

	override function onPause() {
		service.onDisconnect = null;
		service.onData = null;
		for( view in rooms ) view.dispose();
		window.removeEventListener( 'keydown', handleKeyDown );
	}

	function handleKeyDown(e) {
		//trace(e.keyCode);
		switch e.keyCode {
		case 82: // R
			requestSensorRead();
		}
	}

	function requestSensorRead() {
		//var btn = document.querySelector( 'i.fa-sync' );
		//btn.classList.add( 'active' );
		service.requestSensorRead().then( function(r){
			//trace(r);
		});
	}

	function loadSensorData( days : Int ) {
		element.style.display = 'none';
		service.loadDataForDays( days ).then( function(data){
			replace( new MainActivity( service, setup, data ) );
		});
	}
}

private class RoomView {

	static inline var WARN_TEMPERATURE_MIN = 15;
	static inline var WARN_TEMPERATURE_MAX = 27;

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
	var chartContainer : DivElement;
	var canvas : CanvasElement;
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

		//var height = Std.int(window.innerHeight-100);

		chartContainer = document.createDivElement();
		chartContainer.classList.add( 'chart-container' );
		//chartContainer.style.height = height+'px';
		element.appendChild( chartContainer );

		canvas = document.createCanvasElement();
		canvas.width = window.innerWidth;
		//canvas.height = height;
		canvas.classList.add( 'chart' );
		chartContainer.appendChild( canvas );

		var datasets = new Array<Dynamic>();
		for( i in 0...setup.sensors.length ) {
			var sensor = setup.sensors[i];
			datasets.push({
				type: 'line',
				label: sensor.name,
				yAxisID: 'y-axis-1',
				borderColor: COLORS_TEMPERATURE[i],
				//backgroundColor: COLORS_TEMPERATURE[i],
				//backgroundColor: 'rgba(50,50,50,0.2)', //untyped Color( COLORS_TEMPERATURE[i] ).alpha( 0.2 ).rgbString(),
				backgroundColor: untyped Color( COLORS_TEMPERATURE[i] ).alpha( 0.1 ).rgbString(),
				//backgroundColor: 'rgba(255,100,100,0.9)',
				//pointRadius: 0.5,
				//lineTension: 0.05,
				//display: false,
				//hidden: true,
				data: [],
			});
		}
		
		datasets[0].fill = '1';
		datasets[1].fill = '2';
		datasets[2].fill = '2';

		for( i in 0...setup.sensors.length ) {
			var sensor = setup.sensors[i];
			datasets.push({
				type: 'line',
				label: sensor.name,
				yAxisID: 'y-axis-2',
				borderColor: COLORS_HUMIDITY[i],
				//backgroundColor: COLORS_HUMIDITY[i],
				//backgroundColor: 'rgba(50,50,50,0.2)',
				//borderDash: [10,4],
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
				maintainAspectRatio: false,
				//maintainAspectRatio: true,
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
						borderWidth: 1,
						tension: 0.1
						//stepped: true
					},
					point: {
						//backgroundColor:
						pointStyle: 'circle',
						radius: 1,
						/*
						radius: function adjustRadiusBasedOnData( ctx ) {
							var v = ctx.dataset.data[ctx.dataIndex];
							trace(v);
							return v > 23 ? 10 : 1;
						},
						*/
					}
				},
				legend: {
					display: false
				},
				scales: {
					xAxes: [{
						gridLines: {
							display: true,
							drawBorder: true,
							//drawOnChartArea: false,
							//drawTicks: false,
							color: '#111'
						},
						ticks: {
							fontFamily: 'Anonymous Pro',
							fontSize: 11
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
							gridLines: {
								display: true,
								//drawBorder: true,
								//drawOnChartArea: true,
								//drawTicks: true,
								//color: ['#111','#222','#111','#222','#111','#111','#111','#111','#111','#111']
								color: '#111',
							},
							scaleLabel: {
								display: false,
								labelString: 'TEMPERATURE'
							},
							ticks: {
								//min: 10,
								//max: 100,
								stepSize: 0.5,
								//suggestedMin: 20,
								//suggestedMax: 25,
								fontFamily: 'Anonymous Pro',
								fontSize: 11,
								callback: function(value,index,values){
									//trace(value,index,values);
									var str = value+'°';
									switch value {
									case 19,27: str = '–––$str';
									}
									return str;
								}
							}
						},
						{
							display: true,
							gridLines: {
								drawOnChartArea: false,
								color: '#111'
							},
							id: 'y-axis-2',
							position: 'left',
							scaleLabel: {
								display: false,
								labelString: 'HUMIDITY'
							},
							ticks: {
								fontFamily: 'Anonymous Pro',
								fontSize: 11,
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

		updateChartHeight();
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

		window.addEventListener( 'resize', handleWindowResize, false );
	}

	public function render() {
		chart.render();
	}

	public function dispose() {
		window.removeEventListener( 'resize', handleWindowResize );
	}

	public function update( entry : Dynamic ) {
		
		var time = entry.time; //Date.fromTime( data.time );
		var temperature : Float = entry.data.temperature;
		var humidity : Float = entry.data.humidity;

		var view = sensors.get( entry.sensor.name );
		view.update( time, temperature, humidity );

		chart.data.labels.push( Date.fromTime( entry.time ) );
		var j = 0;
		for( key in sensors.keys() ) {
			if( key == entry.sensor.name ) {
				//trace(key);
				chart.data.datasets[j].data.push( temperature );
				chart.data.datasets[j+numSensors].data.push( humidity );
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
		
		/*
		for( i in 0...chart.data.datasets.length ) {
			chart.data.datasets[i].data.shift();
		}
		*/

		chart.update();

		//TODO
		if( temperature >= WARN_TEMPERATURE_MAX ) {
			var warning = new js.html.Audio( 'snd/warning.mp3' );
			warning.play();
		}
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

	function updateChartHeight() {
		var w = Std.int( window.innerWidth );
		if( w < 200 ) w = 200;
		var h = Std.int( window.innerHeight );
		if( h > w ) h = w;
		else if( h < 200 ) h = 200;
		chartContainer.style.height = h+'px';
		canvas.height = h;
		chart.render();
	}

	function handleWindowResize(e) {
		updateChartHeight();
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
