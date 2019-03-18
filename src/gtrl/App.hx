package gtrl;

class App implements om.App {

	static function main() {
		console.info( 'GTRL' );
		Activity.boot( new gtrl.app.ConnectActivity() );
	}
}