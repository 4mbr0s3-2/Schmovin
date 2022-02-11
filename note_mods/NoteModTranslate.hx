/**
 * @ Author: 4mbr0s3 2
 * @ Create Time: 2021-07-21 20:23:56
 * @ Modified by: 4mbr0s3 2
 * @ Modified time: 2022-02-10 23:51:08
 */

package schmovin.note_mods;

import lime.math.Vector4;

class NoteModTranslate extends NoteModBase
{
	override function MustExecute():Bool
	{
		return true;
	}

	override function ExecutePath(currentBeat:Float, strumTime:Float, column:Int, player:Int, pos:Vector4, playfield:SchmovinPlayfield):Vector4
	{
		var newPos = pos;
		var extraOffset = new Vector4(GetOtherPercent('xoffset', playfield), GetOtherPercent('yoffset', playfield), GetOtherPercent('zoffset', playfield));
		return newPos.add(new Vector4(GetPercent(playfield), GetOtherPercent('y', playfield), GetOtherPercent('z', playfield)).add(extraOffset));
	}
}
