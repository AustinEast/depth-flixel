package;

import flixel.FlxGame;
import openfl.display.Sprite;

class Main extends Sprite {
	public function new() {
		super();
		addChild(new FlxGame(128, 128, PlayState));
	}
}
