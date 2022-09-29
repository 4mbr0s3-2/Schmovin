/**
 * @ Author: 4mbr0s3 2
 * @ Create Time: 2021-07-23 17:48:21
 * @ Modified by: 4mbr0s3 2
 * @ Modified time: 2022-09-11 12:22:40
 */

package schmovin.note_mods;

import flixel.FlxG;
import flixel.math.FlxMath;
import lime.math.Vector4;
import schmovin.util.Camera3DTransforms;

class NoteModRotate extends NoteModBase
{
	var _modPrefix:String;
	var _origin:Vector4;

	override public function new(modPrefix:String = '', origin:Vector4 = null)
	{
		_modPrefix = modPrefix;
		_origin = origin;
		super();
	}

	override function IsVertexModifier():Bool
	{
		return true;
	}

	override function ExecuteOther(currentBeat:Float, strumTime:Float, column:Int, player:Int, map:Map<String, Dynamic>, playfield:SchmovinPlayfield)
	{
		map.set('angleX', GetOtherPercent('${_modPrefix}rotatex', playfield));
		map.set('angleY', GetOtherPercent('${_modPrefix}rotatey', playfield));
		map.set('angleZ', GetOtherPercent('${_modPrefix}rotatez', playfield));
	}

	override function ExecutePath(currentBeat:Float, strumTime:Float, column:Int, player:Int, pos:Vector4, playfield:SchmovinPlayfield):Vector4
	{
		var origin:Vector4 = new Vector4(50 + FlxG.width / 2 * player + 2 * Note.swagWidth, FlxG.height / 2);
		if (_origin != null)
			origin = _origin;
		// Set center of rotation to origin
		var diff = pos.subtract(origin);

		var out = Camera3DTransforms.RotateVector4(diff, GetOtherPercent('${_modPrefix}rotatex', playfield),
			GetOtherPercent('${_modPrefix}rotatey', playfield), GetOtherPercent('${_modPrefix}rotatez', playfield));

		return origin.add(out);
	}
}
