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

	override function alwaysExecute():Bool
	{
		return true;
	}

	override function isVertexModifier():Bool
	{
		return true;
	}

	override function executeOther(currentBeat:Float, strumTime:Float, column:Int, player:Int, map:Map<String, Dynamic>, playfield:SchmovinPlayfield)
	{
		var x = map.get('angleX');
		if (x != null)
			playfield.setPercent('${_modPrefix}othernoterotatex', x);
		var y = map.get('angleY');
		if (y != null)
			playfield.setPercent('${_modPrefix}othernoterotatey', y);
		var z = map.get('angleZ');
		if (z != null)
			playfield.setPercent('${_modPrefix}othernoterotatez', z);
	}

	override function executeNoteVertex(currentBeat:Float, strumTime:Float, column:Int, player:Int, vert:Vector4, vertIndex:Int, pos:Vector4,
			playfield:SchmovinPlayfield):Vector4
	{
		var angleX = getOtherPercent('${_modPrefix}noterotatex', playfield)
			+ getOtherPercent('${_modPrefix}othernoterotatex', playfield)
			+ getOtherPercent('${_modPrefix}noterotatex${column}', playfield);
		var angleY = getOtherPercent('${_modPrefix}noterotatey', playfield)
			+ getOtherPercent('${_modPrefix}othernoterotatey', playfield)
			+ getOtherPercent('${_modPrefix}noterotatey${column}', playfield);
		var angleZ = getOtherPercent('${_modPrefix}noterotatez', playfield)
			+ getOtherPercent('${_modPrefix}othernoterotatez', playfield)
			+ getOtherPercent('${_modPrefix}noterotatez${column}', playfield);
		var out = Camera3DTransforms.rotateVector4(vert, angleX, angleY, angleZ);
		return out;
	}
}
