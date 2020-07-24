package depth;

import flixel.FlxSprite;
import flixel.FlxG;
import flixel.FlxCamera;
import flixel.math.FlxMath;
import flixel.math.FlxVelocity;
import flixel.math.FlxVector;
import flixel.math.FlxPoint;
import flixel.system.FlxAssets.FlxGraphicAsset;
import flixel.util.FlxDestroyUtil;
import flixel.util.FlxColor;
import openfl.geom.ColorTransform;

class DepthSprite extends FlxSprite implements IDepth {
  /**
   * All DepthSprites in this list.
   */
  public var slices:Array<DepthSprite> = [];
  /**
   * Simulated position of the sprite on the Z axis.
   */
  public var z:Float;

  public var local_x:Float;

  public var local_y:Float;
  /**
   * Simulated position of the sprite on the Z axis, relative to the sprite's parent
   */
  public var local_z:Float;

  public var local_angle:Float;

  public var velocity_z:Float;
  /**
   * Used to set whether the Sprite "billboards",
   * or that the Sprite's angle will always remain opposite of the Camera's
   */
  public var billboard(default, set):Bool;
  /**
   * Offset of each 3D "Slice"
   */
  public var slice_offset:Float = 1;
  /**
   * Amount of Graphics in this list.
   */
  public var count(get, never):Int;

  var parent_red:Float = 1;
  var parent_green:Float = 1;
  var parent_blue:Float = 1;

  public function new(x:Float = 0, y:Float = 0) {
    super(x, y);
    z = 0;
    velocity_z = 0;
  }
  /**
   * WARNING: This will remove this sprite entirely. Use kill() if you
   * want to disable it temporarily only and reset() it later to revive it.
   * Used to clean up memory.
   */
  override public function destroy():Void {
    super.destroy();

    slices = FlxDestroyUtil.destroyArray(slices);
  }
  /**
   * Adds the DepthSprite to the slices list.
   *
   * @param	slice	The DepthSprite to add.
   * @return	The added DepthSprite.
   */
  public function add_slice(slice:DepthSprite):DepthSprite {
    if (slices.indexOf(slice) >= 0) return slice;

    slices.push(slice);
    slice.velocity.set(0, 0);
    slice.acceleration.set(0, 0);
    slice.scrollFactor.copyFrom(scrollFactor);

    slice.alpha = alpha;
    slice.parent_red = color.redFloat;
    slice.parent_green = color.greenFloat;
    slice.parent_blue = color.blueFloat;
    slice.color = slice.color;

    return slice;
  }
  /**
   * Removes the DepthSprite from the slices list.
   *
   * @param	slice	The DepthSprite to remove.
   * @return	The removed DepthSprite.
   */
  public function remove_slice(slice:DepthSprite):DepthSprite {
    var index:Int = slices.indexOf(slice);
    if (index >= 0) slices.splice(index, 1);
    index = slices.indexOf(slice);
    if (index >= 0) slices.splice(index, 1);

    return slice;
  }
  /**
   * Removes the DepthSprite from the position in the slices list.
   *
   * @param	Index	Index to remove.
   */
  public function remove_index(Index:Int = 0):DepthSprite {
    if (slices.length < Index || Index < 0) return null;

    return remove_slice(slices[Index]);
  }
  /**
   * Removes all slices sprites from this sprite.
   */
  public function remove_all():Void {
    for (slice in slices) remove_slice(slice);
  }

  public function sync() {
    for (slice in slices) if (slice.active && slice.exists) {
      slice.x = slice.local_x + x;
      slice.y = slice.local_y + y;
      slice.z = slice.local_z * slice_offset + z;
      slice.angle = slice.local_angle + angle;
      slice.scale.copyFrom(scale);

      slice.sync();
    }
  }

  override public function update(elapsed:Float) {
    super.update(elapsed);

    z += velocity_z * elapsed;

    for (slice in slices) if (slice.active && slice.exists) slice.update(elapsed);

    sync();
  }
  /**
   * Extending `getScreenPosition` to set the sprite's z-offset based on the camera angle.
   * We do this here so as to not offset the sprite's actual world space, but just it's visuals.
   */
  override public function getScreenPosition(?point:FlxPoint, ?Camera:FlxCamera):FlxPoint {
    if (point == null) point = FlxPoint.get();
    if (Camera == null) Camera = FlxG.camera;

    // This is where the offset is created, then added to the sprite's screen position.
    var _offset = FlxVelocity.velocityFromAngle((Camera.angle + 90) * -1, -z);
    point.set(x + _offset.x, y + _offset.y);
    _offset.put();

    if (pixelPerfectPosition) point.floor();

    return point.subtract(Camera.scroll.x * scrollFactor.x, Camera.scroll.y * scrollFactor.y);
  }

  override public function draw():Void {
    // if billboarded, angle is opposite of camera's
    if (billboard) {
      var temp = angle;
      angle = -FlxG.camera.angle;
      super.draw();
      angle = temp;
    }
    else super.draw();

    for (slice in slices) if (slice.exists && slice.visible) slice.draw();
  }

  #if FLX_DEBUG
  override public function drawDebug():Void {
    super.drawDebug();

    for (slice in slices) if (slice.exists && slice.visible) slice.drawDebug();
  }
  #end

  override function kill() {
    super.kill();
    for (slice in slices) slice.kill();
  }

  override function revive() {
    super.revive();
    for (slice in slices) slice.revive();
  }

  override function set_color(Color:FlxColor):FlxColor {
    for (slice in slices) slice.color = Color;
    if (color == Color) return Color;
    color = Color;
    updateColorTransform();
    return color;
  }

  public function set_slice_offsets(x:Float, y:Float) {
    for (slice in slices) slice.offset.set(x, y);
  }
  /**
   * Loads a 3D Sprite from a Sprite sheet
   * @param img
      * @param width
   * @param height
   * @param slices
   */
  public function load_slices(img:FlxGraphicAsset, width:Int, height:Int, slices:Int):DepthSprite {
    this.slices.resize(0);
    // loadGraphic(img, true, slice_width, slice_height);
    makeGraphic(width, height, FlxColor.TRANSPARENT);
    for (i in 0...slices) load_slice(img, width, height, i, i);

    return this;
  }
  /**
   * Loads a 3D Sprite from a FlxColor
   * @param color
      * @param width
   * @param height
   * @param slices
   */
  public function make_slices(width:Int, height:Int, slices:Int, color:FlxColor = FlxColor.WHITE):DepthSprite {
    this.slices.resize(0);
    makeGraphic(width, height, FlxColor.TRANSPARENT);
    for (i in 0...slices + 1) make_slice(width, height, i, color);

    return this;
  }
  /**
   * The sprite's depth in relation to the camera angle.
   * Function inspired by @01010111.
   */
  public function get_depth(?camera:FlxCamera):Float {
    var mid:FlxVector = getMidpoint();
    var d = FlxVelocity.velocityFromAngle(mid.degrees + (camera == null ? FlxG.camera : camera).angle, mid.length);
    var d_y = d.y;
    mid.put();
    d.put();

    return d_y;
  }

  inline function load_slice(img:FlxGraphicAsset, width:Int, height:Int, z:Int, frame:Int = 0) {
    var s = get_slice(z);
    s.loadGraphic(img, true, width, height);
    s.animation.frameIndex = frame;
  }

  inline function make_slice(width:Int, height:Int, z:Int, color:FlxColor = FlxColor.WHITE) {
    var s = get_slice(z);
    s.makeGraphic(width, height, color);
  }

  inline function get_slice(z:Int):DepthSprite {
    var s = new DepthSprite(x, y);
    s.local_z = -z;
    s.z = this.z + s.local_z;
    s.solid = false;
    s.camera = camera;
    #if FLX_DEBUG
    s.ignoreDrawDebug = true;
    #end
    add_slice(s);
    return s;
  }
  /**
   * Get the sprite's Rotation relative to the Camera.
   */
  public inline function get_relative_angle(?camera:FlxCamera)
    return ((-angle - (camera == null ? FlxG.camera : camera).angle + 180) % 360);
  /**
   * Set the sprite's Rotation relative to the Camera.
   */
  public inline function set_relative_angle(value:Float, ?camera:FlxCamera)
    return angle = ((value - (camera == null ? FlxG.camera : camera).angle) % 360);

  public inline function anchor_origin():Void {
    origin.set(frameWidth * 0.5, frameHeight);
  }

  public inline function anchor_offset():Void {
    offset.set(frameWidth * 0.5, frameHeight);
  }

  function set_billboard(value:Bool):Bool {
    return billboard = value;
  }

  override function set_width(value:Float) {
    for (slice in slices) slice.width = value;
    return super.set_width(value);
  }

  override function set_height(value:Float) {
    for (slice in slices) slice.height = value;
    return super.set_height(value);
  }

  override function set_visible(Value:Bool):Bool {
    for (slice in slices) slice.visible = Value;
    return super.set_visible(Value);
  }

  override function set_alpha(Alpha:Float):Float {
    super.set_alpha(Alpha);

    if (slices != null) {
      for (slice in slices) slice.alpha = alpha;
    }
    return alpha;
  }

  override function set_flipX(v:Bool) {
    if (slices != null) for (slice in slices) if (slice.exists && slice.active) slice.flipX = v;
    return super.set_flipX(v);
  }

  override function set_facing(Direction:Int):Int {
    super.set_facing(Direction);
    if (slices != null) for (slice in slices) {
      if (slice.exists && slice.active) slice.facing = Direction;
    }

    return Direction;
  }

  inline function get_count():Int {
    return slices.length;
  }
}
