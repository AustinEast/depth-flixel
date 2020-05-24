package depth;

class DepthUtil {
  /**
   * Sorting function that compares the depth of each sprite.
   * Check out the `get_depth` function in `DepthSprite` to see how it works
   */
  public static function sort_by_depth(o:Int, o1:DepthSprite, o2:DepthSprite):Int {
    return o1.get_depth() > o2.get_depth() ? 1 : -1;
  }
}
