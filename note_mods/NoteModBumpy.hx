package schmovin.note_mods;

import flixel.FlxG;
import lime.math.Vector4;

class NoteModBumpy extends NoteModBase
{
	override function ExecutePath(currentBeat:Float, strumTime:Float, column:Int, player:Int, pos:Vector4, playfield:SchmovinPlayfield):Vector4
	{
		var outPos = pos.clone();
		var period = 300;
		outPos.z += Math.sin(GetRelativeTime(strumTime) / period * Math.PI * 2) * Note.swagWidth * GetPercent(playfield);
		return outPos;
	}
}
