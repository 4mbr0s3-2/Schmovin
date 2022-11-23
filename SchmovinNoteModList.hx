/**
 * @ Author: 4mbr0s3 2
 * @ Create Time: 2021-06-22 12:04:54
 * @ Modified by: 4mbr0s3 2
 * @ Modified time: 2022-03-14 01:13:23
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
	private var _schmovinAdapter = SchmovinAdapter.getInstance();
	private var _state:PlayState;
	@:allow(schmovin.overlays.SchmovinDebugger)
	/**
	 * Names of mods that must execute before any other mod.
	 */
	private var _mustExecuteModNames:Array<String>;

	public function GetMustExecuteMods()
	{
		return _mustExecuteModNames;
	}

	/**
	 * Consists of all registered note mods.
	 */
	private var _mods:Map<String, ISchmovinNoteMod>;

	private var _modsOrder:Array<String> = [];

	/**
	 * Consists of all registered auxiliary (formerly sub) note mods.
	 */
	private var _auxMods:Map<String, ISchmovinNoteMod>;

	private var _auxModsOrder:Array<String> = [];

	/**
	 * Consists of all registered miscellaneous mods. They always run every frame (once).
	 */
	private var _miscMods:Map<String, ISchmovinNoteMod>;

	private var _miscModsOrder:Array<String> = [];

	@:allow(schmovin.SchmovinClient, schmovin.ModRegistry)
	private var _playfields:SchmovinPlayfieldManager;

	/**
	 * Consists of mods to be updated.
	 */
	private var _timeline:SchmovinTimeline;

	public function getModIndex(modName:String)
	{
		var modOrder = _modsOrder.indexOf(modName);
		return modOrder;
	}

	public function new(state:PlayState, timeline:SchmovinTimeline, playfields:SchmovinPlayfieldManager)
	{
		_timeline = timeline;
		_state = state;
		_mods = new Map<String, ISchmovinNoteMod>();
		_auxMods = new Map<String, ISchmovinNoteMod>();
		_miscMods = new Map<String, ISchmovinNoteMod>();
		_playfields = playfields;
		_mustExecuteModNames = [];
		initializeNoteMods();
	}

	@:allow(schmovin.note_mods.ISchmovinNoteMod, schmovin.ModRegistry)
	private function getSchmovinInstance()
	{
		return _timeline._instance;
	}

	public function getNoteModsMap()
	{
		return [for (m in _mods) m].concat([for (m in _auxMods) m]).concat([for (m in _miscMods) m]);
	}

	public function initializeNoteMods()
	{
		new ModRegistry(this, _state).register();
	}

	public function addNoteMod(modName:String, mod:ISchmovinNoteMod, auxiliary:Bool = false, parent:String = '')
	{
		mod.initialize(_state, this, _playfields);
		mod.setParent(parent);
		mod.setName(modName);
		if (auxiliary)
		{
			_auxMods.set(modName, mod);
			_auxModsOrder.push(modName);
		}
		else if (mod.isMiscMod())
		{
			_miscMods.set(modName, mod);
			_miscModsOrder.push(modName);
		}
		else
		{
			_mods.set(modName, mod);
			_modsOrder.push(modName);
		}
		if (mod.alwaysExecute())
			_mustExecuteModNames.push(modName);
	}

	public function addNoteModAt(beforeModName:String, modName:String, mod:ISchmovinNoteMod, putInExecutionList:Bool = true)
	{
		mod.setName(modName);
		_mods.set(modName, mod);
		// if (putInExecutionList || mod.alwaysExecute() || mod.isMiscMod())
		// {
		// 	_modExecuteList.insert(_modExecuteList.indexOf(getModFromName(beforeModName)), mod);
		// }
	}

	public function getModFromName(modName:String)
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

	public function removeNoteModFromName(modName:String)
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
	public function itgParseApplyModifiers(stringOptions:String, player:Int)
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

			setPercentPlayfieldIndex(bit, level, player);
		}
	}

	/**
	 * Returns true if successful.
	 * @param modName The mod name.
	 * @param percent The percent (0.01 = 1%).
	 * @return Bool
	 */
	public function setPercent(modName:String, percent:Float, player:Int, playfield:SchmovinPlayfield = null):Bool
	{
		var pf = _playfields.getPlayfieldAtIndex(player);
		if (playfield != null)
			pf = playfield;
		pf.setPercent(modName, percent);
		return true;
	}

	public function setPercentPlayfieldIndex(modName:String, percent:Float, index:Int)
	{
		setPercent(modName, percent, index, _playfields.getPlayfieldAtIndex(index));
	}

	public function getPercent(modName:String, player:Int, playfield:SchmovinPlayfield = null)
	{
		var pf = _playfields.getPlayfieldAtIndex(player);
		if (playfield != null)
			pf = playfield;
		return pf.getPercent(modName);
	}

	@:deprecated
	public function updatePath(playfield:SchmovinPlayfield, currentBeat:Float, sprite:FlxSprite, player:Int = 0, column:Int = 0)
	{
		var pos = new Vector4();
		for (modName in _modsOrder)
		{
			var notemod = _mods[modName];
			// Concrete dependencies :P
			if (Std.is(sprite, Note))
			{
				var note:Note = cast sprite;
				var strumTimeDiff = _schmovinAdapter.getSongPosition() - note.strumTime - _schmovinAdapter.grabGlobalVisualOffset();
				pos = notemod.executePath(currentBeat, strumTimeDiff, note.getTotalColumn(), player, pos, playfield);
			}
			else
			{
				var receptor = new Receptor(sprite, column);
				pos = notemod.executePath(currentBeat, 0, receptor.column, player, pos, playfield);
			}
		}
		pos = pos.subtract(SchmovinUtil.posGetNoteWidthHalf());
		return pos;
	}

	private function getOrderedPlayfieldMods(pf:SchmovinPlayfield)
	{
		var array = [for (k in pf.mods.keys()) k];
		array.sort((m1, m2) ->
		{
			_mods[m1].getOrder() > _mods[m2].getOrder() ? 1 : -1;
		});
		return array;
	}

	public function updateNote(playfield:SchmovinPlayfield, currentBeat:Float, sprite:FlxSprite, pos:Vector4, player:Int = 0, column:Int = 0)
	{
		for (modName in getModNameList(playfield))
		{
			var notemod = _mods[modName];
			if (Std.is(sprite, Note))
			{
				var note:Note = cast sprite;
				notemod.executeNote(currentBeat, note, player, pos, playfield);
			}
			else
			{
				var receptor = new Receptor(sprite, column);
				notemod.executeReceptor(currentBeat, receptor, player, pos, playfield);
			}
		}
	}

	public function updateNoteVertex(currentBeat:Float, sprite:FlxSprite, vertex:Vector4, vertexIndex:Int, pos:Vector4, playfield:SchmovinPlayfield,
			player:Int = 0, column:Int = 0, exclude:Array<String> = null)
	{
		var outVertex = vertex;
		for (modName in getModNameList(playfield))
		{
			if (exclude != null && exclude.contains(modName))
				continue;
			var notemod = _mods[modName];
			if (notemod == null)
				continue;

			if (!notemod.isVertexModifier())
				continue;
			// Concrete dependencies :P
			if (Std.is(sprite, Note))
			{
				var note:Note = cast sprite;
				var strumTimeDiff = _schmovinAdapter.getSongPosition() - note.strumTime - _schmovinAdapter.grabGlobalVisualOffset();
				outVertex = notemod.executeNoteVertex(currentBeat, strumTimeDiff, note.getTotalColumn(), player, outVertex, vertexIndex, pos, playfield);
			}
			else
				outVertex = notemod.executeNoteVertex(currentBeat, 0, column, player, outVertex, vertexIndex, pos, playfield);
		}
		return outVertex;
	}

	public function updateMiscMods(currentBeat:Float)
	{
		for (miscmod in _miscModsOrder)
			_miscMods[miscmod].update(currentBeat);
	}

	private inline function getModNameList(playfield:SchmovinPlayfield)
	{
		return playfield.activeMods;
	}

	// I reassure you guys this is as optimized as it could possibly get
	public function getPath(currentBeat:Float, strumTime:Float, column:Int, player:Int, playfield:SchmovinPlayfield, exclude:Array<String> = null)
	{
		var pos = new Vector4();
		for (modName in getModNameList(playfield))
		{
			if (exclude != null && exclude.contains(modName))
				continue;
			var notemod = _mods[modName];
			if (notemod == null)
				continue;

			pos = notemod.executePath(currentBeat, strumTime, column, player, pos, playfield);
		}
		return pos;
	}

	public function getOtherMap(currentBeat:Float, strumTime:Float, column:Int, player:Int, playfield:SchmovinPlayfield, exclude:Array<String> = null)
	{
		var map = new Map<String, Dynamic>();
		for (modName in getModNameList(playfield))
		{
			if (exclude != null && exclude.contains(modName))
				continue;
			var notemod = _mods[modName];
			if (notemod == null)
				continue;

			notemod.executeOther(currentBeat, strumTime, column, player, map, playfield);
		}
		return map;
	}
}
