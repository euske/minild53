package {

import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.media.Sound;
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
  private var _invul_count:int;
  private var _start_time:int;

  public const TILE_SIZE:int = 16;
  public const QUEUE_SIZE:int = 1024;
  public const INVUL_COUNT:int = 32;
  public const SEA_COLOR:int = 0xffffff;
  public const LAND_COLOR:int = 0x000000;
  public const WHIRL_COLOR:int = 0xff0000;
  public const TARGET_COLOR:int = 0x00ff00;

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

  // getMap
  private function getMap(x:int, y:int):uint
  {
    var w:int = _map.width;
    var h:int = _map.height;
    return _map.getPixel((x+w) % w, (y+h) % h);
  }

  // setMap
  private function setMap(x:int, y:int, c:uint):void
  {
    var w:int = _map.width;
    var h:int = _map.height;
    _map.setPixel((x+w) % w, (y+h) % h, c);
  }

  // initGame()
  private function initGame():void
  {
    trace("initGame");
    _status.score = 0;
    _status.life = 3;
    _status.time = 0;
    _status.update();
    _start_time = getTimer();

    _map = worldMapBitmap.bitmapData.clone();

    _player.pos = new Point(_map.width/2, _map.height/2);

    _window.x = _player.pos.x-_window.width/2;

    for (var i:int = 0; i < 10; i++) {
      placeTarget();
    }

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
    var speed:int = 10;
    if (t % speed == 0) {
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
    case WHIRL_COLOR:
      if (_invul_count == 0) {
	if (_status.life == 0) {
	  gameOver();
	  return;
	}
	_status.life--;
	_invul_count = INVUL_COUNT;
      }
      break;
    case TARGET_COLOR:
      setMap(p.x, p.y, SEA_COLOR);
      _status.score++;
      break;
    }

    if (!_player.pos.equals(p)) {
      setMap(_player.pos.x, _player.pos.y, WHIRL_COLOR);
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
    if (0 < _invul_count) {
      _invul_count--;
      _player.visible = (_invul_count == 0 || (Math.floor(_invul_count/4)%2 == 0));
    }

    _status.time = (getTimer()-_start_time)/1000;
    _status.update();
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
	case TARGET_COLOR:
	  i = 4;
	  break;
	}
	var src:Rectangle = new Rectangle(i*TILE_SIZE, 0, TILE_SIZE, TILE_SIZE);
	var dst:Point = new Point(dx*TILE_SIZE, dy*TILE_SIZE);
	_mapimage.copyPixels(spriteImages, src, dst);
      }
    }
  }

  // placeTarget
  private function placeTarget():void
  {
    for (var i:int = 0; i < 10; i++) {
      var x:int = Utils.rnd(_map.width);
      var y:int = Utils.rnd(_map.height);
      if (getMap(x, y) == SEA_COLOR) {
	setMap(x,y, TARGET_COLOR);
	break;
      }
    }
  }

  // clearWhirl
  private function clearWhirl(i:int):void
  {
    i = (i+_queue.length) % _queue.length;
    var p:Point = _queue[i];
    if (p != null) {
      setMap(p.x, p.y, SEA_COLOR);
      _queue[i] = null;
    }
  }

}

} // package

import flash.display.Shape;
import flash.display.Sprite;
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.geom.Rectangle;
import flash.geom.Point;
import baseui.Font;


//  Status
// 
class Status extends Sprite
{
  public var score:int;
  public var life:int;
  public var time:int;

  private var _text:Bitmap;

  public function Status()
  {
    _text = Font.createText("SCORE: 000   LIFE: 00   TIME: 000", 0xffffff, 0, 2);
    addChild(_text);
  }

  public function update():void
  {
    var text:String = "SCORE: "+Utils.format(score,3);
    text += "   LIFE: "+Utils.format(life,2);
    text += "   TIME: "+Utils.format(time,3);
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
