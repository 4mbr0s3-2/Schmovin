/**
 * @ Author: 4mbr0s3 2
 * @ Create Time: 2021-06-22 11:55:58
 * @ Modified by: 4mbr0s3 2
 * @ Modified time: 2022-03-07 21:45:22
 */

package schmovin;

import flixel.FlxSprite;
import haxe.Exception;
import lime.math.Vector4;
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
		return _mods.GetModByName(name);
	}

	public function GetModList()
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

	public static function Create(state:PlayState, instance:SchmovinInstance, playfields:SchmovinPlayfieldManager)
	{
		var timeline = new SchmovinTimeline();
		timeline._instance = instance;
		timeline._mods = new SchmovinNoteModList(state, timeline, playfields);
		timeline.InitializeLists();
		return timeline;
	}

	public function GetPath(currentBeat:Float, strumTime:Float, column:Int, player:Int, playfield:SchmovinPlayfield, exclude:Array<String> = null)
	{
		return _mods.GetPath(currentBeat, strumTime, column, player, playfield, exclude);
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
		for (notemod in _mods.GetNoteModsMap())
		{
			_events.set(notemod.GetName(), new Array<ISchmovinEvent>());
		}
		_events.set('events', new Array<ISchmovinEvent>());
	}

	public function Update(currentBeat:Float)
	{
		for (eventList in _events)
		{
			// TODO!!!
			// This is O(N); too many events will make the whole thing lag ;-;
			// Do a performance test with 1000 events... check if it's necessary to fix this
			// FIX: Pop finished events and use first event of array?
			for (event in eventList)
			{
				event.TimelineUpdate(currentBeat);
			}
		}
		_mods.UpdateMiscMods(currentBeat);
	}

	public function UpdatePath(playfield:SchmovinPlayfield, currentBeat:Float, obj:FlxSprite, plr:Int, column:Int = 0)
	{
		return _mods.UpdatePath(playfield, currentBeat, obj, plr, column);
	}

	public function UpdateNote(playfield:SchmovinPlayfield, currentBeat:Float, obj:FlxSprite, pos:Vector4, plr:Int, column:Int = 0)
	{
		return _mods.UpdateNote(playfield, currentBeat, obj, pos, plr, column);
	}

	public function UpdateNoteVertex(playfield:SchmovinPlayfield, currentBeat:Float, obj:FlxSprite, vertex:Vector4, vertexIndex:Int, pos:Vector4,
			player:Int = 0, column:Int = 0, exclude:Array<String> = null)
	{
		return _mods.UpdateNoteVertex(currentBeat, obj, vertex, vertexIndex, pos, playfield, player, column, exclude);
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

	function GetDefaultPlayfieldFromPlayer(p:Int)
	{
		return _instance.playfields.GetPlayfieldAtIndex(p);
	}

	public function Ease(beat:Float, length:Float, easeFunc:Float->Float, target:Float, mod:String, player:Int = -1)
	{
		if (player == -1)
		{
			for (p in 0...2)
				AddEvent(mod, new SchmovinEventEase(beat, length, easeFunc, target, GetNoteMod(mod), p, GetDefaultPlayfieldFromPlayer(p)));
			return;
		}
		AddEvent(mod, new SchmovinEventEase(beat, length, easeFunc, target, GetNoteMod(mod), player, GetDefaultPlayfieldFromPlayer(player)));
	}

	public function Set(beat:Float, target:Float, mod:String, player:Int = -1)
	{
		if (player == -1)
		{
			for (p in 0...2)
				AddEvent(mod, new SchmovinEventSet(beat, target, GetNoteMod(mod), p, GetDefaultPlayfieldFromPlayer(p)));
		}
		AddEvent(mod, new SchmovinEventSet(beat, target, GetNoteMod(mod), player, GetDefaultPlayfieldFromPlayer(player)));
	}

	public function Func(beat:Float, callback:Void->Void)
	{
		AddEvent('events', new SchmovinEventFunction(beat, callback));
	}
}
