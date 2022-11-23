/**
 * @ Author: 4mbr0s3 2
 * @ Create Time: 2021-11-28 01:25:38
 * @ Modified by: 4mbr0s3 2
 * @ Modified time: 2022-05-26 17:44:24
 * @ Description:
 */

package schmovin.note_mods;

import flixel.math.FlxMath;
import lime.math.Vector4;
import schmovin.util.Camera3DTransforms;

/**
 * Gotta have some non-NotITG modifiers in here
 * https://www.youtube.com/watch?v=ev3vENli7wQ
 */
class NoteModGantzGraf extends NoteModBase
{
	override function isVertexModifier():Bool
	{
		return true;
	}

	override function executeNoteVertex(currentBeat:Float, strumTime:Float, column:Int, player:Int, vert:Vector4, vertIndex:Int, pos:Vector4,
			playfield:SchmovinPlayfield):Vector4
	{
		var p = getPercent(playfield);
		var angle = Math.random() * p;

		vert = Camera3DTransforms.rotateVector4(vert, angle, angle, angle);
		return vert;
	}
}
