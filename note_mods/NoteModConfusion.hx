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
	private inline function getTotalConfusion(currentBeat:Float, playfield:SchmovinPlayfield, column:Int, axis:String = 'x')
	{
		var playerColumn = column % 4;
		var offsetConfusion = currentBeat * 45 * getPercent(playfield);
		var offsetConfusionOff = getOtherPercent('confusion${axis}offset', playfield);
		offsetConfusionOff += getOtherPercent('confusion${axis}offset${playerColumn}', playfield);
		return offsetConfusion + offsetConfusionOff;
	}

	override function executeNoteVertex(currentBeat:Float, strumTime:Float, column:Int, player:Int, vert:Vector4, vertIndex:Int, pos:Vector4,
			playfield:SchmovinPlayfield):Vector4
	{
		var angleZ = getTotalConfusion(currentBeat, playfield, column, 'z');
		var angleX = getTotalConfusion(currentBeat, playfield, column, 'x');
		var angleY = getTotalConfusion(currentBeat, playfield, column, 'y');
		var out = vert.clone();
		out = Camera3DTransforms.rotateVector4(out, angleX, angleY, angleZ);
		return out;
	}

	override function isVertexModifier():Bool
	{
		return true;
	}
}
