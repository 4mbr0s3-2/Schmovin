/**
 * @ Author: 4mbr0s3 2
 * @ Create Time: 2021-07-15 16:29:16
 * @ Modified by: 4mbr0s3 2
 * @ Modified time: 2022-03-14 01:10:45
 */

package schmovin.note_mods;

import lime.math.Vector4;
import schmovin.SchmovinEvent.ISchmovinEvent;

using schmovin.SchmovinUtil;

class NoteModBase implements ISchmovinNoteMod
{
	public var order:Int = 0;

	var _name:String;
	var _parent:String;
	var _modList:SchmovinNoteModList;
	var _state:PlayState;
	var _currentEvent:ISchmovinEvent;
	var _active = false;
	var _playfields:SchmovinPlayfieldManager;

	public function ExecuteOther(currentBeat:Float, strumTime:Float, column:Int, player:Int, map:Map<String, Dynamic>, playfield:SchmovinPlayfield):Void {}

	public function Deactivate(receptors:Array<Receptor>, notes:Array<Note>)
	{
		// Only check activity after deactivation
		// var o = false;
		// for (percent in _percents.iterator())
		// 	o = o || percent != 0;
		// _active = o;
		// if (!_active)
		// 	_modList.RemoveFromActiveModList(this);
	}

	public function Activate(receptors:Array<Receptor>, notes:Array<Note>)
	{
		_active = true;
	}

	public function IsActive()
	{
		return _active;
	}

	public function MustExecute()
	{
		return false;
	}

	public function GetName()
	{
		return _name;
	}

	public function SetName(v:String)
	{
		if (_name == null)
			_name = v;
	}

	public function GetParent()
	{
		return _parent;
	}

	public function SetParent(v:String)
	{
		if (_parent == null)
			_parent = v;
	}

	public function IsMiscMod():Bool
	{
		return false;
	}

	function GetDefaultPlayfieldFromPlayer(p:Int)
	{
		return _playfields.GetPlayfieldAtIndex(p);
	}

	public function SetPercent(f:Float, playfield:SchmovinPlayfield)
	{
		var player = playfield.player;
		if (f != 0 && GetPercent(playfield) == 0)
			Activate(SchmovinUtil.GetReceptors(player, _state), SchmovinUtil.GetNotes(player, _state));
		else if (f == 0 && GetPercent(playfield) != 0)
			Deactivate(SchmovinUtil.GetReceptors(player, _state), SchmovinUtil.GetNotes(player, _state));
		// _percents.set(playfield, f);
		playfield.SetPercent(this.GetName(), f);
	}

	/**
	 * Returns the number of pixels for the strum time, taking into account scroll speed. 
	 * @param strumTimeDiff 
	 */
	public function GetRelativeTime(strumTimeDiff:Float)
	{
		return strumTimeDiff * SchmovinAdapter.GetInstance().GrabScrollSpeed() * 0.45;
	}

	public function SetLegacyPercent(f:Float, p:Int)
	{
		if (p < 0)
		{
			for (i in 0...2)
				SetPercent(f, GetDefaultPlayfieldFromPlayer(i));
			return;
		}
		SetPercent(f, GetDefaultPlayfieldFromPlayer(p));
	}

	public function GetLegacyPercent(p:Int)
	{
		if (p < 0)
		{
			var sum = 0.0;
			for (i in 0...2)
				sum += GetPercent(GetDefaultPlayfieldFromPlayer(i));
			return sum;
		}
		if (_playfields == null)
			return 0.0;
		return GetPercent(GetDefaultPlayfieldFromPlayer(p));
	}

	public function GetPercent(playfield:SchmovinPlayfield)
	{
		return playfield.GetPercent(this.GetName());
	}

	public function GetOtherPercent(modName:String, playfield:SchmovinPlayfield)
	{
		return playfield.GetPercent(modName);
	}

	public function GetOtherLegacyPercent(modName:String, player:Int)
	{
		return _modList.GetPercent(modName, player);
	}

	public function SetOtherPercent(f:Float, modName:String, player:Int)
	{
		_modList.SetPercent(modName, f, player);
	}

	@:deprecated
	var _percents:Map<SchmovinPlayfield, Float> = new Map<SchmovinPlayfield, Float>();

	public function new() {}

	public function Initialize(state:PlayState, modList:SchmovinNoteModList, playfields:SchmovinPlayfieldManager)
	{
		_state = state;
		_modList = modList; // Bi-directional
		_playfields = playfields;
	}

	public function SetOrder(v:Int)
	{
		order = v;
	}

	public function GetOrder()
	{
		return order;
	}

	public function IsVertexModifier()
	{
		return false;
	}

	public function ExecuteNoteVertex(currentBeat:Float, strumTime:Float, column:Int, player:Int, vert:Vector4, vertIndex:Int, pos:Vector4,
			playfield:SchmovinPlayfield)
	{
		return vert;
	}

	public function ExecuteReceptor(currentBeat:Float, receptor:Receptor, player:Int, pos:Vector4, playfield:SchmovinPlayfield) {}

	public function ExecuteNote(currentBeat:Float, note:Note, player:Int, pos:Vector4, playfield:SchmovinPlayfield) {}

	public function ExecutePath(currentBeat:Float, strumTime:Float, column:Int, player:Int, pos:Vector4, playfield:SchmovinPlayfield):Vector4
	{
		return pos;
	}

	public function Update(currentBeat:Float) {}

	public function ShouldDoUpdate()
	{
		return false;
	}
}
