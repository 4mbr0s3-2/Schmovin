package schmovin;

import flixel.FlxG;
import groovin.mod.ModHooks;
import groovin.util.GroovinConductor;
import groovin_input.GroovinInput;

// Don't you love these naming conventions?
class GroovinSchmovinAdapter extends SchmovinAdapter
{
	override function forEveryMod(param:Array<Dynamic>)
	{
		ModHooks.forEveryMod((mod) ->
		{
			mod.receiveCrossModCall('SchmovinSetClient', null, param);
		});
	}

	override function getCrotchetAtTime(time:Float):Float
	{
		return GroovinConductor.getCrotchetAtTime(time);
	}

	override function grabScrollSpeed():Float
	{
		return GroovinInput.grabScrollSpeed(PlayState.SONG);
	}

	override function grabReverse():Bool
	{
		return GroovinInput.grabReverse();
	}

	override function getCrotchetNow():Float
	{
		return GroovinConductor.getCrotchetNow();
	}

	override function getSongPosition():Float
	{
		return Conductor.songPosition;
	}

	override function grabGlobalVisualOffset()
	{
		return GroovinInput.grabGlobalVisualOffset();
	}

	override function shouldCacheNoteBitmap(note:Note):Bool
	{
		return !note.extraData.exists('forceBitmap');
	}

	override function getCurrentBeat():Float
	{
		return GroovinConductor.getTotalBeatsToTime(getSongPosition());
	}

	override function getHoldNoteSubdivisions():Int
	{
		return Schmovin.holdNoteSubdivisions;
	}

	override function getArrowPathSubdivisions():Int
	{
		return Schmovin.arrowPathSubdivisions;
	}

	override function getDefaultNoteX(column:Int, player:Int)
	{
		var playerColumn = column % 4;
		return SchmovinUtil.getNoteWidthHalf() + 50 + playerColumn * Note.swagWidth + FlxG.width / 2 * player;
	}

	override function getOptimizeHoldNotes():Bool
	{
		return Schmovin.optimizeHoldNotes;
	}
}
