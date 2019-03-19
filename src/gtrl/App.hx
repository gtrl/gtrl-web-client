package gtrl;

class App implements om.App {

	public static inline var HOST = '192.168.0.200';
	public static inline var PORT = 9000;

	public static var isMobile(default,null) = om.System.isMobile();

	public static function connect() {
		Activity.boot( new gtrl.app.ConnectActivity( HOST, PORT ) );
	}

	static function main() {
		console.info( 'GTRL' );
		connect();
	}
}