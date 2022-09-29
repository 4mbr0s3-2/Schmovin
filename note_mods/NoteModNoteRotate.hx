/**
 * @ Author: 4mbr0s3 2
 * @ Create Time: 2021-07-23 17:48:21
 * @ Modified by: 4mbr0s3 2
 * @ Modified time: 2022-09-11 12:23:54
 */

package schmovin.note_mods;

import flixel.FlxG;
import flixel.math.FlxMath;
import lime.math.Vector4;
import schmovin.util.Camera3DTransforms;

/**
	This is technically confusion offset
**/
class NoteModNoteRotate extends NoteModBase
{
	var _modPrefix:String;
	var _origin:Vector4;

	override public function new(modPrefix:String = '', origin:Vector4 = null)
	{
		_modPrefix = modPrefix;
		_origin = origin;
		super();
	}

	override function MustExecute():Bool
	{
		return true;
	}

	override function IsVertexModifier():Bool
	{
		return true;
	}

	override function ExecuteOther(currentBeat:Float, strumTime:Float, column:Int, player:Int, map:Map<String, Dynamic>, playfield:SchmovinPlayfield)
	{
		var x = map.get('angleX');
		if (x != null)
			playfield.SetPercent('${_modPrefix}othernoterotatex', x);
		var y = map.get('angleY');
		if (y != null)
			playfield.SetPercent('${_modPrefix}othernoterotatey', y);
		var z = map.get('angleZ');
		if (z != null)
			playfield.SetPercent('${_modPrefix}othernoterotatez', z);
	}

	override function ExecuteNoteVertex(currentBeat:Float, strumTime:Float, column:Int, player:Int, vert:Vector4, vertIndex:Int, pos:Vector4,
			playfield:SchmovinPlayfield):Vector4
	{
		var angleX = GetOtherPercent('${_modPrefix}noterotatex', playfield)
			+ GetOtherPercent('${_modPrefix}othernoterotatex', playfield)
			+ GetOtherPercent('${_modPrefix}noterotatex${column}', playfield);
		var angleY = GetOtherPercent('${_modPrefix}noterotatey', playfield)
			+ GetOtherPercent('${_modPrefix}othernoterotatey', playfield)
			+ GetOtherPercent('${_modPrefix}noterotatey${column}', playfield);
		var angleZ = GetOtherPercent('${_modPrefix}noterotatez', playfield)
			+ GetOtherPercent('${_modPrefix}othernoterotatez', playfield)
			+ GetOtherPercent('${_modPrefix}noterotatez${column}', playfield);
		var out = Camera3DTransforms.RotateVector4(vert, angleX, angleY, angleZ);
		return out;
	}
}
