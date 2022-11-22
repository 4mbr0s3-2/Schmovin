/**
 * @ Author: 4mbr0s3 2
 * @ Create Time: 2021-07-15 16:50:55
 * @ Modified by: 4mbr0s3 2
 * @ Modified time: 2021-08-29 15:08:59
 */

package schmovin.note_mods;

import lime.math.Vector4;

using schmovin.SchmovinUtil;

class NoteModTipsy extends NoteModBase
{
	override function executePath(currentBeat:Float, strumTime:Float, column:Int, player:Int, pos:Vector4, playfield:SchmovinPlayfield):Vector4
	{
		var playerColumn = column % 4;
		var newPos = pos.clone();
		var offset = Math.sin(currentBeat / 4 * Math.PI + playerColumn) * Note.swagWidth / 2 * getPercent(playfield);
		return newPos.add(new Vector4(0, offset));
	}
}
