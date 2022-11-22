/**
 * @ Author: 4mbr0s3 2
 * @ Create Time: 2021-07-15 17:13:31
 * @ Modified by: 4mbr0s3 2
 * @ Modified time: 2022-09-11 23:34:19
 */

package schmovin.note_mods;

import flixel.FlxG;
import lime.math.Vector4;

using schmovin.SchmovinUtil;

/**
 * "Drunk" as implemented in OpenITG.
 * https://github.com/openitg/openitg/blob/master/src/ArrowEffects.cpp
 */
class NoteModITGDrunk extends NoteModBase
{
	override function executePath(currentBeat:Float, strumTime:Float, column:Int, player:Int, pos:Vector4, playfield:SchmovinPlayfield):Vector4
	{
		var playerColumn = column % 4;
		var phaseShift = playerColumn * 0.2 + getRelativeTime(strumTime) * 10 / FlxG.height;
		var offsetX = Math.cos(phaseShift + Conductor.songPosition / 1000) * Note.swagWidth / 2 * getPercent(playfield);
		var outPos = pos.clone();
		return outPos.add(new Vector4(offsetX));
	}
}
