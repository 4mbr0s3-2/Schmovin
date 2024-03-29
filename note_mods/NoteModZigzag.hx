/**
 * @ Author: 4mbr0s3 2
 * @ Create Time: 2021-08-27 16:20:56
 * @ Modified by: 4mbr0s3 2
 * @ Modified time: 2021-08-29 15:09:05
 */

package schmovin.note_mods;

import lime.math.Vector4;

using schmovin.SchmovinUtil;

class NoteModZigzag extends NoteModBase
{
	override function ExecutePath(currentBeat:Float, strumTimeDiff:Float, column:Int, player:Int, pos:Vector4):Vector4
	{
		var period = Note.swagWidth;
		var theta = -GetRelativeTime(strumTimeDiff) / period * Math.PI;
		var outRelative = Math.acos(Math.cos(theta + Math.PI / 2)) / Math.PI * 2 - 1;
		var outPos = pos.clone();

		return outPos.add(new Vector4(outRelative * Note.swagWidth / 2 * GetPercent(player)));
	}
}
