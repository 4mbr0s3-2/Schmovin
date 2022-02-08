/**
 * @ Author: 4mbr0s3 2
 * @ Create Time: 2021-06-22 12:04:54
 * @ Modified by: 4mbr0s3 2
 * @ Modified time: 2022-02-07 22:27:10
 */

package schmovin;

import flixel.FlxG;
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
	/**
	 * Consists of all registered mods.
	 */
	var _mods:Map<String, ISchmovinNoteMod>;
	@:allow(schmovin.SchmovinClient, schmovin.Registry)
	var _playfields:SchmovinPlayfieldManager;

	/**
	 * Consists of mods to be updated.
	 */
	var _modExecuteList:Array<ISchmovinNoteMod>;

	var _vertexModExecuteList:Array<ISchmovinNoteMod>;

	var _timeline:SchmovinTimeline;

	public function IsInActiveModList(name:String)
	{
		var out = false;
		for (mod in _modExecuteList)
		{
			if (mod.GetName() == name)
				out = true;
		}
		return out;
	}

	@:allow(schmovin.note_mods.ISchmovinNoteMod)
	function AddToActiveModList(i:ISchmovinNoteMod)
	{
		if (!_modExecuteList.contains(i))
			_modExecuteList.push(i);
		SortModList(_modExecuteList);
	}

	@:allow(schmovin.note_mods.ISchmovinNoteMod)
	function AddToActiveVertexModList(i:ISchmovinNoteMod)
	{
		if (!_vertexModExecuteList.contains(i))
			_vertexModExecuteList.push(i);
		SortModList(_vertexModExecuteList);
	}

	function SortModList(list:Array<ISchmovinNoteMod>)
	{
		list.sort((m1, m2) ->
		{
			return m1.GetOrder() > m2.GetOrder() ? 1 : -1;
		});
	}

	@:allow(schmovin.note_mods.ISchmovinNoteMod)
	function RemoveFromActiveModList(i:ISchmovinNoteMod)
	{
		var out = _modExecuteList.remove(i);
		if (i.IsVertexModifier())
			_vertexModExecuteList.remove(i);
		SortModList(_modExecuteList);
		return out;
	}

	public function new(state:PlayState, timeline:SchmovinTimeline, playfields:SchmovinPlayfieldManager)
	{
		_timeline = timeline;
		_state = state;
		_mods = new Map<String, ISchmovinNoteMod>();
		_modExecuteList = [];
		_vertexModExecuteList = [];
		_playfields = playfields;
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

	var _currentModOrderIndex = 0;

	public function AddNoteMod(modName:String, mod:ISchmovinNoteMod, putInExecutionList:Bool = false)
	{
		mod.SetName(modName);
		mod.SetOrder(_currentModOrderIndex);
		_currentModOrderIndex++;
		_mods.set(modName, mod);
		if (putInExecutionList || mod.MustExecute() || mod.IsMiscMod())
		{
			_modExecuteList.push(mod);
			if (mod.IsVertexModifier())
				_vertexModExecuteList.push(mod);
		}
	}

	public function AddNoteModBefore(beforeModName:String, modName:String, mod:ISchmovinNoteMod, putInExecutionList:Bool = true)
	{
		mod.SetName(modName);
		_mods.set(modName, mod);
		if (putInExecutionList || mod.MustExecute() || mod.IsMiscMod())
		{
			_modExecuteList.insert(_modExecuteList.indexOf(GetNoteModByName(beforeModName)), mod);
		}
	}

	public function GetNoteModByName(modName:String)
	{
		return _mods.get(modName);
	}

	public function RemoveNoteModByName(modName:String)
	{
		_mods.remove(modName);
		_modExecuteList.remove(GetNoteModByName(modName));
	}

	/**
	 * Replicates the way modifiers are processed in NotITG / OpenITG.
	 * In fact, this function is an almost exact port of PlayerOptions::FromString().
	 * https://github.com/openitg/openitg/blob/master/src/PlayerOptions.cpp
	 * 
	 * TODO: Translate speeds to eases and sets, add Lua support, and try using Mirin Template?
	 */
	public function ITGApplyModifiers(stringOptions:String, player:Int)
	{
		var stringBits = stringOptions.toLowerCase().split(',');
		for (bit in stringBits)
		{
			bit = bit.trim();
			var level = 1.0;
			var speed = 1.0;
			var parts = bit.split(' ');
			for (part in parts)
			{
				if (part == 'no')
					level = 0;
				else if (Std.parseInt(part.charAt(0)) != null || part.charAt(0) == '-')
					level = Std.parseFloat(part) / 100.0;
				else if (part.charAt(0) == '*')
					speed = Std.parseFloat(part.split('*')[1]);
			}

			bit = parts[parts.length - 1];

			SetPercentPlayfieldIndex(bit, level, player);
		}
	}

	/**
	 * Returns true if successful.
	 * @param modName 
	 * @param percent 
	 * @return Bool
	 */
	public function SetPercent(modName:String, percent:Float, player:Int, playfield:SchmovinPlayfield = null):Bool
	{
		var pf = _playfields.GetPlayfieldAtIndex(player);
		if (playfield != null)
			pf = playfield;
		if (_mods.exists(modName))
		{
			_mods.get(modName).SetPercent(percent, pf);
			return true;
		}
		return false;
	}

	public function SetPercentPlayfieldIndex(modName:String, percent:Float, index:Int)
	{
		SetPercent(modName, percent, index, _playfields.GetPlayfieldAtIndex(index));
	}

	public function GetPercent(modName:String, player:Int, playfield:SchmovinPlayfield = null)
	{
		var pf = _playfields.GetPlayfieldAtIndex(player);
		if (playfield != null)
			pf = playfield;
		var mod = _mods.get(modName);
		if (mod != null)
		{
			return mod.GetPercent(pf);
		}
		return 0;
	}

	public function UpdatePath(playfield:SchmovinPlayfield, currentBeat:Float, sprite:FlxSprite, player:Int = 0, column:Int = 0)
	{
		var pos = new Vector4();
		for (notemod in _modExecuteList)
		{
			// if (ShouldSkipMod(notemod, player))
			// 	continue;
			// Concrete dependencies :P
			if (Std.is(sprite, Note))
			{
				var note:Note = cast sprite;
				var strumTimeDiff = SchmovinAdapter.GetInstance().GetSongPosition() - note.strumTime - SchmovinAdapter.GetInstance().GrabGlobalVisualOffset();
				pos = notemod.ExecutePath(currentBeat, strumTimeDiff, note.GetTotalColumn(), player, pos, playfield);
			}
			else
			{
				var receptor = new Receptor(sprite, column);
				pos = notemod.ExecutePath(currentBeat, 0, receptor.column, player, pos, playfield);
			}
		}
		pos = pos.subtract(SchmovinUtil.PosNoteWidthHalf());
		return pos;
	}

	public function UpdateNote(playfield:SchmovinPlayfield, currentBeat:Float, sprite:FlxSprite, pos:Vector4, player:Int = 0, column:Int = 0)
	{
		for (notemod in _modExecuteList)
		{
			// if (ShouldSkipMod(notemod, player))
			// 	continue;
			if (Std.is(sprite, Note))
			{
				var note:Note = cast sprite;
				notemod.ExecuteNote(currentBeat, note, player, pos, playfield);
			}
			else
			{
				var receptor = new Receptor(sprite, column);
				notemod.ExecuteReceptor(currentBeat, receptor, player, pos, playfield);
			}
		}
	}

	public function UpdateNoteVertex(currentBeat:Float, sprite:FlxSprite, vertex:Vector4, vertexIndex:Int, pos:Vector4, playfield:SchmovinPlayfield,
			player:Int = 0, column:Int = 0, exclude:Array<String> = null)
	{
		var outVertex = vertex.clone();
		for (notemod in _vertexModExecuteList)
		{
			if (exclude != null && exclude.contains(notemod.GetName()))
				continue;
			// Concrete dependencies :P
			if (Std.is(sprite, Note))
			{
				var note:Note = cast sprite;
				var strumTimeDiff = SchmovinAdapter.GetInstance().GetSongPosition() - note.strumTime - SchmovinAdapter.GetInstance().GrabGlobalVisualOffset();
				outVertex = notemod.ExecuteNoteVertex(currentBeat, strumTimeDiff, note.GetTotalColumn(), player, outVertex, vertexIndex, pos, playfield);
			}
			else
				outVertex = notemod.ExecuteNoteVertex(currentBeat, 0, column, player, outVertex, vertexIndex, pos, playfield);
		}
		return outVertex;
	}

	function ShouldSkipMod(notemod:ISchmovinNoteMod, player:Int)
	{
		return (notemod.IsMiscMod() || !notemod.IsActive()) && !notemod.MustExecute();
	}

	public function UpdateMiscMods(currentBeat:Float)
	{
		for (notemod in _modExecuteList)
		{
			if (notemod.IsMiscMod())
				notemod.Update(currentBeat);
		}
	}

	public function GetPath(currentBeat:Float, strumTime:Float, column:Int, player:Int, playfield:SchmovinPlayfield, exclude:Array<String> = null)
	{
		var pos = new Vector4();
		for (notemod in _modExecuteList)
		{
			if (exclude != null && exclude.contains(notemod.GetName()))
				continue;
			pos = notemod.ExecutePath(currentBeat, strumTime, column, player, pos, playfield);
		}
		return pos;
	}
}
