package;

import flixel.FlxCamera;
import flixel.util.FlxColor;
import flixel.system.FlxAssets.FlxGraphicAsset;
import flixel.math.FlxPoint;
import flixel.math.FlxVelocity;
import flixel.math.FlxVector;
import flixel.FlxG;
import flixel.addons.display.FlxNestedSprite;

class ThreeDSprite extends FlxNestedSprite {
    
    /**
     * Simulated "Depth" position of the sprite
     */
    public var z:Float;
    /**
     * Adding a `relative_` var for this sprite's children's z
     */
     var relativeZ:Float;
    /**
     * Used to set whether the Sprite "billboards",
     * or that the Sprite's angle will always remain opposite of the Camera's
     */
    public var billboard:Bool;
    /**
     * Width of each 3D "Slice"
     */
    var slice_width:Int;
    /**
     * Height of each 3D "Slice"
     */
    var slice_height:Int;
    /**
     * Offset of each 3D "Slice"
     */
    var slice_offset:Int;

    override public function update(elapsed:Float) {
        super.update(elapsed);

        // if billboarded, angle is opposite of camera's
        if (billboard) angle = - FlxG.camera.angle;
    }

    /**
     * Overriding this function provided by FlxNestedSprite to set this sprite's children's z variable
     * @param elapsed 
     */
    override public function postUpdate(elapsed:Float) {
        super.postUpdate(elapsed);
        for (i in 0...children.length - 1)
		{
            var child:ThreeDSprite = cast children[i];
			if (child.active && child.exists) child.z = z + child.z;
        }
    }

    /**
     * Extending `getScreenPosition` to set the sprite's z-offset based on the camera angle.
     * We do this here so as to not offset the sprite's actual world space, but just it's visuals.
     */
    override public function getScreenPosition(?point:FlxPoint, ?Camera:FlxCamera):FlxPoint
	{
		if (point == null)
			point = FlxPoint.get();

		if (Camera == null)
			Camera = FlxG.camera;
	
        // This is where the offset is created, then added to the sprite's screen position.
        var _offset = FlxVelocity.velocityFromAngle((Camera.angle + 90) * -1, -z);
        point.set(x + _offset.x, y + _offset.y);

		if (pixelPerfectPosition)
			point.floor();
		
		return point.subtract(Camera.scroll.x * scrollFactor.x, Camera.scroll.y * scrollFactor.y);
	}

    /**
	 *  Function inspired by @01010111
	 *  Gets depth in relation to the camera angle
	 *  @return Float 
	 */
	public function get_depth():Float {
		
		var pos:FlxVector = FlxVector.get();
		getPosition(pos);
		pos.put();

		var pos = FlxVelocity.velocityFromAngle(pos.degrees + FlxG.camera.angle, pos.length);
		var d = pos.y;
		pos.put();

		return d;
	}

    /**
     * Loads a 3D Sprite from a Sprite sheet
     * @param img 
     * @param slices 
     * @param slice_width 
     * @param slice_height 
     * @param slice_offset 
     */
    public function loadSlices(img:FlxGraphicAsset, slices:Int, slice_width:Int, slice_height:Int, slice_offset:Int = 1):ThreeDSprite {
        this.slice_width = slice_width;
        this.slice_height = slice_height;
        this.slice_offset = slice_offset;
        
        if(graphic == null) loadGraphic(img, true, slice_width, slice_height);
        for (i in 1...slices) loadSlice(img, i, i);

        return this;
    }

    /**
     * Loads a 3D Sprite from a FlxColor
     * @param color 
     * @param slices 
     * @param slice_width 
     * @param slice_height 
     * @param slice_offset 
     */
    public function makeSlices(color:FlxColor = FlxColor.WHITE, slices:Int, slice_width:Int, slice_height:Int, slice_offset:Int = 1):ThreeDSprite {
        this.slice_width = slice_width;
        this.slice_height = slice_height;
        this.slice_offset = slice_offset;
        
        if(graphic == null) makeGraphic(slice_width, slice_height, color);
        for (i in 1...slices + 1) makeSlice(color, i);

        return this;
    }

    function loadSlice(img:FlxGraphicAsset, z:Int, frame:Int = 0) {
        var s = getSlice(z);
		s.loadGraphic(img, true, slice_width, slice_height);
		s.animation.frameIndex = frame;
		add(s);
	}

    function makeSlice(color:FlxColor = FlxColor.WHITE, z:Int) {
		var s = getSlice(z);
		s.makeGraphic(slice_width, slice_height, color);
		add(s);
	}

    function getSlice(z:Int):FlxNestedSprite {
        var s:ThreeDSprite;
        s = new ThreeDSprite(x, y);
        s.relativeZ = -z * slice_offset;
        s.z = this.z + s.relativeZ;
        s.solid = false;
        s.camera = camera;
        s.ignoreDrawDebug = true;
        return s;
    }
}