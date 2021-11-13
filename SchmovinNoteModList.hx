/**
 * @ Author: 4mbr0s3 2
 * @ Create Time: 2021-06-22 12:04:54
 * @ Modified by: 4mbr0s3 2
 * @ Modified time: 2021-11-13 13:19:28
 */

package schmovin;

import flixel.FlxSprite;
import lime.math.Vector4;
import schmovin.Registry;
import schmovin.SchmovinTimeline;
import schmovin.note_mods.ISchmovinNoteMod;
import schmovin.note_mods.NoteModBase;

using StringTools;
using schmovin.SchmovinUtil;

class SchmovinNoteModList
{
	var _state:PlayState;
	@:allow(schmovin.overlays.SchmovinDebugger)
	var _mods:Map<String, ISchmovinNoteMod>;
	var _modNameOrder:Array<String>;
	var _timeline:SchmovinTimeline;

	public function new(state:PlayState, timeline:SchmovinTimeline)
	{
		_timeline = timeline;
		_state = state;
		_mods = new Map<String, ISchmovinNoteMod>();
		_modNameOrder = [];
		InitializeNoteMods();
	}

	@:allow(schmovin.note_mods.ISchmovinNoteMod, schmovin.Registry)
	function GetSchmovinInstance()
	{
		return _timeline._instance;
	}

	public function GetNoteModsMap()
	{
		return _mods;
	}

	public function InitializeNoteMods()
	{
		new Registry(this, _state).Register();
	}

	public function AddNoteMod(modName:String, mod:ISchmovinNoteMod, putInOrderedList:Bool = true)
	{
		mod.SetName(modName);
		_mods.set(modName, mod);
		if (putInOrderedList)
			_modNameOrder.push(modName);
	}

	public function AddNoteModBefore(beforeModName:String, modName:String, mod:ISchmovinNoteMod, putInOrderedList:Bool = true)
	{
		mod.SetName(modName);
		_mods.set(modName, mod);
		if (putInOrderedList)
			_modNameOrder.insert(_modNameOrder.indexOf(beforeModName), modName);
	}

	public function AddNoteSubMod(modName:String)
	{
		AddNoteMod(modName, new NoteModBase(_state, this, false));
	}

	public function GetNoteModByName(modName:String)
	{
		return _mods.get(modName);
	}

	public function RemoveNoteModByName(modName:String)
	{
		_mods.remove(modName);
		_modNameOrder.remove(modName);
	}

	/**
	 * Returns true if successful.
	 * @param modName 
	 * @param percent 
	 * @return Bool
	 */
	public function SetPercent(modName:String, percent:Float, player:Int):Bool
	{
		if (_mods.exists(modName))
		{
			_mods.get(modName).SetPercent(percent, player);
			return true;
		}
		return false;
	}

	public function GetPercent(modName:String, player:Int)
	{
		if (_mods.exists(modName))
		{
			return _mods.get(modName).GetPercent(player);
		}
		return 0;
	}

	public function Update(currentBeat:Float, sprite:FlxSprite, player:Int = 0, column:Int = 0)
	{
		var pos = new Vector4();
		var sustain = false;
		for (noteModName in _modNameOrder)
		{
			var notemod = _mods.get(noteModName);
			if (ShouldSkipMod(notemod, player))
				continue;
			// Concrete dependencies :P
			if (Std.is(sprite, Note))
			{
				var note:Note = cast sprite;
				var strumTimeDiff = SchmovinAdapter.GetInstance().GetSongPosition() - note.strumTime - SchmovinAdapter.GetInstance().GrabGlobalVisualOffset();
				pos = notemod.ExecutePath(currentBeat, strumTimeDiff, note.GetTotalColumn(), player, pos);
				notemod.ExecuteNote(currentBeat, cast sprite, player, pos);
				if (note.isSustainNote)
					sustain = true;
			}
			else
			{
				var receptor = new Receptor(sprite, column);
				pos = notemod.ExecutePath(currentBeat, 0, receptor.column, player, pos);
				notemod.ExecuteReceptor(currentBeat, receptor, player, pos);
			}
		}
		pos = pos.subtract(SchmovinUtil.PosNoteWidthHalf());
		if (sustain)
			return;
		sprite.x = pos.x;
		sprite.y = pos.y;
	}

	function ShouldSkipMod(notemod:ISchmovinNoteMod, player:Int)
	{
		return (!notemod.IsPrimaryMod() || notemod.GetPercent(player) == 0) && !notemod.MustExecute();
	}

	public function UpdateMiscMods(currentBeat:Float)
	{
		for (noteModName in _modNameOrder)
		{
			var notemod = _mods.get(noteModName);
			if (!notemod.IsPrimaryMod() && notemod.ShouldDoUpdate())
			{
				notemod.Update(currentBeat);
			}
		}
	}

	public function GetPath(currentBeat:Float, strumTime:Float, column:Int, player:Int)
	{
		var pos = new Vector4();
		for (noteModName in _modNameOrder)
		{
			var notemod = _mods.get(noteModName);
			if (ShouldSkipMod(notemod, player))
				continue;
			pos = notemod.ExecutePath(currentBeat, strumTime, column, player, pos);
		}
		return pos;
	}
}
