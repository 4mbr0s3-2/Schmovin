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
	override function MustExecute():Bool
	{
		return true;
	}

	function GetScale(column:Int, playfield:SchmovinPlayfield)
	{
		var playerColumn = column % 4;
		var scale = new FlxPoint(1, 1);
		scale.scale(1 - GetPercent(playfield) * 0.5);
		scale.scale(1 - GetOtherPercent('tiny${playerColumn}', playfield) * 0.5);
		scale.x *= 1 - GetOtherPercent('tinyx${playerColumn}', playfield) * 0.5;
		scale.y *= 1 - GetOtherPercent('tinyy${playerColumn}', playfield) * 0.5;
		scale.x *= 1 - GetOtherPercent('tinyx', playfield) * 0.5;
		scale.y *= 1 - GetOtherPercent('tinyy', playfield) * 0.5;
		return scale;
	}

	override function IsVertexModifier():Bool
	{
		return true;
	}

	override function ExecuteNoteVertex(currentBeat:Float, strumTime:Float, column:Int, player:Int, vert:Vector4, vertIndex:Int, pos:Vector4,
			playfield:SchmovinPlayfield):Vector4
	{
		var scale = GetScale(column, playfield);
		var outVert = vert.clone();
		outVert.x *= scale.x;
		outVert.y *= scale.y;
		return outVert;
	}
}
