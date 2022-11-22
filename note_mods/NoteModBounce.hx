/**
 * @ Author: 4mbr0s3 2
 * @ Create Time: 2021-08-27 16:52:00
 * @ Modified by: 4mbr0s3 2
 * @ Modified time: 2021-08-29 15:08:37
 */

package schmovin.note_mods;

import lime.math.Vector4;

using schmovin.SchmovinUtil;

class NoteModBounce extends NoteModBase
{
	override function executePath(currentBeat:Float, strumTime:Float, column:Int, player:Int, pos:Vector4, playfield:SchmovinPlayfield):Vector4
	{
		var outPos = pos.clone();

		return outPos.add(new Vector4(outRelative * Note.swagWidth / 2 * getPercent(playfield)));
	}
}
