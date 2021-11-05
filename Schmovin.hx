/**
 * @ Author: 4mbr0s3 2
 * @ Create Time: 2021-06-22 11:55:58
 * @ Modified by: 4mbr0s3 2
 * @ Modified time: 2021-11-04 23:15:33
 */

package schmovin;

import Song.SwagSong;
import flixel.FlxBasic;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.util.FlxColor;
import groovin.mod.Mod;
import groovin.mod.ModHooks;
import groovin.mod_options.GroovinModOptionsClasses.GroovinModOption;
import groovin.mod_options.GroovinModOptionsClasses.GroovinModOptionSectionTitle;
import groovin.mod_options.GroovinModOptionsClasses.GroovinModOptionSlider;
import groovin.util.GroovinConductor;

using SchmovinUtil.SchmovinUtil;

class Schmovin extends Mod
{
	private var instance:SchmovinInstance;

	public static var holdNoteSubdivisions:Int = 4;

	override function GetCredits():String
	{
		return '4mbr0s3 2';
	}

	override function Initialize()
	{
		Hook(ModHooks.HookAfterCameras);
		Hook(ModHooks.HookPostUpdate);
		Hook(ModHooks.HookPostNotePosition);
		Hook(ModHooks.HookPreDraw);
		Hook(ModHooks.HookPostDraw);
		Hook(ModHooks.HookPostUI);
		Hook(ModHooks.HookOnCountdown);
		Hook(ModHooks.HookSetupCharacters);
		Hook(ModHooks.HookOnExitPlayState);
	}

	override function ShouldRun():Bool
	{
		if (Std.is(FlxG.state.subState, PauseSubState))
			return true;
		return FlxG.state.subState == null;
	}

	override function OnGameOver(state:PlayState)
	{
		instance.Destroy();
	}

	override function AfterCameras(camGame:FlxCamera, camHUD:FlxCamera)
	{
		instance = SchmovinInstance.Create();
		instance.state = cast FlxG.state;

		instance.camHUD = camHUD;
		instance.camGame = camGame;
		InitializeCamBelowGame();

		instance.InitializeCameras();
		instance.InitializeSchmovin();
	}

	function InitializeCamBelowGame()
	{
		instance.camBelowGame = new FlxCamera();
		instance.camBelowGame.bgColor = FlxColor.TRANSPARENT;
		FlxG.cameras.add(instance.camBelowGame);
		instance.layerBelowGame = new FlxTypedGroup<FlxBasic>();
		instance.layerBelowGame.cameras = [instance.camBelowGame];
		instance.state.add(instance.layerBelowGame);
	}

	override function OnExitPlayState(nextState:FlxState)
	{
		Log('PlayState exited...');
		instance.Destroy();
	}

	function InitializeAboveHUD()
	{
		instance.layerAboveHUD = new FlxTypedGroup<FlxBasic>();
		instance.layerAboveHUD.cameras = [instance.camHUD];
		instance.state.add(instance.layerAboveHUD);
	}

	override function PostUI(state:PlayState)
	{
		state.strumLineNotes.cameras = [instance.camNotes];
		state.notes.cameras = [instance.camNotes];

		FlxCamera.defaultCameras = [instance.camGameCopy];
		InitializeAboveHUD();
	}

	override function PreDraw(state:PlayState)
	{
		if (instance.camPath == null)
			return;
		instance.notePathRenderer.PreDraw();
	}

	override function PostDraw(state:PlayState)
	{
		if (instance.camPath == null)
			return;
		instance.holdNoteRenderer.PreDraw();
	}

	override function OnCountdown(state:PlayState)
	{
		instance.InitializeFakeExplosionReceptors();
	}

	override function PostUpdate(state:PlayState, elapsed:Float)
	{
		instance.Update(elapsed);
		UpdateReceptors();
	}

	function UpdateReceptors()
	{
		var currentBeat = GetCurrentBeat();
		for (receptorIndex in 0...instance.state.strumLineNotes.length)
		{
			var receptor = instance.state.strumLineNotes.members[receptorIndex];
			instance.timeline.UpdateNotes(currentBeat, receptor, SchmovinUtil.GetPlayerOfTotalColumn(receptorIndex), receptorIndex);
		}
		instance.UpdateFakeExplosionReceptors();
	}

	override function IsVisibleOnModList():Bool
	{
		return false;
	}

	public static function GetCurrentBeat()
	{
		return GroovinConductor.GetTotalBeatsToTime(Conductor.songPosition);
	}

	override function RegisterModOptions():Array<GroovinModOption<Dynamic>>
	{
		return [
			new GroovinModOptionSectionTitle(this, 'Visual'),
			new GroovinModOptionSlider(this, 'maxSustainSubdivisions', 'Maximum Sustain Subdivisions', 4, 1, 4, (v) ->
			{
				holdNoteSubdivisions = cast v;
			}, 1, 4, '', true),
		];
	}

	override function PostNotePosition(state:PlayState, strumLine:FlxSprite, daNote:Note, SONG:SwagSong):Bool
	{
		if (daNote.alive && daNote.visible)
			instance.timeline.UpdateNotes(GetCurrentBeat(), daNote, daNote.GetPlayer());
		return true;
	}
}
