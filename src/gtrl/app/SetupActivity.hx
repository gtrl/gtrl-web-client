package gtrl.app;

import gtrl.Setup;

class SetupActivity extends MenuActivity {

	var service : Service;
	var setup : Setup;

	public function new( service : Service, setup : Setup ) {
		super();
		this.service = service;
		this.setup = setup;
	}

	override function onCreate() {
		//element.textContent = ''+setup;

		super.onCreate();

		/*
		title = document.createElement( 'h2' );
		title.classList.add( 'title' );
		title.textContent = 'setup';
		element.appendChild( title );
		*/

		var rooms = document.createDivElement();
		rooms.classList.add( 'rooms' );
		element.appendChild( rooms );

		for( room in setup ) {
			var view = new RoomView( room );
			rooms.appendChild( view.element );
		}
	}

	/*
	override function onResume() {
		title.addEventListener( 'click', handleClickTitle, false );
	}

	override function onResume() {
		title.addEventListener( 'click', handleClickTitle, false );
	}
	*/
}

private class RoomView {

	public var element(default,null) : DivElement;

	public function new( setup : RoomSetup ) {

		trace(setup);

		element = document.createDivElement();
		element.classList.add( 'room' );

		var name = document.createElement( 'h4' );
		name.classList.add( 'name' );
		name.textContent = setup.name;
		element.appendChild( name );

		var size = document.createDivElement();
		size.classList.add( 'size' );
		size.textContent = 'W:${setup.size.w} H: ${setup.size.h} D: ${setup.size.d}';
		element.appendChild( size );

		var interval = document.createDivElement();
		interval.classList.add( 'interval' );
		interval.textContent = 'INTERVAL: '+setup.interval;
		element.appendChild( interval );

		var sensors = document.createDivElement();
		sensors.classList.add( 'sensors' );
		element.appendChild( sensors );

		for( s in setup.sensors ) {
			var view = new SensorView( s );
			sensors.appendChild( view.element );
		}
	}
}

private class SensorView {

	public var element(default,null) : DivElement;

	public function new( setup : SensorSetup ) {

		trace(setup);

		element = document.createDivElement();
		element.classList.add( 'sensor' );

		var name = document.createElement( 'h5' );
		name.classList.add( 'name' );
		name.textContent = setup.name;
		element.appendChild( name );

		var type = document.createDivElement();
		type.classList.add( 'type' );
		type.textContent = setup.type;
		element.appendChild( type );

		var pin = document.createDivElement();
		pin.classList.add( 'pin' );
		pin.textContent = setup.driver.options.pin;
		element.appendChild( pin );
	}
}
