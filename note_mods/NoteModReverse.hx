/**
 * @ Author: 4mbr0s3 2
 * @ Create Time: 2021-07-15 16:29:37
 * @ Modified by: 4mbr0s3 2
 * @ Modified time: 2022-02-10 23:49:29
 */

package schmovin.note_mods;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.math.FlxMath;
import lime.math.Vector4;

using StringTools;
using schmovin.SchmovinUtil;

class NoteModReverse extends NoteModBase
{
	private inline function getPercentReverse(column, playfield)
	{
		var percentReverse = getPercent(playfield);
		var playerColumn = column % 4;
		if (playerColumn > 1)
		{
			percentReverse += getOtherPercent('split', playfield);
		}
		if (playerColumn > 0 && playerColumn < 3)
		{
			percentReverse += getOtherPercent('cross', playfield);
		}
		for (i in 0...4)
		{
			if (playerColumn == i)
			{
				percentReverse += getOtherPercent('reverse' + i, playfield);
			}
		}
		percentReverse %= 2;
		if (percentReverse > 1)
		{
			percentReverse = 2 - percentReverse;
		}
		var reverse = SchmovinAdapter.getInstance().grabReverse();
		if (reverse)
		{
			percentReverse = 1 - percentReverse;
		}
		return percentReverse;
	}

	override function alwaysExecute():Bool
	{
		return true;
	}

	private function isSustainEnd(note:Note)
	{
		return note.animation.name.contains("end");
	}

	private function polishNote(reverse:Float, note:Note, strumLine:Float)
	{
		if (note.prevNote.exists && note.prevNote.isSustainNote && !isSustainEnd(note.prevNote))
		{
			note.prevNote.scale.set(note.prevNote.scale.x, Math.abs(note.prevNote.y - note.y) / (note.prevNote.frameHeight - 2));
			note.prevNote.updateHitbox();
		}

		// No longer needed with new hold note rendering system

		// if (reverse > 0.5)
		// {
		// 	FixDownscroll(note);
		// 	GroovinInput.ClipRectReverse(note, strumLine);
		// }
		// else
		// {
		// 	FixUpscroll(note);
		// 	GroovinInput.ClipRect(note, strumLine);
		// }

		// GroovinInput.ClipRect(note, strumLine);
	}

	private function getNoteX(column:Int, player:Int)
	{
		return SchmovinAdapter.getInstance().getDefaultNoteX(column, player);
	}

	override function executePath(currentBeat:Float, strumTime:Float, column:Int, player:Int, pos:Vector4, playfield:SchmovinPlayfield):Vector4
	{
		var playerColumn = column % 4;
		var reverse = getPercentReverse(column, playfield);

		var strumLineY = FlxMath.lerp(50, FlxG.height - 165, reverse);
		var outX = getNoteX(column, player);

		var xmod = getOtherPercent('xmod', playfield) + getOtherPercent('xmod${playerColumn}', playfield) + 1;
		var forced = getOtherPercent('forcexmod', playfield) + getOtherPercent('forcexmod${playerColumn}', playfield);

		var scrollSpeed = FlxMath.lerp(SchmovinAdapter.getInstance().grabScrollSpeed() * xmod, xmod, forced);
		var upscrollY = SchmovinUtil.getNoteWidthHalf() + strumLineY - 0.45 * strumTime * scrollSpeed;
		var downscrollY = SchmovinUtil.getNoteWidthHalf() + strumLineY + 0.45 * strumTime * scrollSpeed;
		var outY = FlxMath.lerp(upscrollY, downscrollY, reverse);

		return new Vector4(outX, outY, 0, 0);
	}

	private function setDefaultScale(s:FlxSprite)
	{
		if (SchmovinInstance.isPixelStage())
			s.scale.set(PlayState.daPixelZoom, PlayState.daPixelZoom);
		else
			s.scale.set(0.7, 0.7);
	}

	override function executeReceptor(currentBeat:Float, receptor:Receptor, player:Int, pos:Vector4, playfield:SchmovinPlayfield)
	{
		receptor.angle = 0;

		// Hide for rendering
		receptor.visible = false;

		setDefaultScale(receptor.wrappee);
		super.executeReceptor(currentBeat, receptor, player, pos, playfield);
	}

	public override function executeNote(currentBeat:Float, note:Note, player:Int, pos:Vector4, playfield:SchmovinPlayfield)
	{
		if (note.shader != null)
			note.shader.hasColorTransform.value = [true];

		var receptorPos = executePath(currentBeat, 0, note.noteData, player, pos, playfield).subtract(SchmovinUtil.posGetNoteWidthHalf());

		note.angle = 0;
		setDefaultScale(note);
		super.executeNote(currentBeat, note, player, pos, playfield);

		// Hide for rendering
		note.visible = false;

		// if (note.isSustainNote)
		// {
		// 	var time = note.strumTime - SchmovinAdapter.getInstance().getSongPosition();
		// 	note.alpha = FlxMath.bound((1400 - time) / 100, 0, 0.6);
		// }

		// else
		// 	note.extraData.set('dirtyFrame', false);

		polishNote(getPercentReverse(note.getTotalColumn(), playfield), note, receptorPos.y);
	}
}
