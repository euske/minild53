package baseui {

import flash.display.Sprite;

//  Screen
//
public class Screen extends Sprite
{
  private var _width:int;
  private var _height:int;
  private var _shared:Object;

  public function Screen(width:int, height:int, shared:Object):void
  {
    _width = width;
    _height = height;
    _shared = shared;
  }

  public function get screenWidth():int
  {
    return _width;
  }

  public function get screenHeight():int
  {
    return _height;
  }

  public function get shared():Object
  {
    return _shared;
  }

  // open()
  public virtual function open():void
  {
  }

  // close()
  public virtual function close():void
  {
  }
  
  // pause()
  public virtual function pause():void
  {
  }

  // resume()
  public virtual function resume():void
  {
  }
  
  // update()
  public virtual function update():void
  {
  }

  // keydown(keycode)
  public virtual function keydown(keycode:int):void
  {
  }

  // keyup(keycode)
  public virtual function keyup(keycode:int):void
  {
  }
  
}

} // package baseui
