/**
 * @ Author: 4mbr0s3 2
 * @ Create Time: 2021-07-15 17:13:31
 * @ Modified by: 4mbr0s3 2
 * @ Modified time: 2021-12-01 00:13:32
 */

package schmovin.note_mods;

import lime.math.Vector4;

using schmovin.SchmovinUtil;

class NoteModDrunk extends NoteModBase
{
	override function executePath(currentBeat:Float, strumTime:Float, column:Int, player:Int, pos:Vector4, playfield:SchmovinPlayfield):Vector4
	{
		var playerColumn = column % 4;
		var phaseShift = playerColumn * 0.5 + getRelativeTime(strumTime) / 222 * Math.PI;
		var offsetX = Math.sin(currentBeat / 4 * Math.PI + phaseShift) * Note.swagWidth / 2 * getPercent(playfield);
		var outPos = pos.clone();
		return outPos.add(new Vector4(offsetX));
	}
}
