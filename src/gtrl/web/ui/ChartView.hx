package gtrl.web.ui;

import js.html.CanvasElement;
import js.html.CanvasRenderingContext2D;

class ChartView {

	static var COLORS = {
		temperature: [
			{ border: 'rgba(233,30,99,0.8)', background: 'rgba(233,30,99,0.2)' },
			{ border: 'rgba(255,152,0,0.8)', background: 'rgba(255,152,0,0.2)' }
		],
		humidity: [
			{ border: 'rgba(3,169,244,0.8)', background: 'rgba(3,169,244,0.2)' },
			{ border: 'rgba(103,58,183,0.8)', background: 'rgba(103,58,183,0.2)' }
		]
	};

	var canvas : CanvasElement;
	var ctx : CanvasRenderingContext2D;
	//var chart : Dynamic;

	public function new( canvas : CanvasElement ) {
		this.canvas = canvas;
		ctx = canvas.getContext2d();
	}

	function printSensor( index : Int, name : String, data : Array<Dynamic> ) {
		var times = new Array<String>();
		var datasets : Array<Dynamic> = [
			{
				label: 'Temperature',
				data: [],
				lineTension: 0,
				borderWidth: 1,
				pointRadius: 0,
				borderColor: COLORS.temperature[index].border,
				backgroundColor: COLORS.temperature[index].background,
			},
			{
				label: 'Humidity',
				data: [],
				lineTension: 0,
				borderWidth: 1,
				pointRadius: 0,
				borderColor: COLORS.humidity[index].border,
				backgroundColor: COLORS.humidity[index].background,
			}
		];
		for( row in data ) {
			times.push( Date.fromTime( row.time ).toString() );
			datasets[0].data.push( row.temperature );
			datasets[1].data.push( row.humidity );
		}
		var chart = untyped Chart.Line( ctx, {
			data: {
				labels: times,
				datasets: datasets
			},
			options: {
				responsive: true,
				hoverMode: 'index',
				stacked: false,
				title: {
					display: true,
					text: name
				},
				legend: {
					display: true,
					position: 'bottom'
				},
				animation: {
					duration: 400
				},
				scales: {
					xAxes: [{
						type: 'time',
						time: {
                    		displayFormats: {
								minute: 'HH:mm',
								hour: 'YYYY-MM-DD HH:mm',
								day: 'YYYY-MM-DD HH:mm'
                    		},
							//ticks: 1
						},
						position: 'bottom'
					}]
				}
 		    }
		});
	}

	public function print( data : Array<Dynamic> ) {
		var sensors = new Map<String,Array<Dynamic>>();
		for( row in data ) {
			if( sensors.exists( row.sensor ) )
				sensors.get( row.sensor ).push( row );
			else
				sensors.set( row.sensor, [row] );
		}
		/*
		var i = 0;
		for( sensor in sensors.keys() ) {
			printSensor( i, sensor, sensors.get( sensor) );
			i++;
		}
		*/
		printSensor( 0, 'top', sensors.get( 'top') );
	}

	public function clear() {
		//trace( chart );
		ctx.clearRect( 0, 0, canvas.width, canvas.height );
	}
}
