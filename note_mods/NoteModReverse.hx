/**
 * @ Author: 4mbr0s3 2
 * @ Create Time: 2021-07-15 16:29:37
 * @ Modified by: 4mbr0s3 2
 * @ Modified time: 2021-10-03 00:14:07
 */

package schmovin.note_mods;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.math.FlxMath;
import groovin_input.GroovinInput;
import lime.math.Vector4;

using StringTools;
using schmovin.SchmovinUtil;

class NoteModReverse extends NoteModBase
{
	function GetPercentReverse(column, player)
	{
		var percentReverse = GetPercent(player);
		var playerColumn = column % 4;
		if (playerColumn > 1)
		{
			percentReverse += GetOtherPercent('split', player);
		}
		if (playerColumn > 0 && playerColumn < 3)
		{
			percentReverse += GetOtherPercent('cross', player);
		}
		for (i in 0...4)
		{
			if (playerColumn == i)
			{
				percentReverse += GetOtherPercent('reverse' + i, player);
			}
		}
		percentReverse %= 2;
		if (percentReverse > 1)
		{
			percentReverse = 2 - percentReverse;
		}
		var reverse = GroovinInput.GrabReverse();
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

	function FixDownscroll(note:Note)
	{
		if (note.isSustainNote)
		{
			note.flipY = true;
			// Calculate offset
			if (IsSustainEnd(note))
			{
				if (note.prevNote.exists)
				{
					note.extraData["downscrollFix"] = (note.prevNote.y - note.height) - note.y;
				}
				note.y += note.extraData["downscrollFix"];
			}
		}
	}

	function IsSustainEnd(note:Note)
	{
		return note.animation.name.contains("end");
	}

	function FixUpscroll(note:Note)
	{
		if (note.isSustainNote)
		{
			note.flipY = false;
			// Calculate offset
			if (IsSustainEnd(note))
			{
				if (note.prevNote.exists)
				{
					note.extraData["upscrollFix"] = (note.prevNote.y + note.prevNote.height) - note.y;
				}
				note.y += note.extraData["upscrollFix"];
			}
		}
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

		GroovinInput.ClipRect(note, strumLine);
	}

	override function ExecutePath(currentBeat:Float, strumTimeDiff:Float, column:Int, player:Int, pos:Vector4):Vector4
	{
		var playerColumn = column % 4;
		var reverse = GetPercentReverse(column, player);

		var strumLineY = FlxMath.lerp(50, FlxG.height - 165, reverse);
		var outX = SchmovinUtil.NoteWidthHalf() + 50 + playerColumn * Note.swagWidth + FlxG.width / 2 * player;

		var xmod = GetOtherPercent('xmod', player) + GetOtherPercent('xmod${playerColumn}', player) + 1;
		var forced = GetOtherPercent('forcexmod', player) + GetOtherPercent('forcexmod${playerColumn}', player);

		var scrollSpeed = FlxMath.lerp(GroovinInput.GrabScrollSpeed(PlayState.SONG) * xmod, xmod, forced);
		var upscrollY = SchmovinUtil.NoteWidthHalf() + strumLineY - 0.45 * strumTimeDiff * scrollSpeed;
		var downscrollY = SchmovinUtil.NoteWidthHalf() + strumLineY + 0.45 * strumTimeDiff * scrollSpeed;
		var outY = FlxMath.lerp(upscrollY, downscrollY, reverse);

		return new Vector4(outX, outY, 0, 0);
	}

	function SetDefaultScale(s:FlxSprite)
	{
		if (GroovinInput.IsPixel(s))
			s.scale.set(PlayState.daPixelZoom, PlayState.daPixelZoom);
		else
			s.scale.set(0.7, 0.7);
	}

	override function ExecuteReceptor(currentBeat:Float, receptor:Receptor, player:Int, pos:Vector4)
	{
		receptor.angle = 0;
		SetDefaultScale(receptor.wrappee);
		super.ExecuteReceptor(currentBeat, receptor, player, pos);
	}

	public override function ExecuteNote(currentBeat:Float, note:Note, player:Int, pos:Vector4)
	{
		if (note.shader != null)
			note.shader.hasColorTransform.value = [true];

		var receptorPos = ExecutePath(currentBeat, 0, note.noteData, player, pos).subtract(SchmovinUtil.PosNoteWidthHalf());

		note.angle = 0;
		SetDefaultScale(note);
		super.ExecuteNote(currentBeat, note, player, pos);

		if (note.isSustainNote)
		{
			note.visible = false;
			var time = note.strumTime - Conductor.songPosition;
			note.alpha = FlxMath.bound((1400 - time) / 100, 0, 0.6);
		}

		// else
		// 	note.extraData.set('dirtyFrame', false);

		PolishNote(GetPercentReverse(note.GetTotalColumn(), player), note, receptorPos.y);
	}
}
