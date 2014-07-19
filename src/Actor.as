package {

import flash.display.Shape;
import flash.geom.Rectangle;
import flash.geom.Point;
import flash.events.Event;
import flash.media.Sound;
import flash.media.SoundChannel;
import flash.media.SoundTransform;

//  Actor
// 
public class Actor extends Shape
{
  private var _maze:Maze;
  
  public function Actor(maze:Maze)
  {
    _maze = maze;
  }

  public function get maze():Maze
  {
    return _maze;
  }

  private var _sound:Sound;
  private var _channel:SoundChannel;

  private function onSoundComplete(e:Event):void
  {
    _channel = null;
    _sound = null;
  }

  protected function get playingSound():Sound
  {
    return _sound;
  }

  protected function get isPlayingSound():Boolean
  {
    return (_channel != null);
  }

  protected function playSound(sound:Sound):void
  {
    if (_channel == null) {
      _sound = sound;
      _channel = sound.play();
      _channel.addEventListener(Event.SOUND_COMPLETE, onSoundComplete);
    }
  }

  protected function stopSound():void
  {
    if (_channel != null) {
      _channel.stop();
      _channel = null;
      _sound = null;
    }
  }

  protected function setSoundTransform(volume:Number=1.0, pan:Number=0.0):void
  {
    if (_channel != null) {
      volume = Math.min(Math.max(volume, 0.0), 1.0);
      pan = Math.min(Math.max(pan, -1.0), 1.0);
      _channel.soundTransform = new SoundTransform(volume, pan);
    }
  }

  public virtual function get rect():Rectangle
  {
    return new Rectangle(x, y, _maze.cellSize, _maze.cellSize);
  }

  public virtual function update(t:int):void
  {
  }

  public virtual function makeNoise(dx:Number, dy:Number):void
  {
  }
}

} // package
