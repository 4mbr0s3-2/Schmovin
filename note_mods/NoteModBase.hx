/**
 * @ Author: 4mbr0s3 2
 * @ Create Time: 2021-07-15 16:29:16
 * @ Modified by: 4mbr0s3 2
 * @ Modified time: 2022-07-30 19:16:17
 */

package schmovin.note_mods;

import lime.math.Vector4;
import schmovin.SchmovinEvent.ISchmovinEvent;

using schmovin.SchmovinUtil;

class NoteModBase implements ISchmovinNoteMod
{
	public var order:Int = 0;

	private function toString()
	{
		return '';
	}

	var _name:String;
	var _parent:String;
	var _modList:SchmovinNoteModList;
	var _state:PlayState;
	var _currentEvent:ISchmovinEvent;
	var _active = false;
	var _playfields:SchmovinPlayfieldManager;

	public function executeOther(currentBeat:Float, strumTime:Float, column:Int, player:Int, map:Map<String, Dynamic>, playfield:SchmovinPlayfield):Void {}

	public function deactivate(receptors:Array<Receptor>, notes:Array<Note>)
	{
		// Only check activity after deactivation
		// var o = false;
		// for (percent in _percents.iterator())
		// 	o = o || percent != 0;
		// _active = o;
		// if (!_active)
		// 	_modList.RemoveFromActiveModList(this);
	}

	public function activate(receptors:Array<Receptor>, notes:Array<Note>)
	{
		_active = true;
	}

	public function isActive()
	{
		return _active;
	}

	public function alwaysExecute()
	{
		return false;
	}

	public function getName()
	{
		return _name;
	}

	public function setName(v:String)
	{
		if (_name == null)
			_name = v;
	}

	public function getParent()
	{
		return _parent;
	}

	public function setParent(v:String)
	{
		if (_parent == null)
			_parent = v;
	}

	public function isMiscMod():Bool
	{
		return false;
	}

	private function getDefaultPlayfieldFromPlayer(p:Int)
	{
		return _playfields.getPlayfieldAtIndex(p);
	}

	private function setPercent(f:Float, playfield:SchmovinPlayfield)
	{
		var player = playfield.player;
		if (f != 0 && getPercent(playfield) == 0)
			activate(SchmovinUtil.getReceptors(player, _state), SchmovinUtil.getNotes(player, _state));
		else if (f == 0 && getPercent(playfield) != 0)
			deactivate(SchmovinUtil.getReceptors(player, _state), SchmovinUtil.getNotes(player, _state));
		// _percents.set(playfield, f);
		playfield.setPercent(this.getName(), f);
	}

	/**
		Called whenever a playfield sets the mod.
		Useful for having mods that sets other mods.
	**/
	public function onSetPercent(f:Float, playfield:SchmovinPlayfield) {}

	/**
	 * Returns the number of pixels for the strum time, taking into account scroll speed. 
	 * @param strumTimeDiff 
	 */
	public function getRelativeTime(strumTimeDiff:Float)
	{
		return strumTimeDiff * SchmovinAdapter.getInstance().grabScrollSpeed() * 0.45;
	}

	public function setLegacyPercent(f:Float, p:Int)
	{
		if (p < 0)
		{
			for (i in 0...2)
				setPercent(f, getDefaultPlayfieldFromPlayer(i));
			return;
		}
		setPercent(f, getDefaultPlayfieldFromPlayer(p));
	}

	/**
		Legacy method that requires a player index rather than a playfield.
	**/
	public function getLegacyPercent(p:Int)
	{
		if (p < 0)
		{
			var sum = 0.0;
			for (i in 0...2)
				sum += getPercent(getDefaultPlayfieldFromPlayer(i));
			return sum;
		}
		if (_playfields == null)
			return 0.0;
		return getPercent(getDefaultPlayfieldFromPlayer(p));
	}

	/**
		Set the percent of the note mod for the playfield.
	**/
	public function getPercent(playfield:SchmovinPlayfield)
	{
		return playfield.getPercent(this.getName());
	}

	/**
		Deprecated because calling playfield.getPercent() would've already been enough. (Middle man)
		However, I'm probably keeping it here in case legacy code calls it...
	**/
	@:deprecated
	public function getOtherPercent(modName:String, playfield:SchmovinPlayfield)
	{
		return playfield.getPercent(modName);
	}

	public function getOtherLegacyPercent(modName:String, player:Int)
	{
		return _modList.getPercent(modName, player);
	}

	public function setOtherPercent(f:Float, modName:String, player:Int)
	{
		_modList.setPercent(modName, f, player);
	}

	@:deprecated
	var _percents:Map<SchmovinPlayfield, Float> = new Map<SchmovinPlayfield, Float>();

	public function new() {}

	public function initialize(state:PlayState, modList:SchmovinNoteModList, playfields:SchmovinPlayfieldManager)
	{
		_state = state;
		_modList = modList; // Bi-directional
		_playfields = playfields;
	}

	public function setOrder(v:Int)
	{
		order = v;
	}

	public function getOrder()
	{
		return order;
	}

	public function isVertexModifier()
	{
		return false;
	}

	public function executeNoteVertex(currentBeat:Float, strumTime:Float, column:Int, player:Int, vert:Vector4, vertIndex:Int, pos:Vector4,
			playfield:SchmovinPlayfield)
	{
		return vert;
	}

	public function executeReceptor(currentBeat:Float, receptor:Receptor, player:Int, pos:Vector4, playfield:SchmovinPlayfield) {}

	public function executeNote(currentBeat:Float, note:Note, player:Int, pos:Vector4, playfield:SchmovinPlayfield) {}

	public function executePath(currentBeat:Float, strumTime:Float, column:Int, player:Int, pos:Vector4, playfield:SchmovinPlayfield):Vector4
	{
		return pos;
	}

	public function update(currentBeat:Float) {}
}
