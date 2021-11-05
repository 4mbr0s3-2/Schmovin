/**
 * @ Author: 4mbr0s3 2
 * @ Create Time: 2021-07-15 17:13:31
 * @ Modified by: 4mbr0s3 2
 * @ Modified time: 2021-08-29 15:08:47
 */

package schmovin.note_mods;

import lime.math.Vector4;

using schmovin.SchmovinUtil;

class NoteModDrunk extends NoteModBase
{
	override function ExecutePath(currentBeat:Float, strumTimeDiff:Float, column:Int, player:Int, pos:Vector4):Vector4
	{
		var playerColumn = column % 4;
		var phaseShift = playerColumn * 0.5 + GetRelativeTime(strumTimeDiff) / 222 * Math.PI;
		var offsetX = Math.sin(currentBeat / 4 * Math.PI + phaseShift) * Note.swagWidth / 2 * GetPercent(player);
		var outPos = pos.clone();
		return outPos.add(new Vector4(offsetX));
	}
}
