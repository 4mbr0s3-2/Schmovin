/**
 * @ Author: 4mbr0s3 2
 * @ Create Time: 2021-07-21 18:18:16
 * @ Modified by: 4mbr0s3 2
 * @ Modified time: 2022-01-06 23:13:47
 */

package schmovin.misc_mods;

import schmovin.misc_mods.MiscModBase;
import schmovin.util.FlxCameraCopy;

class MiscModCamCopyPosition extends MiscModBase
{
	var _cam:FlxCameraCopy;

	var _player:Int;
	var _prefix:String;

	public function new(cam:FlxCameraCopy, plr:Int, prefix:String = 'camgame')
	{
		super();
		_cam = cam;
		_prefix = prefix;
		_player = plr;
	}

	override function Update(currentBeat:Float)
	{
		_cam.scrollOffset.x = GetLegacyPercent(0);
		_cam.scrollOffset.y = GetOtherLegacyPercent('${_prefix}y', 0);
		_cam.scrollOverride = GetOtherLegacyPercent('${_prefix}override', 0);
		_cam.scrollOverrideTarget.x = GetOtherLegacyPercent('${_prefix}overridex', 0);
		_cam.scrollOverrideTarget.y = GetOtherLegacyPercent('${_prefix}overridey', 0);
		_cam.zoomOffset = GetOtherLegacyPercent('${_prefix}zoom', 0);
		_cam.angleOffset = GetOtherLegacyPercent('${_prefix}angle', 0);
	}
}
