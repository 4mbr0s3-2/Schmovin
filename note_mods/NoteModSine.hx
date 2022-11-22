/**
 * @ Author: 4mbr0s3 2
 * @ Create Time: 2021-08-27 16:56:46
 * @ Modified by: 4mbr0s3 2
 * @ Modified time: 2021-11-02 18:34:33
 */

package schmovin.note_mods;

import flixel.FlxG;
import lime.math.Vector4;

using schmovin.SchmovinUtil;

class NoteModSine extends NoteModBase
{
	override function executePath(currentBeat:Float, strumTime:Float, column:Int, player:Int, pos:Vector4, playfield:SchmovinPlayfield):Vector4
	{
		var outPos = pos.clone();
		var offsetFromCenter = outPos.subtract(new Vector4(FlxG.width / 2.0, FlxG.height / 2.0));
		// Apply a wavy sine wave effect based on the position from the center.
		outPos.y += offsetFromCenter.length * Math.sin(offsetFromCenter.length / 100.0 + currentBeat * 2.0 * Math.PI) * getPercent(playfield);
		// Zamn, Copilot's good
		return outPos;
	}
}
