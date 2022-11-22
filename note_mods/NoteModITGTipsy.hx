/**
 * @ Author: 4mbr0s3 2
 * @ Create Time: 2021-07-15 16:50:55
 * @ Modified by: 4mbr0s3 2
 * @ Modified time: 2022-09-11 22:34:18
 */

package schmovin.note_mods;

import lime.math.Vector4;

using schmovin.SchmovinUtil;

class NoteModITGTipsy extends NoteModBase
{
	override function executePath(currentBeat:Float, strumTime:Float, column:Int, player:Int, pos:Vector4, playfield:SchmovinPlayfield):Vector4
	{
		var playerColumn = column % 4;
		var newPos = pos.clone();
		var offset = Math.cos(Conductor.songPosition * 1.2 + playerColumn * 1.8) * Note.swagWidth * 0.4 * getPercent(playfield);
		return newPos.add(new Vector4(0, offset));
	}
}
