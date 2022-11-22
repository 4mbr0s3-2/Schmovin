/**
 * @ Author: 4mbr0s3 2
 * @ Create Time: 2021-06-22 11:55:58
 * @ Modified by: 4mbr0s3 2
 * @ Modified time: 2022-03-14 01:43:06
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

	public function getNoteMod(name:String)
	{
		return _mods.getModFromName(name);
	}

	public function getModList()
	{
		return _mods;
	}

	private function new() {}

	public function clearEvents()
	{
		for (key in _events.keys())
		{
			_events.set(key, []);
		}
	}

	public static function create(state:PlayState, instance:SchmovinInstance, playfields:SchmovinPlayfieldManager)
	{
		var timeline = new SchmovinTimeline();
		timeline._instance = instance;
		timeline._mods = new SchmovinNoteModList(state, timeline, playfields);
		timeline.initializeLists();
		return timeline;
	}

	public function getPath(currentBeat:Float, strumTime:Float, column:Int, player:Int, playfield:SchmovinPlayfield, exclude:Array<String> = null)
	{
		return _mods.getPath(currentBeat, strumTime, column, player, playfield, exclude);
	}

	public function getOtherMap(currentBeat:Float, strumTime:Float, column:Int, player:Int, playfield:SchmovinPlayfield, exclude:Array<String> = null)
	{
		return _mods.getOtherMap(currentBeat, strumTime, column, player, playfield, exclude);
	}

	public function getPreviousEvent(event:ISchmovinEvent):ISchmovinEvent
	{
		var eventList = _events.get(event.getModName()).filter((e) -> e.getPlayer() == event.getPlayer());
		if (eventList != null)
		{
			if (event.getIndex() < 0)
				event.setIndex(eventList.indexOf(event));

			var index = event.getIndex();
			if (index <= 0)
				return new SchmovinEventNull();
			return eventList[index - 1];
		}
		return new SchmovinEventNull();
	}

	public function initializeLists()
	{
		_events = new Map<String, Array<ISchmovinEvent>>();
		for (notemod in _mods.getNoteModsMap())
		{
			_events.set(notemod.getName(), new Array<ISchmovinEvent>());
		}
		_events.set('events', new Array<ISchmovinEvent>());
	}

	public function update(currentBeat:Float)
	{
		for (eventList in _events)
		{
			// TODO!!!
			// This is O(N); too many events will make the whole thing lag ;-;
			// Do a performance test with 1000 events... check if it's necessary to fix this
			// FIX: Pop finished events and use first event of array?
			for (event in eventList)
			{
				event.timelineUpdate(currentBeat);
			}
		}
		_mods.updateMiscMods(currentBeat);
	}

	public function updatePath(playfield:SchmovinPlayfield, currentBeat:Float, obj:FlxSprite, plr:Int, column:Int = 0)
	{
		return _mods.updatePath(playfield, currentBeat, obj, plr, column);
	}

	public function updateNote(playfield:SchmovinPlayfield, currentBeat:Float, obj:FlxSprite, pos:Vector4, plr:Int, column:Int = 0)
	{
		return _mods.updateNote(playfield, currentBeat, obj, pos, plr, column);
	}

	public function updateNoteVertex(playfield:SchmovinPlayfield, currentBeat:Float, obj:FlxSprite, vertex:Vector4, vertexIndex:Int, pos:Vector4,
			player:Int = 0, column:Int = 0, exclude:Array<String> = null)
	{
		return _mods.updateNoteVertex(currentBeat, obj, vertex, vertexIndex, pos, playfield, player, column, exclude);
	}

	public function addEvent(modName:String, event:ISchmovinEvent)
	{
		var mod = _events.get(modName);
		if (mod != null)
		{
			event.setTimeline(this);
			mod.push(event);
		}
	}

	public function removeEvent(modName:String, event:ISchmovinEvent)
	{
		var mod = _events.get(modName);
		if (mod != null)
			mod.remove(event);
	}

	private function getDefaultPlayfieldFromPlayer(p:Int)
	{
		return _instance.playfields.getPlayfieldAtIndex(p);
	}

	public function ease(beat:Float, length:Float, easeFunc:Float->Float, target:Float, mod:String, player:Int = -1)
	{
		if (player == -1)
		{
			for (p in 0...2)
				addEvent(mod, new SchmovinEventEase(beat, length, easeFunc, target, getNoteMod(mod), p, getDefaultPlayfieldFromPlayer(p)));
			return;
		}
		addEvent(mod, new SchmovinEventEase(beat, length, easeFunc, target, getNoteMod(mod), player, getDefaultPlayfieldFromPlayer(player)));
	}

	public function set(beat:Float, target:Float, mod:String, player:Int = -1)
	{
		if (player == -1)
		{
			for (p in 0...2)
				addEvent(mod, new SchmovinEventSet(beat, target, getNoteMod(mod), p, getDefaultPlayfieldFromPlayer(p)));
		}
		addEvent(mod, new SchmovinEventSet(beat, target, getNoteMod(mod), player, getDefaultPlayfieldFromPlayer(player)));
	}

	public function func(beat:Float, callback:Void->Void)
	{
		addEvent('events', new SchmovinEventFunction(beat, callback));
	}
}
