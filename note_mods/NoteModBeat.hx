/**
 * @ Author: 4mbr0s3 2
 * @ Create Time: 2021-07-15 17:59:30
 * @ Modified by: 4mbr0s3 2
 * @ Modified time: 2022-01-04 21:47:30
 */

package schmovin.note_mods;

import flixel.tweens.FlxEase;
import lime.math.Vector4;

using schmovin.SchmovinUtil;

class NoteModBeat extends NoteModBase
{
	private function getAmplitude(currentBeat:Float)
	{
		var beat = currentBeat % 1;
		var amp:Float = 0;
		if (beat <= 0.3)
			amp = FlxEase.quadIn((0.3 - beat) / 0.3) * 0.3;
		else if (beat >= 0.7)
			amp = -FlxEase.quadOut((beat - 0.7) / 0.3) * 0.3;
		var neg = 1;
		if (currentBeat % 2 >= 1)
			neg = -1;
		return amp / 0.3 * neg;
	}

	override function executePath(currentBeat:Float, strumTimeDiff:Float, column:Int, player:Int, pos:Vector4, playfield:SchmovinPlayfield):Vector4
	{
		var newPos = pos.clone();
		var amp = getAmplitude(currentBeat) * Math.cos(getRelativeTime(strumTimeDiff) / 45);
		var offsetX = amp * Note.swagWidth / 2 * getPercent(playfield);
		return newPos.add(new Vector4(offsetX));
	}
}
