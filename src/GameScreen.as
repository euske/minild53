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

  private var _guide:Guide;
  private var _player:Player;
  private var _status:Status;

  private var _map:BitmapData;
  private var _mapimage:BitmapData;
  private var _world:Bitmap;
  private var _window:Rectangle;
  private var _queue:Vector.<Point>;
  private var _queue_push:int;
  private var _queue_pop:int;

  public const TILE_SIZE:int = 16;
  public const QUEUE_SIZE:int = 1024;
  public const SEA_COLOR:int = 0xffffff;
  public const LAND_COLOR:int = 0x000000;
  public const WHIRL_COLOR:int = 0xff0000;

  [Embed(source="../assets/world.png")]
  private static const WorldMapBitmapCls:Class;
  private static const worldMapBitmap:Bitmap = new WorldMapBitmapCls();
  [Embed(source="../assets/sprites.png")]
  private static const SpriteImagesBitmapCls:Class;
  private static const spriteImages:BitmapData = new SpriteImagesBitmapCls().bitmapData;

  public function GameScreen(width:int, height:int, shared:Object)
  {
    super(width, height, shared);

    _queue = new Vector.<Point>(QUEUE_SIZE);
    _queue_push = 0;
    _queue_pop = 1;

    _map = worldMapBitmap.bitmapData.clone();
    _window = new Rectangle(0, 0, width/TILE_SIZE, _map.height);
    _mapimage = new BitmapData(_window.width*TILE_SIZE, _map.height*TILE_SIZE);

    _world = new Bitmap(_mapimage);
    _world.x = (width-_mapimage.width)/2;
    _world.y = (height-_mapimage.height)/2;
    addChild(_world);

    _player = new Player(createSprite(0));
    addChild(_player);

    _status = new Status();
    _status.x = (width-_status.width)/2;
    _status.y = (height-_status.height-8);
    addChild(_status);

    _guide = new Guide();
    addChild(_guide);
  }

  // open()
  public override function open():void
  {
    _ticks = 0;

    _guide.visible = true;
    _guide.text = "HISTORY REPEATS ITSELF\n\nPRESS KEY TO START";
    _state = 1;
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

  // update()
  public override function update():void
  {
    switch (_state) {
    case 2:
      updateGame(_ticks);
      break;
    }
    _ticks++;
  }    

  // keydown(keycode)
  public override function keydown(keycode:int):void
  {
    switch (_state) {
    case 1:
      startGame();
      break;
    case 2:
      keydownGame(keycode);
      break;
    case 3:
      initGame();
      startGame();
      break;
    }
  }

  // keyup(keycode)
  public override function keyup(keycode:int):void 
  {
    switch (_state) {
    case 2:
      keyupGame(keycode);
      break;
    }
  }

  // keydownGame(keycode)
  private function keydownGame(keycode:int):void
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

  // keyupGame(keycode)
  private function keyupGame(keycode:int):void 
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

  // initGame()
  private function initGame():void
  {
    trace("initGame");
    _status.level = 1;
    _status.miss = 0;
    _status.time = 60;
    _status.speed = 10;
    _status.update();

    _map = worldMapBitmap.bitmapData.clone();
    _player.pos = new Point(_map.width/2, _map.height/2);
    _window.x = _player.pos.x-_window.width/2;
    updateGame(0);
  }

  // startGame()
  private function startGame():void
  {
    trace("startGame");
    _state = 2;
    _guide.visible = false;
  }

  // gameOver()
  private function gameOver():void
  {
    trace("gameOver");
    _state = 3;
    _guide.visible = true;
    _guide.text = "GAME OVER\n\nPRESS KEY TO RESTART";
  }

  // updateGame()
  private function updateGame(t:int):void
  {
    if (t % _status.speed == 0) {
      _window.x += 1;
    }
    
    var p:Point = _player.pos.clone();
    if (getMap(p.x+_player.vx, p.y+_player.vy) != LAND_COLOR) {
      p.x += _player.vx;
      p.y += _player.vy;
    }
    p.x = Utils.clamp(_window.left, p.x, _window.right-1);
    p.y = Utils.clamp(_window.top, p.y, _window.bottom-1);

    var c:uint = getMap(p.x, p.y);
    switch (c) {
    case LAND_COLOR:
      // CRUSHED!
      gameOver();
      return;
    }

    if (!_player.pos.equals(p)) {
      _map.setPixel(p.x % _map.width, p.y % _map.height, WHIRL_COLOR);
      _queue[_queue_push] = p;
      _queue_push = (_queue_push+1) % _queue.length;
      clearWhirl(_queue_pop);
      _queue_pop = (_queue_pop+1) % _queue.length;
      _player.pos = p;
    }

    {
      var di:int = Utils.rnd(_queue.length);
      di = Utils.rnd(di+1);
      clearWhirl(_queue_push-di);
    }

    renderTiles(_window);
    _player.x = _world.x + (_player.pos.x-_window.left) * TILE_SIZE;
    _player.y = _world.y + (_player.pos.y-_window.top) * TILE_SIZE;
  }

  // createSprite
  private function createSprite(i:int):BitmapData
  {
    var src:Rectangle = new Rectangle(i*TILE_SIZE, 0, TILE_SIZE, TILE_SIZE);
    var data:BitmapData = new BitmapData(TILE_SIZE, TILE_SIZE);
    data.copyPixels(spriteImages, src, new Point());
    return data;
  }

  // renderTiles
  private function renderTiles(r:Rectangle):void
  {
    for (var dy:int = 0; dy <= r.height; dy++) {
      for (var dx:int = 0; dx <= r.width; dx++) {
	var c:uint = getMap(r.x+dx, r.y+dy);
	var i:int = 1;
	switch (c) {
	case LAND_COLOR:
	  i = 2;
	  break;
	case WHIRL_COLOR:
	  i = 3;
	  break;
	}
	var src:Rectangle = new Rectangle(i*TILE_SIZE, 0, TILE_SIZE, TILE_SIZE);
	var dst:Point = new Point(dx*TILE_SIZE, dy*TILE_SIZE);
	_mapimage.copyPixels(spriteImages, src, dst);
      }
    }
  }

  // getMap
  private function getMap(x:int, y:int):uint
  {
    var w:int = _map.width;
    var h:int = _map.height;
    return _map.getPixel((x+w) % w, (y+h) % h);
  }

  // clearWhirl
  private function clearWhirl(i:int):void
  {
    i = (i+_queue.length) % _queue.length;
    var p:Point = _queue[i];
    if (p != null) {
      _map.setPixel(p.x % _map.width, p.y % _map.height, SEA_COLOR);
      _queue[i] = null;
    }
  }

}

} // package

import flash.display.Shape;
import flash.display.Sprite;
import flash.display.Bitmap;
import flash.display.BitmapData;
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
  public var speed:int;

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
  public const MARGIN:int = 16;
  public const ALPHA:Number = 0.7;

  private var _text:Bitmap;

  public function set text(v:String):void
  {
    if (_text != null) {
      removeChild(_text);
      _text = null;
    }
    if (v != null) {
      _text = Font.createText(v, 0xffffff, 2, 2);
      graphics.clear();
      graphics.beginFill(0, ALPHA);
      graphics.drawRect(0, 0, _text.width+MARGIN*2, _text.height+MARGIN*2);
      graphics.endFill();
      _text.x = (width-_text.width)/2;
      _text.y = (height-_text.height)/2;
      addChild(_text);
      
      if (parent != null) {
	this.x = (parent.width-this.width)/2;
	this.y = (parent.height-this.height)/2;
      }
    }
  }
}


//  Player
// 
class Player extends Bitmap
{
  public var vx:int;
  public var vy:int;
  public var pos:Point = new Point();

  public function Player(bitmapData:BitmapData) 
  {
    super(bitmapData);
  }
}
