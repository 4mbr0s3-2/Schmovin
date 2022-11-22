package schmovin.note_mods;

/**
 * "Blink is a bad mod."
 * TODO: Actually work on this
 */
class NoteModBlink extends NoteModBase
{
	override function executeOther(currentBeat:Float, strumTime:Float, column:Int, player:Int, map:Map<String, Dynamic>, playfield:SchmovinPlayfield)
	{
		map.set('alpha', Math.abs(Math.sin(currentBeat * getPercent(playfield))));
	}
}
