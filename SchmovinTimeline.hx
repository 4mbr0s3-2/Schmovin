/**
 * @ Author: 4mbr0s3 2
 * @ Create Time: 2021-06-22 11:55:58
 * @ Modified by: 4mbr0s3 2
 * @ Modified time: 2021-09-26 16:06:07
 */

package schmovin;

import flixel.FlxSprite;
import schmovin.SchmovinEvent;
import schmovin.SchmovinInstance;

using schmovin.SchmovinUtil;

class SchmovinTimeline
{
	@:allow(schmovin.overlays.SchmovinDebugger)
	private var _mods:SchmovinNoteModList;
	@:allow(schmovin.overlays.SchmovinDebugger)
	private var _events:Map<String, Array<ISchmovinEvent>>;
	private var _time:Float = 0;
	@:allow(schmovin.SchmovinNoteModList)
	private var _instance:SchmovinInstance;

	public function GetNoteMod(name:String)
	{
		return _mods.GetNoteModByName(name);
	}

	@:allow(schmovin.SchmovinClient, schmovin.overlays.SchmovinDebugger)
	private function GetModList()
	{
		return _mods;
	}

	private function new() {}

	public function ClearEvents()
	{
		for (key in _events.keys())
		{
			_events.set(key, []);
		}
	}

	public static function Create(state:PlayState, instance:SchmovinInstance)
	{
		var timeline = new SchmovinTimeline();
		timeline._instance = instance;
		timeline._mods = new SchmovinNoteModList(state, timeline);
		timeline.InitializeLists();
		return timeline;
	}

	public function GetPath(currentBeat:Float, strumTime:Float, column:Int, player:Int)
	{
		return _mods.GetPath(currentBeat, strumTime, column, player);
	}

	public function GetPreviousEvent(event:ISchmovinEvent):ISchmovinEvent
	{
		var eventList = _events.get(event.GetModName()).filter((e) -> e.GetPlayer() == event.GetPlayer());
		if (eventList != null)
		{
			if (event.GetIndex() < 0)
				event.SetIndex(eventList.indexOf(event));

			var index = event.GetIndex();
			if (index <= 0)
				return new SchmovinEventNull();
			return eventList[index - 1];
		}
		return new SchmovinEventNull();
	}

	public function InitializeLists()
	{
		_events = new Map<String, Array<ISchmovinEvent>>();
		for (notemod in _mods.GetNoteModsMap().keys())
		{
			_events.set(notemod, new Array<ISchmovinEvent>());
		}
		_events.set('events', new Array<ISchmovinEvent>());
	}

	public function Update(currentBeat:Float)
	{
		for (eventList in _events)
		{
			for (event in eventList)
			{
				event.TimelineUpdate(currentBeat);
			}
		}
		_mods.UpdateMiscMods(currentBeat);
	}

	public function UpdateNotes(currentBeat:Float, obj:FlxSprite, plr:Int, column:Int = 0)
	{
		_mods.Update(currentBeat, obj, plr, column);
	}

	public function AddEvent(modName:String, event:ISchmovinEvent)
	{
		var mod = _events.get(modName);
		if (mod != null)
		{
			event.SetTimeline(this);
			mod.push(event);
		}
	}

	public function RemoveEvent(modName:String, event:ISchmovinEvent)
	{
		var mod = _events.get(modName);
		if (mod != null)
			mod.remove(event);
	}

	public function Ease(beat:Float, length:Float, easeFunc:Float->Float, target:Float, mod:String, player:Int = -1)
	{
		if (player == -1)
		{
			for (p in 0...2)
				AddEvent(mod, new SchmovinEventEase(beat, length, easeFunc, target, GetNoteMod(mod), p));
			return;
		}
		AddEvent(mod, new SchmovinEventEase(beat, length, easeFunc, target, GetNoteMod(mod), player));
	}

	public function Set(beat:Float, target:Float, mod:String, player:Int = -1)
	{
		if (player == -1)
		{
			for (p in 0...2)
				AddEvent(mod, new SchmovinEventSet(beat, target, GetNoteMod(mod), p));
		}
		AddEvent(mod, new SchmovinEventSet(beat, target, GetNoteMod(mod), player));
	}

	public function Func(beat:Float, callback:Void->Void)
	{
		AddEvent('events', new SchmovinEventFunction(beat, callback));
	}
}
