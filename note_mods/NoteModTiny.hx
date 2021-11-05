/**
 * @ Author: 4mbr0s3 2
 * @ Create Time: 2021-07-16 13:18:59
 * @ Modified by: 4mbr0s3 2
 * @ Modified time: 2021-08-29 15:08:57
 */

package schmovin.note_mods;

import flixel.math.FlxPoint;
import lime.math.Vector4;

using schmovin.SchmovinUtil;

class NoteModTiny extends NoteModBase
{
	override function MustExecute():Bool
	{
		return true;
	}

	function GetScale(column:Int, player:Int)
	{
		var playerColumn = column % 4;
		var scale = new FlxPoint(1, 1);
		scale.scale(1 - GetPercent(player) * 0.5);
		scale.scale(1 - GetOtherPercent('tiny${playerColumn}', player) * 0.5);
		scale.x *= 1 - GetOtherPercent('tinyx${playerColumn}', player) * 0.5;
		scale.y *= 1 - GetOtherPercent('tinyy${playerColumn}', player) * 0.5;
		scale.x *= 1 - GetOtherPercent('tinyx', player) * 0.5;
		scale.y *= 1 - GetOtherPercent('tinyy', player) * 0.5;
		return scale;
	}

	override function ExecuteNote(currentBeat:Float, note:Note, player:Int, pos:Vector4)
	{
		var scale = GetScale(note.noteData, player);
		note.scale.x *= scale.x;
		note.scale.y *= scale.y;
	}

	override function ExecuteReceptor(currentBeat:Float, receptor:Receptor, player:Int, pos:Vector4)
	{
		var scale = GetScale(receptor.column, player);
		receptor.scale.x *= scale.x;
		receptor.scale.y *= scale.y;
	}
}
