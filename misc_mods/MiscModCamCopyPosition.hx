/**
 * @ Author: 4mbr0s3 2
 * @ Create Time: 2021-07-21 18:18:16
 * @ Modified by: 4mbr0s3 2
 * @ Modified time: 2021-09-06 16:54:40
 */

package schmovin.misc_mods;

import groovin.util.FlxCameraCopy;
import schmovin.misc_mods.MiscModBase;

class MiscModCamCopyPosition extends MiscModBase
{
	var _cam:FlxCameraCopy;
	var _player:Int;
	var _prefix:String;

	public function new(state:PlayState, modList:SchmovinNoteModList, primary:Bool = false, cam:FlxCameraCopy, plr:Int, prefix:String = 'camgame')
	{
		super(state, modList, primary);
		_cam = cam;
		_prefix = prefix;
		_player = plr;
	}

	override function Update(currentBeat:Float)
	{
		_cam.scrollOffset.x = GetPercent(0);
		_cam.scrollOffset.y = GetOtherPercent('${_prefix}y', 0);
		_cam.scrollOverride = GetOtherPercent('${_prefix}override', 0);
		_cam.scrollOverrideTarget.x = GetOtherPercent('${_prefix}overridex', 0);
		_cam.scrollOverrideTarget.y = GetOtherPercent('${_prefix}overridey', 0);
		_cam.zoomOffset = GetOtherPercent('${_prefix}zoom', 0);
		_cam.angleOffset = GetOtherPercent('${_prefix}angle', 0);
	}

	override function IsPrimaryMod():Bool
	{
		return false;
	}
}
