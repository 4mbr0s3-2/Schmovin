/**
 * @ Author: 4mbr0s3 2
 * @ Create Time: 2021-07-15 19:47:00
 * @ Modified by: 4mbr0s3 2
 * @ Modified time: 2022-05-26 17:44:16
 */

package schmovin.note_mods;

import flixel.FlxG;
import flixel.math.FlxMath;
import lime.math.Vector4;
import schmovin.util.Camera3DTransforms;

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

	override function ExecuteNoteVertex(currentBeat:Float, strumTime:Float, column:Int, player:Int, vert:Vector4, vertIndex:Int, pos:Vector4,
			playfield:SchmovinPlayfield):Vector4
	{
		var angleZ = GetTotalConfusion(currentBeat, playfield, column, 'z');
		var angleX = GetTotalConfusion(currentBeat, playfield, column, 'x');
		var angleY = GetTotalConfusion(currentBeat, playfield, column, 'y');
		var out = vert.clone();
		out = Camera3DTransforms.RotateVector4(out, angleX, angleY, angleZ);
		return out;
	}

	override function IsVertexModifier():Bool
	{
		return true;
	}
}
