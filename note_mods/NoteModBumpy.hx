package schmovin.note_mods;

import flixel.FlxG;
import lime.math.Vector4;

class NoteModBumpy extends NoteModBase
{
	override function executePath(currentBeat:Float, strumTime:Float, column:Int, player:Int, pos:Vector4, playfield:SchmovinPlayfield):Vector4
	{
		var outPos = pos.clone();
		var period = 300;
		outPos.z += Math.sin(getRelativeTime(strumTime) / period * Math.PI * 2) * Note.swagWidth * getPercent(playfield);
		return outPos;
	}
}
