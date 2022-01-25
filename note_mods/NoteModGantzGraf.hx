/**
 * @ Author: 4mbr0s3 2
 * @ Create Time: 2021-11-28 01:25:38
 * @ Modified by: 4mbr0s3 2
 * @ Modified time: 2022-01-17 23:29:52
 * @ Description:
 */

package schmovin.note_mods;

import flixel.FlxG;
import flixel.math.FlxMath;
import lime.math.Vector4;

/**
 * https://www.youtube.com/watch?v=ev3vENli7wQ
 */
class NoteModGantzGraf extends NoteModBase
{
	override function IsVertexModifier():Bool
	{
		return true;
	}

	static function Rotate(x:Float, y:Float, angle:Float)
	{
		return [
			x * FlxMath.fastCos(angle) - y * FlxMath.fastSin(angle),
			x * FlxMath.fastSin(angle) + y * FlxMath.fastCos(angle)
		];
	}

	public static function RotateVector4(vec:Vector4, angleX:Float, angleY:Float, angleZ:Float)
	{
		var rotateZ = Rotate(vec.x, vec.y, angleZ);
		var offZ = new Vector4(rotateZ[0], rotateZ[1], vec.z);

		var rotateX = Rotate(offZ.z, offZ.y, angleX);
		var offX = new Vector4(offZ.x, rotateX[1], rotateX[0]);

		var rotateY = Rotate(offX.x, offX.z, angleY);
		var offY = new Vector4(rotateY[0], offX.y, rotateY[1]);

		return offY;
	}

	override function ExecuteNoteVertex(currentBeat:Float, strumTime:Float, column:Int, player:Int, vert:Vector4, vertIndex:Int, pos:Vector4,
			playfield:SchmovinPlayfield):Vector4
	{
		var p = GetPercent(playfield);
		var angle = Math.random() * p;

		vert = RotateVector4(vert, angle, angle, angle);
		return vert;
	}
}
