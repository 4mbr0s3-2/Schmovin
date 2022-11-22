/**
 * @ Author: 4mbr0s3 2
 * @ Create Time: 2021-06-22 13:03:47
 * @ Modified by: 4mbr0s3 2
 * @ Modified time: 2022-03-07 20:07:01
 */

package schmovin;

import flixel.math.FlxMath;
import schmovin.SchmovinTimeline;
import schmovin.note_mods.ISchmovinNoteMod.ISchmovinNoteMod;

interface ISchmovinEvent
{
	public function timelineUpdate(currentBeat:Float):Void;
	public function getModName():String;
	public function getPlayer():Int;
	public function getPlayfield():SchmovinPlayfield;
	public function getTargetPercent(player:Int):Float;
	public function setTimeline(t:SchmovinTimeline):Void;
	public function getIndex():Int;
	public function setIndex(index:Int):Void;
	public function getBeat():Float;
	public function getBeatLength():Float;
}

class SchmovinEventNull implements ISchmovinEvent
{
	var _timeline:SchmovinTimeline;

	public function new() {}

	public function timelineUpdate(currentBeat:Float) {}

	// (Violates interface segregation)
	public function getTargetPercent(player:Int)
	{
		return 0;
	}

	public function getModName()
	{
		return null;
	}

	public function setTimeline(t:SchmovinTimeline)
	{
		_timeline = t;
	}

	public function getPlayer()
	{
		return 0;
	}

	public function getPlayfield()
	{
		return new SchmovinPlayfield(_timeline.getModList());
	}

	public function getBeat()
	{
		return 0;
	}

	public function getBeatLength()
	{
		return 0;
	}

	public function getIndex()
	{
		return -1;
	}

	public function setIndex(index:Int) {}
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

	public function getPlayfield()
	{
		return _playfield;
	}

	public function getBeat()
	{
		return _beat;
	}

	public function getBeatLength()
	{
		return _length;
	}

	public function getIndex()
	{
		return _index;
	}

	public function setIndex(index:Int)
	{
		_index = index;
	}

	public function setTimeline(t:SchmovinTimeline)
	{
		_timeline = t;
	}

	public function getPreviousEvent()
	{
		return _timeline.getPreviousEvent(this);
	}

	public function getPlayer()
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

	public function getModName()
	{
		return _mod.getName();
	}

	public function getTargetPercent(player:Int)
	{
		return _targetPercent;
	}

	public function timelineUpdate(currentBeat:Float)
	{
		var endBeat = _beat + _length;
		var isOverlapping = currentBeat > _beat && currentBeat <= endBeat;

		if (isOverlapping)
		{
			// Costly, so we're moving it here (when it's actually needed)
			var lastPercent = getPreviousEvent().getTargetPercent(_player);

			_done = false;
			var progress = (currentBeat - _beat) / _length;
			var percent = FlxMath.lerp(lastPercent, _targetPercent, _easeFunction(progress));
			_playfield.setPercent(_mod.getName(), percent);
		}
		else if (!_done && currentBeat > endBeat) // Reached the end
		{
			_done = true;
			_playfield.setPercent(_mod.getName(), _targetPercent);
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

	public function getPlayfield()
	{
		return _playfield;
	}

	public function getBeat()
	{
		return _beat;
	}

	public function getBeatLength()
	{
		return 0;
	}

	public function getIndex()
	{
		return _index;
	}

	public function setIndex(index:Int)
	{
		_index = index;
	}

	public function getPreviousEvent()
	{
		return _timeline.getPreviousEvent(this);
	}

	public function getModName()
	{
		return _mod.getName();
	}

	public function getPlayer()
	{
		return _player;
	}

	public function setTimeline(t:SchmovinTimeline)
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

	public function getTargetPercent(player:Int)
	{
		return _targetPercent;
	}

	public function timelineUpdate(currentBeat:Float)
	{
		// var prevEvent = getPreviousEvent();
		// var isOverlapping = currentBeat <= _beat && currentBeat > prevEvent.getBeat() + prevEvent.getBeatLength();
		var isOverlapping = currentBeat <= _beat;
		if (isOverlapping)
		{
			// _mod.setPercent(prevEvent.getTargetPercent(_player), _player);
			_done = false;
		}
		else if (!_done)
		{
			_playfield.setPercent(_mod.getName(), _targetPercent);
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

	public function getPlayfield()
	{
		return new SchmovinPlayfield(_timeline.getModList());
	}

	public function getBeat()
	{
		return _beat;
	}

	public function getBeatLength()
	{
		return 0;
	}

	public function getIndex()
	{
		return -1;
	}

	public function setIndex(index:Int) {}

	public function getModName()
	{
		return null;
	}

	public function setTimeline(t:SchmovinTimeline)
	{
		_timeline = t;
	}

	public function getPlayer()
	{
		return -1;
	}

	public function new(beat:Float, callback:Void->Void)
	{
		_beat = beat;
		_callback = callback;
	}

	public function timelineUpdate(currentBeat:Float):Void
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
	public function getTargetPercent(player:Int):Float
	{
		return 0;
	}
}
