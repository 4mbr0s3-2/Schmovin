/**
 * @ Author: 4mbr0s3 2
 * @ Create Time: 2021-06-22 11:55:58
 * @ Modified by: 4mbr0s3 2
 * @ Modified time: 2022-04-03 01:04:16
 */

package schmovin;

import Song.SwagSong;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.util.FlxColor;
import groovin.mod.Mod;
import groovin.mod.ModHooks;
import groovin.mod_options.GroovinModOptionsClasses.GroovinModOption;
import groovin.mod_options.GroovinModOptionsClasses.GroovinModOptionCheckbox;
import groovin.mod_options.GroovinModOptionsClasses.GroovinModOptionSectionTitle;
import groovin.mod_options.GroovinModOptionsClasses.GroovinModOptionSlider;

using SchmovinUtil.SchmovinUtil;

class Schmovin extends Mod
{
	private var instance:SchmovinInstance;

	public static var holdNoteSubdivisions:Int = 4;
	public static var arrowPathSubdivisions:Int = 80;
	public static var optimizeHoldNotes:Bool = false;

	override function getCredits():String
	{
		return '4mbr0s3 2';
	}

	override function initialize()
	{
		hook(ModHooks.hookAfterCameras);
		hook(ModHooks.hookUpdate);
		hook(ModHooks.hookPostNotePosition);
		hook(ModHooks.hookPreDraw);
		hook(ModHooks.hookPostDraw);
		hook(ModHooks.hookPostUI);
		hook(ModHooks.hookOnCountdown);
		hook(ModHooks.hookSetupCharacters);
		hook(ModHooks.hookOnExitPlayState);
	}

	override function shouldRun():Bool
	{
		if (Std.is(FlxG.state.subState, PauseSubState))
			return true;
		return FlxG.state.subState == null;
	}

	override function onGameOver(state:PlayState)
	{
		instance.destroy();
	}

	private function initializeGroovinSchmovinAdapter()
	{
		SchmovinAdapter.setInstance(new GroovinSchmovinAdapter());
	}

	override function afterCameras(camGame:FlxCamera, camHUD:FlxCamera)
	{
		initializeGroovinSchmovinAdapter();

		instance = SchmovinInstance.create(cast FlxG.state, camHUD, camGame);
		instance.initialize();
	}

	override function onExitPlayState(nextState:FlxState)
	{
		Log('Destroying Schmovin instance...');
		instance.destroy();
	}

	override function postUI(state:PlayState)
	{
		state.strumLineNotes.cameras = [instance.camNotes];
		state.notes.cameras = [instance.camNotes];
		FlxCamera.defaultCameras = [instance.camGameCopy];

		instance.initializeAboveHUD();
	}

	override function preDraw(state:PlayState)
	{
		instance.preDraw();
	}

	override function postDraw(state:PlayState)
	{
		instance.postDraw();
	}

	override function onCountdown(state:PlayState)
	{
		// No longer needed
		// instance.initializeFakeExplosionReceptors();
	}

	override function update(elapsed:Float)
	{
		instance.update(elapsed);
		hideReceptors();
	}

	private function hideReceptors()
	{
		for (receptorIndex in 0...instance.state.strumLineNotes.length)
		{
			// Note positioning moved to SchmovinRenderers for multiple playfield support
			// This is for updating receptor positions...
			var receptor = instance.state.strumLineNotes.members[receptorIndex];
			receptor.visible = false;
		}
	}

	override function isVisibleOnModList():Bool
	{
		return false;
	}

	override function registerModOptions():Array<GroovinModOption<Dynamic>>
	{
		return [
			new GroovinModOptionSectionTitle(this, 'Visual'),
			new GroovinModOptionSlider(this, 'maxSustainSubdivisions', 'Maximum Sustain Subdivisions', 4, 1, 4, (v) ->
			{
				holdNoteSubdivisions = cast v;
			}, 1, 4, '', true),
			new GroovinModOptionSlider(this, 'maxArrowPathSubdivisions', 'Maximum Arrow Path Subdivisions', 80, 10, 100, (v) ->
			{
				arrowPathSubdivisions = cast v;
			}, 1, 80, '', true),
			new GroovinModOptionCheckbox(this, 'optimizeSustainNotes', 'Optimize Sustain Notes', false, (v) ->
			{
				optimizeHoldNotes = cast v;
			}, false,
				'Reduces the number of times paths are calculated for sustain (hold) notes by 1. Boosts framerate by about 10 FPS.')
		];
	}

	override function postNotePosition(state:PlayState, strumLine:FlxSprite, daNote:Note, SONG:SwagSong):Bool
	{
		// Note positioning moved to SchmovinRenderers for multiple playfield support

		if (daNote.alive)
		{
			daNote.visible = false;
			daNote.cameras = [];
		}

		return true;
	}
}
