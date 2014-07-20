package {

import flash.display.Bitmap;
import flash.media.Sound;
import flash.events.Event;
import flash.ui.Keyboard;
import baseui.Font;
import baseui.Screen;
import baseui.ScreenEvent;
import baseui.ChoiceMenu;

//  MenuScreen
// 
public class MenuScreen extends Screen
{
  public function MenuScreen(width:int, height:int, shared:Object)
  {
    super(width, height, shared);

    var text:Bitmap;
    text = Font.createText("HISTORY\nREPEATS\nITSELF", 0xffffff, 4, 4);
    text.x = (width-text.width)/2;
    text.y = (height-text.height)/4;
    addChild(text);
  }

  public override function keydown(keycode:int):void
  {
    switch (keycode) {
    case Keyboard.SPACE:
    case Keyboard.ENTER:
    case 88:			// X
    case 90:			// Z
      dispatchEvent(new ScreenEvent(GameScreen));
      break;
    }
  }
}

} // package
