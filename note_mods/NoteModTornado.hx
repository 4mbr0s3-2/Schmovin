/**
 * @ Author: 4mbr0s3 2
 * @ Create Time: 2021-08-23 17:54:36
 * @ Modified by: 4mbr0s3 2
 * @ Modified time: 2021-12-01 00:15:15
 */

package schmovin.note_mods;

import flixel.math.FlxMath;
import lime.math.Vector4;

using schmovin.SchmovinUtil;

class NoteModTornado extends NoteModBase
{
	override function executePath(currentBeat:Float, strumTime:Float, column:Int, player:Int, pos:Vector4, playfield:SchmovinPlayfield):Vector4
	{
		var playerColumn = column % 4;
		var columnPhaseShift = playerColumn * Math.PI / 3;
		var phaseShift = getRelativeTime(strumTime) / 135;
		var returnReceptorToZeroOffsetX = (-Math.cos(-columnPhaseShift) + 1) / 2 * Note.swagWidth * 3;
		var offsetX = (-Math.cos(phaseShift - columnPhaseShift) + 1) / 2 * Note.swagWidth * 3 - returnReceptorToZeroOffsetX;
		var outPos = pos.clone();
		return outPos.add(new Vector4(offsetX * getPercent(playfield)));
	}
}
