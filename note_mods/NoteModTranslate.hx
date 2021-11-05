/**
 * @ Author: 4mbr0s3 2
 * @ Create Time: 2021-07-21 20:23:56
 * @ Modified by: 4mbr0s3 2
 * @ Modified time: 2021-08-29 21:16:23
 */

package schmovin.note_mods;

import lime.math.Vector4;

class NoteModTranslate extends NoteModBase
{
	override function MustExecute():Bool
	{
		return true;
	}

	override function ExecutePath(currentBeat:Float, strumTimeDiff:Float, column:Int, player:Int, pos:Vector4):Vector4
	{
		var newPos = pos.clone();
		var extraOffset = new Vector4(GetOtherPercent('xoffset', player), GetOtherPercent('yoffset', player), GetOtherPercent('zoffset', player));
		return newPos.add(new Vector4(GetPercent(player), GetOtherPercent('y', player), GetOtherPercent('z', player)).add(extraOffset));
	}
}
