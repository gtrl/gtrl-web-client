package gtrl.app;

class MenuActivity extends Activity {

	var title : Element;

	/*
	public function new( service : Service, setup : Setup ) {
		super();
		this.service = service;
		this.setup = setup;
	}
	*/

	override function onCreate() {
		title = document.createElement( 'h2' );
		title.classList.add( 'title' );
		title.textContent = id;
		element.appendChild( title );
	}

	override function onResume() {
		title.addEventListener( 'click', handleClickTitle, false );
	}

	override function onPause() {
		title.addEventListener( 'click', handleClickTitle, false );
	}

	function handleClickTitle(e) {
		pop();
	}
}
