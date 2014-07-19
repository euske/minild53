package {

import flash.geom.Point;
import flash.geom.Rectangle;

//  Utility Functions
// 
public class Utils
{
  // clamp(v0, v, v1): caps the value between upper/lower bounds.
  public static function clamp(v0:int, v:int, v1:int):int
  {
    return Math.min(Math.max(v, v0), v1);
  }
  
  // rnd(n)
  public static function rnd(a:int, b:int=0):int
  {
    if (b < a) {
      var c:int = a;
      a = b;
      b = c;
    }
    return Math.floor(Math.random()*(b-a))+a;
  }

  // choose(a)
  public static function choose(a:Array):*
  {
    return a[rnd(a.length)];
  }

  // shuffle(a)
  public static function shuffle(a:Array):Array
  {
    for (var n:int = 0; n < a.length; n++) {
      var i:int = rnd(a.length);
      var j:int = rnd(a.length);
      var t:* = a[i];
      a[i] = a[j];
      a[j] = t;
    }
    return a;
  }

  // format
  public static function format(v:int, n:int=3, c:String=" "):String
  {
    var s:String = "";
    while (s.length < n) {
      s = (v % 10)+s;
      v /= 10;
      if (v <= 0) break;
    }
    while (s.length < n) {
      s = c+s;
    }
    return s;
  }
}

} // package
