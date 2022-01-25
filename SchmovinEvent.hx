/**
 * @ Author: 4mbr0s3 2
 * @ Create Time: 2021-06-22 13:03:47
 * @ Modified by: 4mbr0s3 2
 * @ Modified time: 2021-12-01 00:09:19
 */

package schmovin;

import flixel.math.FlxMath;
import schmovin.SchmovinTimeline;
import schmovin.note_mods.ISchmovinNoteMod.ISchmovinNoteMod;

interface ISchmovinEvent
{
	public function TimelineUpdate(currentBeat:Float):Void;
	public function GetModName():String;
	public function GetPlayer():Int;
	public function GetPlayfield():SchmovinPlayfield;
	public function GetTargetPercent(player:Int):Float;
	public function SetTimeline(t:SchmovinTimeline):Void;
	public function GetIndex():Int;
	public function SetIndex(index:Int):Void;
	public function GetBeat():Float;
	public function GetBeatLength():Float;
}

class SchmovinEventNull implements ISchmovinEvent
{
	var _timeline:SchmovinTimeline;

	public function new() {}

	public function TimelineUpdate(currentBeat:Float) {}

	// (Violates interface segregation)
	public function GetTargetPercent(player:Int)
	{
		return 0;
	}

	public function GetModName()
	{
		return null;
	}

	public function SetTimeline(t:SchmovinTimeline)
	{
		_timeline = t;
	}

	public function GetPlayer()
	{
		return 0;
	}

	public function GetPlayfield()
	{
		return new SchmovinPlayfield();
	}

	public function GetBeat()
	{
		return 0;
	}

	public function GetBeatLength()
	{
		return 0;
	}

	public function GetIndex()
	{
		return -1;
	}

	public function SetIndex(index:Int) {}
}

class SchmovinEventEase implements ISchmovinEvent
{
	var _beat:Float = 0;
	var _length:Float = 0;
	var _easeFunction:Float->Float;
	var _targetPercent:Float = 0;
	var _mod:ISchmovinNoteMod;
	var _player:Int = 0;
	var _done = false;
	var _timeline:SchmovinTimeline;
	var _index = -1;
	var _playfield:SchmovinPlayfield;

	public function GetPlayfield()
	{
		return _playfield;
	}

	public function GetBeat()
	{
		return _beat;
	}

	public function GetBeatLength()
	{
		return _length;
	}

	public function GetIndex()
	{
		return _index;
	}

	public function SetIndex(index:Int)
	{
		_index = index;
	}

	public function SetTimeline(t:SchmovinTimeline)
	{
		_timeline = t;
	}

	public function GetPreviousEvent()
	{
		return _timeline.GetPreviousEvent(this);
	}

	public function GetPlayer()
	{
		return _player;
	}

	public function new(beat:Float, length:Float, easeFunc:Float->Float, targetPercent:Float, mod:ISchmovinNoteMod, player:Int, playfield:SchmovinPlayfield)
	{
		_beat = beat;
		_length = length;
		_easeFunction = easeFunc;
		_targetPercent = targetPercent;
		_mod = mod;
		_player = player;
		_playfield = playfield;
	}

	public function GetModName()
	{
		return _mod.GetName();
	}

	public function GetTargetPercent(player:Int)
	{
		return _targetPercent;
	}

	public function TimelineUpdate(currentBeat:Float)
	{
		var endBeat = _beat + _length;
		var isOverlapping = currentBeat > _beat && currentBeat <= endBeat;

		if (isOverlapping)
		{
			// Costly, so we're moving it here (when it's actually needed)
			var lastPercent = GetPreviousEvent().GetTargetPercent(_player);

			_done = false;
			var progress = (currentBeat - _beat) / _length;
			var percent = FlxMath.lerp(lastPercent, _targetPercent, _easeFunction(progress));
			_mod.SetPercent(percent, _playfield);
		}
		else if (!_done && currentBeat > endBeat) // Reached the end
		{
			_done = true;
			_mod.SetPercent(_targetPercent, _playfield);
		}
	}
}

class SchmovinEventSet implements ISchmovinEvent
{
	var _timeline:SchmovinTimeline;
	var _beat:Float = 0;
	var _targetPercent:Float = 0;
	var _mod:ISchmovinNoteMod;
	var _player:Int = 0;
	var _done = false;
	var _index = -1;
	var _playfield:SchmovinPlayfield;

	public function GetPlayfield()
	{
		return _playfield;
	}

	public function GetBeat()
	{
		return _beat;
	}

	public function GetBeatLength()
	{
		return 0;
	}

	public function GetIndex()
	{
		return _index;
	}

	public function SetIndex(index:Int)
	{
		_index = index;
	}

	public function GetPreviousEvent()
	{
		return _timeline.GetPreviousEvent(this);
	}

	public function GetModName()
	{
		return _mod.GetName();
	}

	public function GetPlayer()
	{
		return _player;
	}

	public function SetTimeline(t:SchmovinTimeline)
	{
		_timeline = t;
	}

	public function new(beat:Float, targetPercent:Float, mod:ISchmovinNoteMod, player:Int, playfield:SchmovinPlayfield)
	{
		_beat = beat;
		_targetPercent = targetPercent;
		_mod = mod;
		_player = player;
		_playfield = playfield;
	}

	public function GetTargetPercent(player:Int)
	{
		return _targetPercent;
	}

	public function TimelineUpdate(currentBeat:Float)
	{
		// var prevEvent = GetPreviousEvent();
		// var isOverlapping = currentBeat <= _beat && currentBeat > prevEvent.GetBeat() + prevEvent.GetBeatLength();
		var isOverlapping = currentBeat <= _beat;
		if (isOverlapping)
		{
			// _mod.SetPercent(prevEvent.GetTargetPercent(_player), _player);
			_done = false;
		}
		else if (!_done)
		{
			_mod.SetPercent(_targetPercent, _playfield);
			_done = true;
		}
	}
}

class SchmovinEventFunction implements ISchmovinEvent
{
	var _timeline:SchmovinTimeline;
	var _callback:Void->Void;
	var _done = false;
	var _beat:Float;

	public function GetPlayfield()
	{
		return new SchmovinPlayfield();
	}

	public function GetBeat()
	{
		return _beat;
	}

	public function GetBeatLength()
	{
		return 0;
	}

	public function GetIndex()
	{
		return -1;
	}

	public function SetIndex(index:Int) {}

	public function GetModName()
	{
		return null;
	}

	public function SetTimeline(t:SchmovinTimeline)
	{
		_timeline = t;
	}

	public function GetPlayer()
	{
		return -1;
	}

	public function new(beat:Float, callback:Void->Void)
	{
		_beat = beat;
		_callback = callback;
	}

	public function TimelineUpdate(currentBeat:Float):Void
	{
		var isOverlapping = currentBeat <= _beat;
		if (isOverlapping)
		{
			_done = false;
		}
		else if (!_done)
		{
			_callback();
			_done = true;
		}
	}

	// Violates interface segregation lol
	public function GetTargetPercent(player:Int):Float
	{
		return 0;
	}
}
