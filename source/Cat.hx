import depth.DepthSprite;

class Cat extends DepthSprite {
  public function new(x, y) {
    super(x, y);
    loadGraphic(AssetPaths.cat__png, true, 16, 16);
    // Set `billboard` to true
    billboard = true;
    animation.add("meow", [0, 1], 2);
    animation.play("meow");
    setSize(3, 3);
    anchor_offset();
    anchor_origin();
  }
}
