package;

import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.FlxG;
import flixel.FlxState;
import flixel.math.FlxMath;

class PlayState extends FlxState {
	/**
	 * Group to keep all our 3D objects sorted
	 */
	var sprites:FlxTypedGroup<DepthSprite>;

	// Camera controls
	var zoom:Float;
	var angle:Float;
	var last_mouse_x:Float;
	var lerp:Float = 0.15;

	override public function create():Void {
		super.create();

		sprites = new FlxTypedGroup();
		add(sprites);

		// Add the 3D Sprites
		for (i in 0...10) {
			// Place in random position
			var crate = new DepthSprite(Math.random() * 240, Math.random() * 240);
			// Load the sliced spritesheet
			crate.load_slices(AssetPaths.crate__png, 16, 16, 16);
			crate.angle = Math.random() * 360;
			sprites.add(crate);
		}

		// Add the Billboarded sprites
		for (i in 0...10) {
			// Place in random position
			var cat = new Cat(Math.random() * 240, Math.random() * 240);
			sprites.add(cat);
		}

		// Add a Billboarded Sprite in the center to revolve around
		var cat = new Cat(120, 120);
		sprites.add(cat);

		// Initialize some camera control variables
		angle = -90;
		zoom = FlxG.camera.zoom;
		FlxG.camera.bgColor = 0xff222034;

		// Increase the camera size 2X so that the camera is bigger than the screen
		// Otherwise you will see the camera edges when it rotates (comment these lines to see what I mean)
		FlxG.camera.setSize(FlxG.width * 2, FlxG.height * 2);
		FlxG.camera.setPosition(-FlxG.width / 2, -FlxG.height / 2);

		FlxG.camera.focusOn(cat.getMidpoint());
		FlxG.worldBounds.set(0, 0, 1000, 1000);
		FlxG.collide(sprites, sprites);
	}

	override public function update(elapsed:Float):Void {
		FlxG.collide(sprites, sprites);
		sprites.sort(sortByRotY);

		super.update(elapsed);

		// Camera controls
		// Drag your mouse to Rotate the camera angle
		// Scroll the mouse to zoom in-or-out
		angle += FlxG.mouse.pressed ? FlxG.mouse.x - last_mouse_x : 0.1;
		zoom += FlxG.mouse.wheel * 0.1;
		zoom = FlxMath.bound(zoom, 0.5, 3);
		last_mouse_x = FlxG.mouse.x;
		FlxG.camera.zoom += (zoom - FlxG.camera.zoom) * lerp;
		FlxG.camera.angle += (-angle - 90 - FlxG.camera.angle) * lerp;
	}

	/**
	 * Sorting function that compares the depth of each sprite.
	 * Check out the `get_depth` function in `DepthSprite` to see how it works
	 */
	function sortByRotY(o:Int, o1:DepthSprite, o2:DepthSprite):Int {
		return o1.get_depth() > o2.get_depth() ? 1 : -1;
	}
}
