package {

import flash.media.Sound;
import flash.events.SampleDataEvent;

//  SoundGenerator
//
public class SoundGenerator extends Sound
{
  public static function getPitch(note:String):int
  {
    return Frequencies[note];
  }

  private const SAMPLES:int = 8192;

  public function SoundGenerator()
  {
    addEventListener(SampleDataEvent.SAMPLE_DATA, onSampleData);
  }

  private var envelope:SampleGenerator;
  private var tone:SampleGenerator;

  private function onSampleData(e:SampleDataEvent):void
  {
    for (var d:int = 0; d < SAMPLES; d++) {
      var i:int = e.position+d;
      var x:Number;
      try {
	x = envelope.getSample(i) * tone.getSample(i);
      } catch (error:ArgumentError) {
	break;
      }
      e.data.writeFloat(x); // L
      e.data.writeFloat(x); // R
    }
  }

  public function setConstantEnvelope(value:Number):SoundGenerator
  {
    envelope = new ConstantEnvelopeGenerator(value);
    return this;
  }

  public function setCutoffEnvelope(duration:Number):SoundGenerator
  {
    envelope = new CutoffEnvelopeGenerator(duration);
    return this;
  }

  public function setDecayEnvelope(attack:Number,
				   decay:Number,
				   cutoff:Number=0,
				   nrepeat:int=1):SoundGenerator
  {
    envelope = new DecayEnvelopeGenerator(attack, decay, cutoff, nrepeat);
    return this;
  }

  public function setConstSineTone(pitch:Number):SoundGenerator
  {
    return setSineTone(function (t:Number):Number { return pitch; });
  }
  
  public function setConstRectTone(pitch:Number):SoundGenerator
  {
    return setRectTone(function (t:Number):Number { return pitch; });
  }

  public function setConstSawTone(pitch:Number):SoundGenerator
  {
    return setSawTone(function (t:Number):Number { return pitch; });
  }

  public function setConstNoise(pitch:Number):SoundGenerator
  {
    return setNoise(function (t:Number):Number { return pitch; });
  }

  public function setSineTone(pitchfunc:Function):SoundGenerator
  {
    tone = new SineToneGenerator(pitchfunc);
    return this;
  }
  
  public function setRectTone(pitchfunc:Function):SoundGenerator
  {
    tone = new RectToneGenerator(pitchfunc);
    return this;
  }

  public function setSawTone(pitchfunc:Function):SoundGenerator
  {
    tone = new SawToneGenerator(pitchfunc);
    return this;
  }

  public function setNoise(pitchfunc:Function):SoundGenerator
  {
    tone = new NoiseGenerator(pitchfunc);
    return this;
  }
  
}

} // package

class SampleGenerator
{
  protected const FRAMERATE:int = 44100;

  public virtual function getSample(i:int):Number
  {
    throw new ArgumentError();    
  }
}

class ConstantEnvelopeGenerator extends SampleGenerator
{
  public function ConstantEnvelopeGenerator(value:Number=0.0)
  {
    this.value = value;
  }

  public var value:Number = 0.0;

  public override function getSample(i:int):Number
  {
    return value;
  }
}

class CutoffEnvelopeGenerator extends SampleGenerator
{
  public function CutoffEnvelopeGenerator(duration:Number)
  {
    this.duration = duration;
  }

  private var _frames:int;
  public function set duration(v:Number):void
  {
    _frames = Math.floor(v*FRAMERATE);
  }

  public override function getSample(i:int):Number
  {
    if (i == 0 || i == _frames) {
      return 0.0;
    } else if (i < _frames) {
      return 1.0;
    } else {
      throw new ArgumentError();
    }
  }
}

class DecayEnvelopeGenerator extends SampleGenerator
{
  public function DecayEnvelopeGenerator(attack:Number,
					 decay:Number,
					 cutoff:Number=0,
					 nrepeat:int=1)
  {
    this.attack = attack;
    this.decay = decay;
    this.cutoff = cutoff;
    this.nrepeat = nrepeat;
  }

  private var _attackframes:int;
  public function set attack(v:Number):void
  {
    _attackframes = Math.floor(v*FRAMERATE);
    update();
  }

  private var _decayframes:int;
  public function set decay(v:Number):void
  {
    _decayframes = Math.floor(v*FRAMERATE);
    update();
  }

  private var _cutoffframes:int;
  public function set cutoff(v:Number):void
  {
    _cutoffframes = Math.floor(v*FRAMERATE);
    update();
  }

  private var _nrepeat:int;
  public function set nrepeat(v:int):void
  {
    _nrepeat = v;
    update();
  }

  private var _repeatframes:int;
  private var _total1frames:int;
  private var _total2frames:int;
  private function update():void
  {
    if (_cutoffframes == 0) {
      _cutoffframes = _decayframes;
    }
    _repeatframes = (_attackframes+_cutoffframes);
    _total1frames = _repeatframes*(_nrepeat-1);
    _total2frames = _total1frames+(_attackframes+_decayframes);
  }

  public override function getSample(i:int):Number
  {
    if (_total2frames <= i) throw new ArgumentError();

    if (_total1frames <= i) {
      i -= _total1frames;
    } else {
      i = (i % _repeatframes);
    }
    if (i < _attackframes) {
      return i/_attackframes;
    } else {
      return 1.0 - (i-_attackframes)/_decayframes;
    }
  }
}

class SineToneGenerator extends SampleGenerator
{
  public var pitchfunc:Function;

  public function SineToneGenerator(pitchfunc:Function)
  {
    this.pitchfunc = pitchfunc;
  }

  public override function getSample(i:int):Number
  {
    var pitch:Number = pitchfunc(i/FRAMERATE);
    return Math.sin(2.0*Math.PI*pitch / FRAMERATE);
  }
}

class RectToneGenerator extends SampleGenerator
{
  public var pitchfunc:Function;

  public function RectToneGenerator(pitchfunc:Function)
  {
    this.pitchfunc = pitchfunc;
  }

  private var _i0:int = 0;
  private var _i1:int = 0;
  private var _i2:int = 0;
  public override function getSample(i:int):Number
  {
    if (i < _i0) {
      _i0 = 0;
      _i1 = 0;
      _i2 = 0;
    }
    if (_i2 <= i) {
      var pitch:Number = pitchfunc(i/FRAMERATE);
      var d:int = Math.floor(FRAMERATE/pitch/2);
      _i0 = i;
      _i1 = i+d;
      _i2 = i+d+d;
    }
    return (i < _i1)? +1 : -1;
  }
}

class SawToneGenerator extends SampleGenerator
{
  public var pitchfunc:Function;

  public function SawToneGenerator(pitchfunc:Function)
  {
    this.pitchfunc = pitchfunc;
  }

  private var _i0:int = 0;
  private var _i1:int = 0;
  public override function getSample(i:int):Number
  {
    if (i < _i0) {
      _i0 = 0;
      _i1 = 0;
    }
    if (_i1 <= i) {
      var pitch:Number = pitchfunc(i/FRAMERATE);
      _i0 = i;
      _i1 = i+Math.floor(FRAMERATE/pitch);
    }
    return (i-_i0)/(_i1-_i0)*2-1;
  }
}

class NoiseGenerator extends SampleGenerator
{
  public var pitchfunc:Function;

  public function NoiseGenerator(pitchfunc:Function)
  {
    this.pitchfunc = pitchfunc;
  }

  private var _i0:int = 0;
  private var _i1:int = 0;
  private var _x:Number;
  public override function getSample(i:int):Number
  {
    if (i < _i0) {
      _i0 = 0;
      _i1 = 0;
    }
    if (_i1 <= i) {
      var pitch:Number = pitchfunc(i/FRAMERATE);
      _i0 = i;
      _i1 = i+Math.floor(FRAMERATE/pitch/2);
      _x = Math.random()*2-1;
    }
    return _x;
  }
}

class MixSoundGenerator extends SampleGenerator
{
  public var generators:Vector.<SampleGenerator>;

  public function MixSoundGenerator(generators:Vector.<SampleGenerator>)
  {
    this.generators = generators;
  }

  public override function getSample(i:int):Number
  {
    var v:Number = 0;
    for each (var g:SampleGenerator in generators) {
      v += g.getSample(i);
    }
    return v/generators.length;
  }
}

class Frequencies extends Object
{
  public static const A0:int = 28;
  public static const A0s:int = 29;
  public static const B0:int = 31;
  public static const C1:int = 33;
  public static const C1s:int = 35;
  public static const D1:int = 37;
  public static const D1s:int = 39;
  public static const E1:int = 41;
  public static const F1:int = 44;
  public static const F1s:int = 46;
  public static const G1:int = 49;
  public static const G1s:int = 52;
  public static const A1:int = 55;
  public static const A1s:int = 58;
  public static const B1:int = 62;
  public static const C2:int = 65;
  public static const C2s:int = 69;
  public static const D2:int = 73;
  public static const D2s:int = 78;
  public static const E2:int = 82;
  public static const F2:int = 87;
  public static const F2s:int = 93;
  public static const G2:int = 98;
  public static const G2s:int = 104;
  public static const A2:int = 110;
  public static const A2s:int = 117;
  public static const B2:int = 123;
  public static const C3:int = 131;
  public static const C3s:int = 139;
  public static const D3:int = 147;
  public static const D3s:int = 156;
  public static const E3:int = 165;
  public static const F3:int = 175;
  public static const F3s:int = 185;
  public static const G3:int = 196;
  public static const G3s:int = 208;
  public static const A3:int = 220;
  public static const A3s:int = 233;
  public static const B3:int = 247;
  public static const C4:int = 262;
  public static const C4s:int = 277;
  public static const D4:int = 294;
  public static const D4s:int = 311;
  public static const E4:int = 330;
  public static const F4:int = 349;
  public static const F4s:int = 370;
  public static const G4:int = 392;
  public static const G4s:int = 415;
  public static const A4:int = 440;
  public static const A4s:int = 466;
  public static const B4:int = 494;
  public static const C5:int = 523;
  public static const C5s:int = 554;
  public static const D5:int = 587;
  public static const D5s:int = 622;
  public static const E5:int = 659;
  public static const F5:int = 698;
  public static const F5s:int = 740;
  public static const G5:int = 784;
  public static const G5s:int = 831;
  public static const A5:int = 880;
  public static const A5s:int = 932;
  public static const B5:int = 988;
  public static const C6:int = 1047;
  public static const C6s:int = 1109;
  public static const D6:int = 1175;
  public static const D6s:int = 1245;
  public static const E6:int = 1319;
  public static const F6:int = 1397;
  public static const F6s:int = 1480;
  public static const G6:int = 1568;
  public static const G6s:int = 1661;
  public static const A6:int = 1760;
  public static const A6s:int = 1865;
  public static const B6:int = 1976;
  public static const C7:int = 2093;
  public static const C7s:int = 2217;
  public static const D7:int = 2349;
  public static const D7s:int = 2489;
  public static const E7:int = 2637;
  public static const F7:int = 2794;
  public static const F7s:int = 2960;
  public static const G7:int = 3136;
  public static const G7s:int = 3322;
  public static const A7:int = 3520;
  public static const A7s:int = 3729;
  public static const B7:int = 3951;
  public static const C8:int = 4186;
}
