/**
 * @ Author: 4mbr0s3 2
 * @ Create Time: 2021-07-23 17:48:21
 * @ Modified by: 4mbr0s3 2
 * @ Modified time: 2022-05-26 17:44:46
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

	override function ExecuteNoteVertex(currentBeat:Float, strumTime:Float, column:Int, player:Int, vert:Vector4, vertIndex:Int, pos:Vector4,
			playfield:SchmovinPlayfield):Vector4
	{
		var out = Camera3DTransforms.RotateVector4(vert, GetOtherPercent('${_modPrefix}rotatex', playfield),
			GetOtherPercent('${_modPrefix}rotatey', playfield), GetOtherPercent('${_modPrefix}rotatez', playfield));
		return out;
	}

	override function ExecutePath(currentBeat:Float, strumTime:Float, column:Int, player:Int, pos:Vector4, playfield:SchmovinPlayfield):Vector4
	{
		var origin:Vector4 = new Vector4(50 + FlxG.width / 2 * player + 2 * Note.swagWidth, FlxG.height / 2);
		if (_origin != null)
			origin = _origin;
		var diff = pos.subtract(origin);

		var out = Camera3DTransforms.RotateVector4(diff, GetOtherPercent('${_modPrefix}rotatex', playfield),
			GetOtherPercent('${_modPrefix}rotatey', playfield), GetOtherPercent('${_modPrefix}rotatez', playfield));

		return origin.add(out);
	}
}
