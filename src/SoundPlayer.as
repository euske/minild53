package {

import flash.events.Event;
import flash.media.Sound;
import flash.media.SoundChannel;
import flash.media.SoundTransform;

//  SoundPlayer
//
public class SoundPlayer extends Object
{
  public var soundTransform:SoundTransform;

  public function SoundPlayer()
  {
    _playlist = new Vector.<Sound>();
  }

  public function addSound(sound:Sound):void
  {
    _playlist.push(sound);
    update();
  }

  public function get isPlaying():Boolean
  {
    return _playing;
  }

  public function set isPlaying(v:Boolean):void
  {
    _playing = v;
    if (_playing) {
      update();
    } else {
      if (_channel != null) {
	_lastpos = _channel.position;
	_channel.stop();
	_channel.removeEventListener(Event.SOUND_COMPLETE, onSoundComplete);
	_channel = null;
      }
    }
  }

  private var _playing:Boolean;
  private var _lastpos:Number;
  private var _channel:SoundChannel;
  private var _playlist:Vector.<Sound>;

  private function update():void
  {
    if (_channel != null) return;
    if (_playing && 0 < _playlist.length) {
      var sound:Sound = _playlist[0];
      _channel = sound.play(_lastpos, 0, soundTransform);
      _channel.addEventListener(Event.SOUND_COMPLETE, onSoundComplete);
    }
  }

  private function onSoundComplete(e:Event):void
  {
    _lastpos = 0;
    _channel.removeEventListener(Event.SOUND_COMPLETE, onSoundComplete);
    _channel = null;
    _playlist.shift();
    update();
  }
}

} // package
