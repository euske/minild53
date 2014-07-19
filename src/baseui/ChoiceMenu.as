package baseui {

import flash.display.Sprite;
import flash.events.Event;
import flash.media.Sound;
import flash.ui.Keyboard;

//  ChoiceMenu
// 
public class ChoiceMenu extends Sprite
{
  public static const CHOOSE:String = "Event.CHOOSE";

  public var margin:int = 16;

  private var _totalHeight:int;
  private var _choices:Vector.<MenuChoice>;

  private var _current:int = -1;

  public function ChoiceMenu()
  {
    _totalHeight = margin;
    _choices = new Vector.<MenuChoice>();
  }
  
  public function addChoice(label:String, value:Object=null, sound:Sound=null):void
  {
    var choice:MenuChoice = new BitmapMenuChoice(label, value, sound);
    choice.y = _totalHeight;
    choice.addEventListener(MenuChoiceEvent.FOCUS, onMenuFocus);
    choice.addEventListener(MenuChoiceEvent.CHOOSE, onMenuChoose);
    _totalHeight += choice.height + margin;
    _choices.push(choice);
    addChild(choice);
  }
  
  private function onMenuFocus(e:MenuChoiceEvent):void
  {
    if (e.choice != null) {
      choice = e.choice;
      update();
    }
  }

  private function onMenuChoose(e:MenuChoiceEvent):void
  {
    if (e.choice != null) {
      choice = e.choice;
      dispatchEvent(new Event(CHOOSE));
    }
  }

  public function get choices():Vector.<MenuChoice>
  {
    return _choices;
  }

  public function get choice():MenuChoice
  {
    if (0 <= _current && _current < _choices.length) {
      return _choices[_current];
    } else {
      return null;
    }
  }

  public function set choice(value:MenuChoice):void
  {
    if (value != null) {
      _current = _choices.indexOf(value);
    } else {
      _current = -1;
    }
    update();
  }

  public function get choiceIndex():int
  {
    return _current;
  }

  public function set choiceIndex(v:int):void
  {
    if (0 <= v && v < _choices.length) {
      _current = v;
    } else {
      _current = -1;
    }
    update();
  }

  public function update(playSound:Boolean=false):void
  {
    for (var i:int = 0; i < _choices.length; i++) {
      var highlit:Boolean = (_current == i);
      var choice:MenuChoice = _choices[i];
      choice.highlit = highlit;
      if (playSound && highlit && choice.sound != null) {
	choice.sound.play();
      }
    }
  }

  public function keydown(keycode:int):void
  {
    switch (keycode) {
    case Keyboard.UP:
      if (_current < 0 && 0 < _choices.length) {
	_current = 0;
	update(true);
      } else if (0 < _current) {
	_current--;
	update(true);
      }
      break;

    case Keyboard.DOWN:
      if (_current < 0 && 0 < _choices.length) {
	_current = 0;
	update(true);
      } else if (_current < _choices.length-1) {
	_current++;
	update(true);
      }
      break;
      
    case Keyboard.LEFT:
    case Keyboard.HOME:
      if (0 < _choices.length) {
	_current = 0;
	update(true);
      }
      break;

    case Keyboard.RIGHT:
    case Keyboard.END:
      if (0 < _choices.length) {
	_current = _choices.length-1;
	update(true);
      }
      break;

    case 49:			// 1-9
    case 50:
    case 51:
    case 52:
    case 53:
    case 54:
    case 55:
    case 56:
    case 57:
    case 58:
      if (keycode-49 < _choices.length) {
	_current = keycode-49;
	update(true);
      }
      break;

    case Keyboard.SPACE:
    case Keyboard.ENTER:
      if (choice != null) {
	dispatchEvent(new Event(CHOOSE));
      }
      break;
    }
  }
}

} // package

import flash.display.Sprite;
import flash.display.Bitmap;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.media.Sound;
import flash.geom.ColorTransform;
import baseui.Font;

class MenuChoiceEvent extends Event
{
  public static const FOCUS:String = "MenuChoiceEvent.FOCUS";
  public static const CHOOSE:String = "MenuChoiceEvent.CHOOSE";

  public var choice:MenuChoice;

  public function MenuChoiceEvent(type:String, choice:MenuChoice=null)
  {
    super(type);
    this.choice = choice;
  }
}

class MenuChoice extends Sprite
{
  public var label:String;
  public var value:Object;
  public var sound:Sound;

  public override function toString():String
  {
    return ("<MenuChoice: "+label+", "+value+">");
  }

  public function MenuChoice(label:String, value:Object=null, sound:Sound=null)
  {
    this.label = label;
    this.value = (value != null)? value : label;
    this.sound = sound;
    addEventListener(MouseEvent.MOUSE_OVER, onMouseOver);
    addEventListener(MouseEvent.MOUSE_OUT, onMouseOut);
    addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
  }

  protected virtual function onMouseOver(e:MouseEvent):void 
  {
    dispatchEvent(new MenuChoiceEvent(MenuChoiceEvent.FOCUS, this));
  }

  protected virtual function onMouseOut(e:MouseEvent):void 
  {
    dispatchEvent(new MenuChoiceEvent(MenuChoiceEvent.FOCUS, null));
  }

  protected virtual function onMouseDown(e:MouseEvent):void 
  {
    dispatchEvent(new MenuChoiceEvent(MenuChoiceEvent.CHOOSE, this));
  }

  public virtual function set highlit(v:Boolean):void
  {
  }
}

class BitmapMenuChoice extends MenuChoice
{
  public var margin:int = 8;
  public var scale:int = 2;
  public var fgColor:uint = 0xffffff;
  public var hiColor:uint = 0xff0000;

  private var _text:Bitmap;
  private var _highlit:Boolean;

  public function BitmapMenuChoice(label:String, value:Object=null, sound:Sound=null)
  {
    super(label, value, sound);

    _text = Font.createText(label, 0xffffff, scale, scale);
    _text.x = margin;
    _text.y = margin;
    addChild(_text);

    update();
  }

  public override function set highlit(v:Boolean):void
  {
    _highlit = v;
    update();
  }

  public function update():void
  {
    var color:uint = _highlit? hiColor : fgColor;
    var ct:ColorTransform = new ColorTransform();
    ct.color = color;
    _text.bitmapData.colorTransform(_text.bitmapData.rect, ct);

    graphics.clear();
    graphics.beginFill(0, 0.5);
    graphics.drawRect(0, 0, _text.width+margin*2, _text.height+margin*2);
    graphics.endFill();
  }
}
