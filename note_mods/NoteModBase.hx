/**
 * @ Author: 4mbr0s3 2
 * @ Create Time: 2021-07-15 16:29:16
 * @ Modified by: 4mbr0s3 2
 * @ Modified time: 2021-08-29 15:08:32
 */

package schmovin.note_mods;

import groovin_input.GroovinInput;
import lime.math.Vector4;
import schmovin.SchmovinEvent.ISchmovinEvent;

using schmovin.SchmovinUtil;

class NoteModBase implements ISchmovinNoteMod
{
	var _name:String;
	var _isPrimary:Bool = true;
	var _modList:SchmovinNoteModList;
	var _state:PlayState;
	var _currentEvent:ISchmovinEvent;

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

	public function IsPrimaryMod():Bool
	{
		return _isPrimary;
	}

	public function SetPercent(f:Float, player:Int)
	{
		if (player <= -1)
		{
			for (p in 0..._percents.length)
				_percents[p] = f;
		}
		_percents[player] = f;
	}

	/**
	 * Returns the number of pixels for the strum time, taking into account scroll speed. 
	 * @param strumTimeDiff 
	 */
	public function GetRelativeTime(strumTimeDiff:Float)
	{
		return strumTimeDiff * GroovinInput.GrabScrollSpeed(PlayState.SONG) * 0.45;
	}

	public function GetPercent(player:Int)
	{
		if (player <= -1)
		{
			var sum = 0.0;
			for (p in 0..._percents.length)
				sum += _percents[p];
			return sum / _percents.length;
		}
		return _percents[player];
	}

	public function GetOtherPercent(modName:String, player:Int)
	{
		return _modList.GetPercent(modName, player);
	}

	public function SetOtherPercent(f:Float, modName:String, player:Int)
	{
		_modList.SetPercent(modName, f, player);
	}

	var _percents:Array<Float> = [0, 0];

	public function new(state:PlayState, modList:SchmovinNoteModList, primary:Bool = true)
	{
		_state = state;
		_modList = modList; // Bi-directional
		_isPrimary = primary;
	}

	public function ExecuteReceptor(currentBeat:Float, receptor:Receptor, player:Int, pos:Vector4) {}

	public function ExecuteNote(currentBeat:Float, note:Note, player:Int, pos:Vector4) {}

	public function ExecutePath(currentBeat:Float, strumTime:Float, column:Int, player:Int, pos:Vector4):Vector4
	{
		return pos;
	}

	public function Update(currentBeat:Float) {}

	public function ShouldDoUpdate()
	{
		return false;
	}
}
