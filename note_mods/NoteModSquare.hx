/**
 * @ Author: 4mbr0s3 2
 * @ Create Time: 2021-08-27 16:56:46
 * @ Modified by: 4mbr0s3 2
 * @ Modified time: 2021-12-01 00:17:41
 */

package schmovin.note_mods;

import lime.math.Vector4;

using schmovin.SchmovinUtil;

class NoteModSquare extends NoteModBase
{
	override function executePath(currentBeat:Float, strumTime:Float, column:Int, player:Int, pos:Vector4, playfield:SchmovinPlayfield):Vector4
	{
		var outPos = pos.clone();
		var period = 200;
		var time = -getRelativeTime(strumTime) / period + 1;
		var phaseShift = -0.001;
		var offX = (Math.floor(time + phaseShift)) % 2 - 0.5;

		return outPos.add(new Vector4(offX * Note.swagWidth * getPercent(playfield)));
	}
}
