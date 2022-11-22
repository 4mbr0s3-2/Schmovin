/**
 * @ Author: 4mbr0s3 2
 * @ Create Time: 2021-07-16 14:32:19
 * @ Modified by: 4mbr0s3 2
 * @ Modified time: 2021-08-29 15:08:42
 */

package schmovin.note_mods;

import lime.math.Vector4;

using schmovin.SchmovinUtil;

class NoteModInvert extends NoteModBase
{
	override function executePath(currentBeat:Float, strumTime:Float, column:Int, player:Int, pos:Vector4, playfield:SchmovinPlayfield):Vector4
	{
		var playerColumn = column % 4;
		var outPos = pos.clone();
		var neg = (playerColumn % 2 - 0.5) / 0.5;
		outPos.x += Note.swagWidth * getPercent(playfield) * -neg;
		return outPos;
	}
}

class NoteModFlip extends NoteModBase
{
	override function executePath(currentBeat:Float, strumTime:Float, column:Int, player:Int, pos:Vector4, playfield:SchmovinPlayfield):Vector4
	{
		var playerColumn = column % 4;
		var outPos = pos.clone();
		var off = playerColumn - 1.5;
		outPos.x -= Note.swagWidth * off * getPercent(playfield) * 2;
		return outPos;
	}
}
