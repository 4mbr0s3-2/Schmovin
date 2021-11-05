/**
 * @ Author: 4mbr0s3 2
 * @ Create Time: 2021-07-15 19:47:00
 * @ Modified by: 4mbr0s3 2
 * @ Modified time: 2021-11-02 18:35:06
 */

package schmovin.note_mods;

import lime.math.Vector4;

using schmovin.SchmovinUtil;

class NoteModConfusion extends NoteModBase
{
	override function MustExecute():Bool
	{
		return true;
	}

	function GetTotalConfusion(currentBeat:Float, player:Int, column:Int)
	{
		var playerColumn = column % 4;
		var offsetConfusion = currentBeat * 45 * GetPercent(player);
		var offsetConfusionOff = GetOtherPercent('confusionzoffset', player);
		offsetConfusionOff += GetOtherPercent('confusionzoffset${playerColumn}', player);
		return offsetConfusion + offsetConfusionOff / Math.PI * 180;
	}

	override function ExecuteReceptor(currentBeat:Float, receptor:Receptor, player:Int, pos:Vector4)
	{
		receptor.angle = GetTotalConfusion(currentBeat, player, receptor.column);
		super.ExecuteReceptor(currentBeat, receptor, player, pos);
	}

	override function ExecuteNote(currentBeat:Float, note:Note, player:Int, pos:Vector4)
	{
		note.angle = GetTotalConfusion(currentBeat, player, note.noteData);
		super.ExecuteNote(currentBeat, note, player, pos);
	}
}
