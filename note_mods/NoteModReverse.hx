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
	inline function GetPercentReverse(column, playfield)
	{
		var percentReverse = GetPercent(playfield);
		var playerColumn = column % 4;
		if (playerColumn > 1)
		{
			percentReverse += GetOtherPercent('split', playfield);
		}
		if (playerColumn > 0 && playerColumn < 3)
		{
			percentReverse += GetOtherPercent('cross', playfield);
		}
		for (i in 0...4)
		{
			if (playerColumn == i)
			{
				percentReverse += GetOtherPercent('reverse' + i, playfield);
			}
		}
		percentReverse %= 2;
		if (percentReverse > 1)
		{
			percentReverse = 2 - percentReverse;
		}
		var reverse = SchmovinAdapter.GetInstance().GrabReverse();
		if (reverse)
		{
			percentReverse = 1 - percentReverse;
		}
		return percentReverse;
	}

	override function MustExecute():Bool
	{
		return true;
	}

	function IsSustainEnd(note:Note)
	{
		return note.animation.name.contains("end");
	}

	function PolishNote(reverse:Float, note:Note, strumLine:Float)
	{
		if (note.prevNote.exists && note.prevNote.isSustainNote && !IsSustainEnd(note.prevNote))
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

	function GetNoteX(column:Int, player:Int)
	{
		return SchmovinAdapter.GetInstance().GetDefaultNoteX(column, player);
	}

	override function ExecutePath(currentBeat:Float, strumTime:Float, column:Int, player:Int, pos:Vector4, playfield:SchmovinPlayfield):Vector4
	{
		var playerColumn = column % 4;
		var reverse = GetPercentReverse(column, playfield);

		var strumLineY = FlxMath.lerp(50, FlxG.height - 165, reverse);
		var outX = GetNoteX(column, player);

		var xmod = GetOtherPercent('xmod', playfield) + GetOtherPercent('xmod${playerColumn}', playfield) + 1;
		var forced = GetOtherPercent('forcexmod', playfield) + GetOtherPercent('forcexmod${playerColumn}', playfield);

		var scrollSpeed = FlxMath.lerp(SchmovinAdapter.GetInstance().GrabScrollSpeed() * xmod, xmod, forced);
		var upscrollY = SchmovinUtil.NoteWidthHalf() + strumLineY - 0.45 * strumTime * scrollSpeed;
		var downscrollY = SchmovinUtil.NoteWidthHalf() + strumLineY + 0.45 * strumTime * scrollSpeed;
		var outY = FlxMath.lerp(upscrollY, downscrollY, reverse);

		return new Vector4(outX, outY, 0, 0);
	}

	function SetDefaultScale(s:FlxSprite)
	{
		if (SchmovinInstance.IsPixelStage())
			s.scale.set(PlayState.daPixelZoom, PlayState.daPixelZoom);
		else
			s.scale.set(0.7, 0.7);
	}

	override function ExecuteReceptor(currentBeat:Float, receptor:Receptor, player:Int, pos:Vector4, playfield:SchmovinPlayfield)
	{
		receptor.angle = 0;

		// Hide for rendering
		receptor.visible = false;

		SetDefaultScale(receptor.wrappee);
		super.ExecuteReceptor(currentBeat, receptor, player, pos, playfield);
	}

	public override function ExecuteNote(currentBeat:Float, note:Note, player:Int, pos:Vector4, playfield:SchmovinPlayfield)
	{
		if (note.shader != null)
			note.shader.hasColorTransform.value = [true];

		var receptorPos = ExecutePath(currentBeat, 0, note.noteData, player, pos, playfield).subtract(SchmovinUtil.PosNoteWidthHalf());

		note.angle = 0;
		SetDefaultScale(note);
		super.ExecuteNote(currentBeat, note, player, pos, playfield);

		// Hide for rendering
		note.visible = false;

		// if (note.isSustainNote)
		// {
		// 	var time = note.strumTime - SchmovinAdapter.GetInstance().GetSongPosition();
		// 	note.alpha = FlxMath.bound((1400 - time) / 100, 0, 0.6);
		// }

		// else
		// 	note.extraData.set('dirtyFrame', false);

		PolishNote(GetPercentReverse(note.GetTotalColumn(), playfield), note, receptorPos.y);
	}
}
