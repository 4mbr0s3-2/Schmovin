/**
 * @ Author: 4mbr0s3 2
 * @ Create Time: 2021-08-28 21:16:38
 * @ Modified by: 4mbr0s3 2
 * @ Modified time: 2022-01-06 22:52:28
 */

package schmovin.misc_mods;

import flixel.FlxCamera;
import schmovin.misc_mods.MiscModBase;

class MiscModCamRaymarch extends MiscModBase
{
	var _cam:FlxCamera;
	var _player:Int;
	var _prefix:String;

	public function new(cam:FlxCamera, plr:Int, prefix:String = 'camnotesrm')
	{
		super();
		_cam = cam;
		_prefix = prefix;
		_player = plr;
	}

	override function update(currentBeat:Float)
	{
		var schmovinInstance = _modList.getSchmovinInstance();
		var getRaymarcher = schmovinInstance.planeRaymarcher;
		getRaymarcher.cameraLookAtX = getOtherLegacyPercent('${_prefix}lookatx', _player);
		getRaymarcher.cameraLookAtY = getOtherLegacyPercent('${_prefix}lookaty', _player);
		getRaymarcher.cameraLookAtZ = getOtherLegacyPercent('${_prefix}lookatz', _player);
		getRaymarcher.cameraOffX = getOtherLegacyPercent('${_prefix}x', _player);
		getRaymarcher.cameraOffY = getOtherLegacyPercent('${_prefix}y', _player);
		getRaymarcher.cameraOffZ = getOtherLegacyPercent('${_prefix}z', _player);
		getRaymarcher.pitch = getOtherLegacyPercent('${_prefix}pitch', _player);
		getRaymarcher.yaw = getOtherLegacyPercent('${_prefix}yaw', _player);
	}
}
