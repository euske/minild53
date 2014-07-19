package {

import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.media.Sound;
import flash.media.SoundTransform;
import flash.geom.Point;
import flash.geom.Rectangle;
import flash.events.MouseEvent;
import flash.ui.Keyboard;
import flash.utils.getTimer;
import baseui.Screen;
import baseui.ScreenEvent;

//  GameScreen
//
public class GameScreen extends Screen
{
  private var _state:int;
  private var _ticks:int;
  private var _player:Player;
  private var _status:Status;

  private var _map:BitmapData;
  private var _mapimage:BitmapData;
  private var _window:Rectangle;

  public const TILE_SIZE:int = 16;
  public const WHIRL_COLOR:int = 0xff0000;

  private var _windowWidth:int;
  private var _windowHeight:int;

  [Embed(source="../assets/world.png")]
  private static const WorldMapBitmapCls:Class;
  private static const worldMapBitmap:Bitmap = new WorldMapBitmapCls();
  [Embed(source="../assets/sprites.png")]
  private static const SpriteImagesBitmapCls:Class;
  private static const spriteImages:BitmapData = new SpriteImagesBitmapCls().bitmapData;

  public function GameScreen(width:int, height:int, shared:Object)
  {
    super(width, height, shared);

    _status = new Status();
    _status.x = (width-_status.width)/2;
    _status.y = (height-_status.height-8);
    addChild(_status);

    _windowWidth = width / TILE_SIZE;
    _windowHeight = (height-_status.height-16) / TILE_SIZE;

    _window = new Rectangle(0, 0, _windowWidth, _windowHeight);

    _map = worldMapBitmap.bitmapData.clone();
    _mapimage = new BitmapData(_windowWidth*TILE_SIZE, 
			       _windowHeight*TILE_SIZE);
    addChild(new Bitmap(_mapimage));

    _player = new Player(createSprite(0));
    addChild(_player);
  }

  // open()
  public override function open():void
  {
    _state = 0;
    _ticks = 0;

    initGame();
  }

  // close()
  public override function close():void
  {
  }

  // pause()
  public override function pause():void
  {
  }

  // resume()
  public override function resume():void
  {
  }

  private function createSprite(i:int):Bitmap
  {
    var data:BitmapData = new BitmapData(TILE_SIZE, TILE_SIZE);
    data.copyPixels(spriteImages, 
		    new Rectangle(i*TILE_SIZE, 0, TILE_SIZE, TILE_SIZE),
		    new Point());
    return new Bitmap(data);
  }

  // renderTiles
  private function renderTiles(r:Rectangle):void
  {
    for (var dy:int = 0; dy <= r.height; dy++) {
      for (var dx:int = 0; dx <= r.width; dx++) {
	var c:uint = _map.getPixel((r.x+dx) % _map.width, 
				   (r.y+dy) % _map.height);
	var i:int = -1;
	switch (c) {
	case 0x000000:
	  i = 2;
	  break;
	case WHIRL_COLOR:
	  i = 3;
	  break;
	default:
	  i = 1;
	  break;
	}
	if (0 <= i) {
	  var src:Rectangle = new Rectangle(i*TILE_SIZE, 0, TILE_SIZE, TILE_SIZE);
	  var dst:Point = new Point(dx*TILE_SIZE, dy*TILE_SIZE);
	  _mapimage.copyPixels(spriteImages, src, dst);
	}
      }
    }
  }

  // setCenter(p)
  public function setCenter(p:Point, hmargin:int, vmargin:int):void
  {
    // Center the window position.
    if (_mapimage.width < _window.width) {
      _window.x = -(_window.width-_mapimage.width)/2;
    } else if (p.x-hmargin < _window.left) {
      _window.x = Math.max(0, p.x-hmargin);
    } else if (_window.right < p.x+hmargin) {
      _window.x = Math.min(_mapimage.width, p.x+hmargin)-_window.width;
    }
    if (_map.height < _window.height) {
      _window.y = -(_window.height-_map.height)/2;
    } else if (p.y-vmargin < _window.top) {
      _window.y = Math.max(0, p.y-vmargin);
    } else if (_window.bottom < p.y+vmargin) {
      _window.y = Math.min(_map.height, p.y+vmargin)-_window.height;
    }
  }

  // update()
  public override function update():void
  {
    _player.update(_ticks);
    _map.setPixel(_player.pos.x % _map.width, 
		  _player.pos.y % _map.height,
		  WHIRL_COLOR);
    setCenter(_player.pos, 4, 0);
    renderTiles(_window);

    _player.x = (_player.pos.x-_window.left) * TILE_SIZE;
    _player.y = (_player.pos.y-_window.top) * TILE_SIZE;
    _ticks++;
  }

  // initGame()
  private function initGame():void
  {
    trace("initGame");
    _status.level = 1;
    _status.miss = 0;
    _status.time = 60;
    _status.update();

    _player.pos = new Point(0, 3);

    _state = 1;
  }

  // startGame()
  private function startGame():void
  {
    _state = 2;
  }

  // gameOver()
  private function gameOver():void
  {
    trace("gameOver");
    _state = 0;
  }

  // keydown(keycode)
  public override function keydown(keycode:int):void
  {
    switch (keycode) {
    case Keyboard.LEFT:
    case 65:			// A
    case 72:			// H
      _player.vx = -1;
      break;

    case Keyboard.RIGHT:
    case 68:			// D
    case 76:			// L
      _player.vx = +1;
      break;

    case Keyboard.UP:
    case 87:			// W
    case 75:			// K
      _player.vy = -1;
      break;

    case Keyboard.DOWN:
    case 83:			// S
    case 74:			// J
      _player.vy = +1;
      break;

    case Keyboard.SPACE:
    case Keyboard.ENTER:
    case 88:			// X
    case 90:			// Z
      //_player.action();
      break;

    }
  }

  // keyup(keycode)
  public override function keyup(keycode:int):void 
  {
    switch (keycode) {
    case Keyboard.LEFT:
    case Keyboard.RIGHT:
    case 65:			// A
    case 68:			// D
    case 72:			// H
    case 76:			// L
      _player.vx = 0;
      break;

    case Keyboard.UP:
    case Keyboard.DOWN:
    case 87:			// W
    case 75:			// K
    case 83:			// S
    case 74:			// J
      _player.vy = 0;
      break;
    }
  }
}

} // package

import flash.display.Shape;
import flash.display.Sprite;
import flash.display.Bitmap;
import flash.media.Sound;
import flash.media.SoundChannel;
import flash.geom.Rectangle;
import flash.geom.Point;
import baseui.Font;


//  Status
// 
class Status extends Sprite
{
  public var level:int;
  public var miss:int;
  public var time:int;

  private var _text:Bitmap;

  public function Status()
  {
    _text = Font.createText("LEVEL: 00   MISS: 00   TIME: 00", 0xffffff, 0, 2);
    addChild(_text);
  }

  public function update():void
  {
    var text:String = "LEVEL: "+Utils.format(level,2);
    text += "   MISS: "+Utils.format(miss,2);
    text += "   TIME: "+Utils.format(time,2);
    Font.renderText(_text.bitmapData, text);
  }
}


//  Guide
// 
class Guide extends Sprite
{
  private var _text:Bitmap;
  private var _sound:Sound;
  private var _channel:SoundChannel;
  private var _count:int;

  public function Guide(width:int, height:int, alpha:Number=0.2)
  {
    graphics.beginFill(0, alpha);
    graphics.drawRect(0, 0, width, height);
    graphics.endFill();
  }

  public function set text(v:String):void
  {
    if (_text != null) {
      removeChild(_text);
      _text = null;
    }
    if (v != null) {
      _text = Font.createText(v, 0xffffff, 2, 2);
      _text.x = (width-_text.width)/2;
      _text.y = (height-_text.height)/2;
      addChild(_text);
    }
  }

  public function show(text:String=null, 
		       sound:Sound=null, delay:int=30):void
  {
    this.text = text;
    _sound = sound;
    _count = delay;
    visible = true;
  }

  public function hide():void
  {
    if (_channel != null) {
      _channel.stop();
      _channel = null;
    }
    visible = false;
  }

  public function update():void
  {
    if (_count != 0) {
      _count--;
    } else {
      if (_sound != null) {
	_channel = _sound.play();
	_sound = null;
      }
    }
  }
}

//  Player
// 
class Player extends Sprite
{
  public var vx:int;
  public var vy:int;

  private var _pos:Point;

  public function Player(bitmap:Bitmap)
  {
    _pos = new Point();
    addChild(bitmap);
  }

  public function get pos():Point
  {
    return _pos;
  }
  public function set pos(v:Point):void
  {
    _pos = v;
  }

  public function get rect():Rectangle
  {
    return new Rectangle(x, y, width, height);
  }

  public function update(t:int):void
  {
    _pos.x += vx;
    _pos.y += vy;
  }
}