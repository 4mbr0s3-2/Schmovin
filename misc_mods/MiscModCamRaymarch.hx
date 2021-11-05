/**
 * @ Author: 4mbr0s3 2
 * @ Create Time: 2021-08-28 21:16:38
 * @ Modified by: 4mbr0s3 2
 * @ Modified time: 2021-10-02 18:30:57
 */

package schmovin.misc_mods;

import flixel.FlxCamera;
import schmovin.misc_mods.MiscModBase;

class MiscModCamRaymarch extends MiscModBase
{
	var _cam:FlxCamera;
	var _player:Int;
	var _prefix:String;

	public function new(state:PlayState, modList:SchmovinNoteModList, primary:Bool = false, cam:FlxCamera, plr:Int, prefix:String = 'camnotesrm')
	{
		super(state, modList, primary);
		_cam = cam;
		_prefix = prefix;
		_player = plr;
	}

	override function Update(currentBeat:Float)
	{
		var schmovinInstance = _modList.GetSchmovinInstance();
		var getRaymarcher = schmovinInstance.planeRaymarcher;
		getRaymarcher.cameraLookAtX = GetOtherPercent('${_prefix}lookatx', _player);
		getRaymarcher.cameraLookAtY = GetOtherPercent('${_prefix}lookaty', _player);
		getRaymarcher.cameraLookAtZ = GetOtherPercent('${_prefix}lookatz', _player);
		getRaymarcher.cameraOffX = GetOtherPercent('${_prefix}x', _player);
		getRaymarcher.cameraOffY = GetOtherPercent('${_prefix}y', _player);
		getRaymarcher.cameraOffZ = GetOtherPercent('${_prefix}z', _player);
		getRaymarcher.pitch = GetOtherPercent('${_prefix}pitch', _player);
		getRaymarcher.yaw = GetOtherPercent('${_prefix}yaw', _player);
	}
}
