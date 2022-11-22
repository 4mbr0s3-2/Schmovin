/**
 * @ Author: 4mbr0s3 2
 * @ Create Time: 2021-07-16 13:18:59
 * @ Modified by: 4mbr0s3 2
 * @ Modified time: 2022-01-17 23:29:48
 */

package schmovin.note_mods;

import flixel.math.FlxPoint;
import lime.math.Vector4;

using schmovin.SchmovinUtil;

class NoteModTiny extends NoteModBase
{
	private function getScale(column:Int, playfield:SchmovinPlayfield)
	{
		var playerColumn = column % 4;
		var scale = new FlxPoint(1, 1);
		scale.scale(1 - getPercent(playfield) * 0.5);
		scale.scale(1 - getOtherPercent('tiny${playerColumn}', playfield) * 0.5);
		scale.x *= 1 - getOtherPercent('tinyx${playerColumn}', playfield) * 0.5;
		scale.y *= 1 - getOtherPercent('tinyy${playerColumn}', playfield) * 0.5;
		scale.x *= 1 - getOtherPercent('tinyx', playfield) * 0.5;
		scale.y *= 1 - getOtherPercent('tinyy', playfield) * 0.5;
		return scale;
	}

	override function isVertexModifier():Bool
	{
		return true;
	}

	override function executeNoteVertex(currentBeat:Float, strumTime:Float, column:Int, player:Int, vert:Vector4, vertIndex:Int, pos:Vector4,
			playfield:SchmovinPlayfield):Vector4
	{
		var scale = getScale(column, playfield);
		var outVert = vert.clone();
		outVert.x *= scale.x;
		outVert.y *= scale.y;
		return outVert;
	}
}
