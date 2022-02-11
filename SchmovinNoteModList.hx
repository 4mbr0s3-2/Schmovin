/**
 * @ Author: 4mbr0s3 2
 * @ Create Time: 2021-06-22 12:04:54
 * @ Modified by: 4mbr0s3 2
 * @ Modified time: 2022-02-11 00:04:37
 */

package schmovin;

import flixel.FlxG;
import flixel.FlxSprite;
import haxe.Exception;
import lime.math.Vector4;
import schmovin.ModRegistry;
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
	 * Consists of all registered note mods.
	 */
	var _mods:Map<String, ISchmovinNoteMod>;

	var _modsOrder:Array<String> = [];

	/**
	 * Consists of all registered auxiliary (formerly sub) note mods.
	 */
	var _auxMods:Map<String, ISchmovinNoteMod>;

	var _auxModsOrder:Array<String> = [];

	/**
	 * Consists of all registered miscellaneous mods. They always run every frame (once).
	 */
	var _miscMods:Map<String, ISchmovinNoteMod>;

	var _miscModsOrder:Array<String> = [];

	@:allow(schmovin.SchmovinClient, schmovin.ModRegistry)
	var _playfields:SchmovinPlayfieldManager;

	/**
	 * Consists of mods to be updated.
	 */
	// var _modExecuteList:Array<ISchmovinNoteMod>;
	// var _vertexModExecuteList:Array<ISchmovinNoteMod>;
	var _timeline:SchmovinTimeline;

	// public function IsInActiveModList(name:String)
	// {
	// 	var out = false;
	// 	for (mod in _modExecuteList)
	// 	{
	// 		if (mod.GetName() == name)
	// 			out = true;
	// 	}
	// 	return out;
	// }
	// @:allow(schmovin.note_mods.ISchmovinNoteMod)
	// function AddToActiveModList(i:ISchmovinNoteMod)
	// {
	// 	if (!_modExecuteList.contains(i))
	// 		_modExecuteList.push(i);
	// 	SortModList(_modExecuteList);
	// }
	// @:allow(schmovin.note_mods.ISchmovinNoteMod)
	// function AddToActiveVertexModList(i:ISchmovinNoteMod)
	// {
	// 	if (!_vertexModExecuteList.contains(i))
	// 		_vertexModExecuteList.push(i);
	// 	SortModList(_vertexModExecuteList);
	// }
	// function SortModList(list:Array<ISchmovinNoteMod>)
	// {
	// 	list.sort((m1, m2) ->
	// 	{
	// 		return m1.GetOrder() > m2.GetOrder() ? 1 : -1;
	// 	});
	// }
	// @:allow(schmovin.note_mods.ISchmovinNoteMod)
	// function RemoveFromActiveModList(i:ISchmovinNoteMod)
	// {
	// 	var out = _modExecuteList.remove(i);
	// 	if (i.IsVertexModifier())
	// 		_vertexModExecuteList.remove(i);
	// 	SortModList(_modExecuteList);
	// 	return out;
	// }

	public function new(state:PlayState, timeline:SchmovinTimeline, playfields:SchmovinPlayfieldManager)
	{
		_timeline = timeline;
		_state = state;
		_mods = new Map<String, ISchmovinNoteMod>();
		_auxMods = new Map<String, ISchmovinNoteMod>();
		_miscMods = new Map<String, ISchmovinNoteMod>();
		_playfields = playfields;
		InitializeNoteMods();
	}

	@:allow(schmovin.note_mods.ISchmovinNoteMod, schmovin.ModRegistry)
	function GetSchmovinInstance()
	{
		return _timeline._instance;
	}

	public function GetNoteModsMap()
	{
		return [for (m in _mods) m].concat([for (m in _auxMods) m]).concat([for (m in _miscMods) m]);
	}

	public function InitializeNoteMods()
	{
		new ModRegistry(this, _state).Register();
	}

	public function AddNoteMod(modName:String, mod:ISchmovinNoteMod, auxiliary:Bool = false)
	{
		mod.Initialize(_state, this, _playfields);
		mod.SetName(modName);
		if (auxiliary)
		{
			_auxMods.set(modName, mod);
			_auxModsOrder.push(modName);
		}
		else if (mod.IsMiscMod())
		{
			_miscMods.set(modName, mod);
			_miscModsOrder.push(modName);
		}
		else
		{
			_mods.set(modName, mod);
			_modsOrder.push(modName);
		}
	}

	public function AddNoteModBefore(beforeModName:String, modName:String, mod:ISchmovinNoteMod, putInExecutionList:Bool = true)
	{
		mod.SetName(modName);
		_mods.set(modName, mod);
		// if (putInExecutionList || mod.MustExecute() || mod.IsMiscMod())
		// {
		// 	_modExecuteList.insert(_modExecuteList.indexOf(GetModByName(beforeModName)), mod);
		// }
	}

	public function GetModByName(modName:String)
	{
		var aux = _auxMods.get(modName);
		if (aux != null)
			return aux;
		var note = _mods.get(modName);
		if (note != null)
			return note;
		var misc = _miscMods.get(modName);
		if (misc != null)
			return misc;
		return new NoteModBase();
	}

	public function RemoveNoteModByName(modName:String)
	{
		_mods.remove(modName);
		_modsOrder.remove(modName);
		_auxMods.remove(modName);
		_auxModsOrder.remove(modName);
		_miscMods.remove(modName);
		_miscModsOrder.remove(modName);
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
		pf.SetPercent(modName, percent);
		return true;
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
		return pf.GetPercent(modName);
	}

	public function UpdatePath(playfield:SchmovinPlayfield, currentBeat:Float, sprite:FlxSprite, player:Int = 0, column:Int = 0)
	{
		var pos = new Vector4();
		for (modName in _modsOrder)
		{
			var notemod = _mods[modName];
			if (ShouldSkipMod(notemod, playfield))
				continue;
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

	function GetOrderedPlayfieldMods(pf:SchmovinPlayfield)
	{
		var array = [for (k in pf.mods.keys()) k];
		array.sort((m1, m2) ->
		{
			_mods[m1].GetOrder() > _mods[m2].GetOrder() ? 1 : -1;
		});
		return array;
	}

	public function UpdateNote(playfield:SchmovinPlayfield, currentBeat:Float, sprite:FlxSprite, pos:Vector4, player:Int = 0, column:Int = 0)
	{
		for (modName in _modsOrder)
		{
			var notemod = _mods[modName];
			if (ShouldSkipMod(notemod, playfield))
				continue;
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
		var outVertex = vertex;
		for (modName in _modsOrder)
		{
			if (exclude != null && exclude.contains(modName))
				continue;
			var notemod = _mods[modName];
			if (ShouldSkipMod(notemod, playfield))
				continue;
			if (!notemod.IsVertexModifier())
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

	inline function ShouldSkipMod(notemod:ISchmovinNoteMod, playfield:SchmovinPlayfield)
	{
		// return (notemod.IsMiscMod() || !notemod.IsActive()) && !notemod.MustExecute();
		return !playfield.CheckActiveMod(notemod.GetName()) && !notemod.MustExecute();
	}

	public function UpdateMiscMods(currentBeat:Float)
	{
		for (miscmod in _miscModsOrder)
			_miscMods[miscmod].Update(currentBeat);
	}

	// I reassure you guys this is as optimized as it could possibly get
	public function GetPath(currentBeat:Float, strumTime:Float, column:Int, player:Int, playfield:SchmovinPlayfield, exclude:Array<String> = null)
	{
		var pos = new Vector4();
		for (modName in _modsOrder)
		{
			if (exclude != null && exclude.contains(modName))
				continue;
			var notemod = _mods[modName];
			if (ShouldSkipMod(notemod, playfield))
				continue;
			pos = notemod.ExecutePath(currentBeat, strumTime, column, player, pos, playfield);
		}
		return pos;
	}
}
