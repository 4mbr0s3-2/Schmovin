package schmovin;

import groovin.mod.ModHooks;
import groovin.util.GroovinConductor;
import groovin_input.GroovinInput;

// Don't you love these naming conventions?
class GroovinSchmovinAdapter extends SchmovinAdapter
{
	override function ForEveryMod(param:Array<Dynamic>)
	{
		ModHooks.ForEveryMod((mod) ->
		{
			mod.ReceiveCrossModCall('SchmovinSetClient', null, param);
		});
	}

	override function GetCrotchetAtTime(time:Float):Float
	{
		return GroovinConductor.GetCrotchetAtTime(time);
	}

	override function GrabScrollSpeed():Float
	{
		return GroovinInput.GrabScrollSpeed(PlayState.SONG);
	}

	override function GrabReverse():Bool
	{
		return GroovinInput.GrabReverse();
	}

	override function GetCrotchetNow():Float
	{
		return GroovinConductor.GetCrotchetNow();
	}

	override function GetSongPosition():Float
	{
		return Conductor.songPosition;
	}

	override function GrabGlobalVisualOffset()
	{
		return GroovinInput.GrabGlobalVisualOffset();
	}

	override function GetCurrentBeat():Float
	{
		return GroovinConductor.GetTotalBeatsToTime(GetSongPosition());
	}

	override function GetHoldNoteSubdivisions():Int
	{
		return Schmovin.holdNoteSubdivisions;
	}
}
