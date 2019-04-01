package gtrl;

import gtrl.app.Service;

class App implements om.App {

	public static var isMobile(default,null) = om.System.isMobile();

	static function main() {
		console.info( 'GTRL' );
		Activity.boot( new gtrl.app.ConnectActivity( Service.HOST, Service.PORT ) );
	}
}