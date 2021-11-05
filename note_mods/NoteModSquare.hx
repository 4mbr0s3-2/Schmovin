/**
 * @ Author: 4mbr0s3 2
 * @ Create Time: 2021-08-27 16:56:46
 * @ Modified by: 4mbr0s3 2
 * @ Modified time: 2021-08-29 15:08:55
 */

package schmovin.note_mods;

import lime.math.Vector4;

using schmovin.SchmovinUtil;

class NoteModSquare extends NoteModBase
{
	override function ExecutePath(currentBeat:Float, strumTimeDiff:Float, column:Int, player:Int, pos:Vector4):Vector4
	{
		var outPos = pos.clone();
		var period = 200;
		var time = -GetRelativeTime(strumTimeDiff) / period + 1;
		var phaseShift = -0.001;
		var offX = (Math.floor(time + phaseShift)) % 2 - 0.5;

		return outPos.add(new Vector4(offX * Note.swagWidth * GetPercent(player)));
	}
}
