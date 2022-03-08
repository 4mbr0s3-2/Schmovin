/**
 * @ Author: 4mbr0s3 2
 * @ Create Time: 2021-07-15 19:47:00
 * @ Modified by: 4mbr0s3 2
 * @ Modified time: 2022-03-07 19:01:21
 */

package schmovin.note_mods;

import flixel.FlxG;
import flixel.math.FlxMath;
import lime.math.Vector4;

using schmovin.SchmovinUtil;

class NoteModConfusion extends NoteModBase
{
	inline function GetTotalConfusion(currentBeat:Float, playfield:SchmovinPlayfield, column:Int, axis:String = 'x')
	{
		var playerColumn = column % 4;
		var offsetConfusion = currentBeat * 45 * GetPercent(playfield);
		var offsetConfusionOff = GetOtherPercent('confusion${axis}offset', playfield);
		offsetConfusionOff += GetOtherPercent('confusion${axis}offset${playerColumn}', playfield);
		return offsetConfusion + offsetConfusionOff;
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
		var angleZ = GetTotalConfusion(currentBeat, playfield, column, 'z');
		var angleX = GetTotalConfusion(currentBeat, playfield, column, 'x');
		var angleY = GetTotalConfusion(currentBeat, playfield, column, 'y');
		var out = vert.clone();
		out = RotateVector4(out, angleX, angleY, angleZ);
		return out;
	}

	override function IsVertexModifier():Bool
	{
		return true;
	}
}
