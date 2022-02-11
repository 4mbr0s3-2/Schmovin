/**
 * @ Author: 4mbr0s3 2
 * @ Create Time: 2021-07-23 17:48:21
 * @ Modified by: 4mbr0s3 2
 * @ Modified time: 2022-02-10 23:50:10
 */

package schmovin.note_mods;

import flixel.FlxG;
import flixel.math.FlxMath;
import lime.math.Vector4;

class NoteModRotate extends NoteModBase
{
	var _modPrefix:String;
	var _origin:Vector4;

	override function MustExecute():Bool
	{
		return true;
	}

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
		var out = RotateVector4(vert, GetOtherPercent('${_modPrefix}rotatex', playfield), GetOtherPercent('${_modPrefix}rotatey', playfield),
			GetPercent(playfield));
		return out;
	}

	static inline function Rotate(x:Float, y:Float, angle:Float)
	{
		return [
			x * FlxMath.fastCos(angle) - y * FlxMath.fastSin(angle),
			x * FlxMath.fastSin(angle) + y * FlxMath.fastCos(angle)
		];
	}

	public static inline function RotateVector4(vec:Vector4, angleX:Float, angleY:Float, angleZ:Float)
	{
		var rotateZ = Rotate(vec.x, vec.y, angleZ);
		var offZ = new Vector4(rotateZ[0], rotateZ[1], vec.z);

		var rotateX = Rotate(offZ.z, offZ.y, angleX);
		var offX = new Vector4(offZ.x, rotateX[1], rotateX[0]);

		var rotateY = Rotate(offX.x, offX.z, angleY);
		var offY = new Vector4(rotateY[0], offX.y, rotateY[1]);

		return offY;
	}

	override function ExecutePath(currentBeat:Float, strumTime:Float, column:Int, player:Int, pos:Vector4, playfield:SchmovinPlayfield):Vector4
	{
		var origin:Vector4 = new Vector4(50 + FlxG.width / 2 * player + 2 * Note.swagWidth, FlxG.height / 2);
		if (_origin != null)
			origin = _origin;
		var diff = pos.subtract(origin);

		var out = RotateVector4(diff, GetOtherPercent('${_modPrefix}rotatex', playfield), GetOtherPercent('${_modPrefix}rotatey', playfield),
			GetPercent(playfield));

		return origin.add(out);
	}
}
