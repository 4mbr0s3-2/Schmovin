/**
 * @ Author: 4mbr0s3 2
 * @ Create Time: 2021-07-21 18:18:16
 * @ Modified by: 4mbr0s3 2
 * @ Modified time: 2022-03-22 14:53:16
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

	override function update(currentBeat:Float)
	{
		_cam.scrollOffset.x = getLegacyPercent(0);
		_cam.scrollOffset.y = getOtherLegacyPercent('${_prefix}y', 0);
		_cam.scrollOverride = getOtherLegacyPercent('${_prefix}override', 0);
		_cam.scrollOverrideTarget.x = getOtherLegacyPercent('${_prefix}overridex', 0);
		_cam.scrollOverrideTarget.y = getOtherLegacyPercent('${_prefix}overridey', 0);
		_cam.zoomOffset = getOtherLegacyPercent('${_prefix}zoom', 0);
		_cam.angleOffset = getOtherLegacyPercent('${_prefix}angle', 0);
	}
}
