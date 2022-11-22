/**
 * @ Author: 4mbr0s3 2
 * @ Create Time: 2021-07-21 20:23:56
 * @ Modified by: 4mbr0s3 2
 * @ Modified time: 2022-03-07 20:35:12
 */

package schmovin.note_mods;

import lime.math.Vector4;

class NoteModTranslate extends NoteModBase
{
	override function executePath(currentBeat:Float, strumTime:Float, column:Int, player:Int, pos:Vector4, playfield:SchmovinPlayfield):Vector4
	{
		var newPos = pos;
		var extraOffset = new Vector4(getOtherPercent('xoffset', playfield), getOtherPercent('yoffset', playfield), getOtherPercent('zoffset', playfield));
		return newPos.add(new Vector4(getOtherPercent('x', playfield), getOtherPercent('y', playfield), getOtherPercent('z', playfield)).add(extraOffset));
	}
}
