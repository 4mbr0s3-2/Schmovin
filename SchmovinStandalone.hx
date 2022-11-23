/**
 * @ Author: 4mbr0s3 2
 * @ Create Time: 2021-06-22 11:55:58
 * @ Modified by: 4mbr0s3 2
 */

package schmovin;

import Song.SwagSong;
import flixel.FlxBasic;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.util.FlxColor;

using SchmovinUtil.SchmovinUtil;

/**
 * Version of Schmovin without any dependencies on Groovin'.
 * This should be used by other engines.
 * Check out the comments for each public function to see where to put them in the engine code.
 */
class SchmovinStandalone
{
	public function new() {}

	private var instance:SchmovinInstance;

	public static var holdNoteSubdivisions:Int = 4;

	private function shouldRun():Bool
	{
		if (Std.is(FlxG.state.subState, PauseSubState))
			return true;
		return FlxG.state.subState == null;
	}

	/**
	 * Call this in PlayState right after the following line:
	 * 
	 * openSubState(new GameOverSubstate(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));
	 * @param state 
	 */
	public function onGameOver(state:PlayState)
	{
		instance.destroy();
	}

	/**
	 * Before calling this, make sure to set the SchmovinAdapter instance so Schmovin' properly works.
	 * Call this in PlayState between the following lines:
	 * 
	 * FlxG.cameras.reset(camGame);
	 * FlxG.cameras.add(camHUD);
	 * @param camGame 
	 * @param camHUD 
	 */
	public function afterCameras(camGame:FlxCamera, camHUD:FlxCamera)
	{
		instance = SchmovinInstance.Create(cast FlxG.state, camGame, camHUD);

		instance.initialize();
	}

	private function initializeCamBelowGame()
	{
		instance.camBelowGame = new FlxCamera();
		instance.camBelowGame.bgColor = FlxColor.TRANSPARENT;
		FlxG.cameras.add(instance.camBelowGame);
		instance.layerBelowGame = new FlxTypedGroup<FlxBasic>();
		instance.layerBelowGame.cameras = [instance.camBelowGame];
		instance.state.add(instance.layerBelowGame);
	}

	/**
	 * Call this when exiting the PlayState.
	 * @param nextState 
	 */
	public function onExitPlayState(nextState:FlxState)
	{
		instance.destroy();
	}

	private function initializeAboveHUD()
	{
		instance.layerAboveHUD = new FlxTypedGroup<FlxBasic>();
		instance.layerAboveHUD.cameras = [instance.camHUD];
		instance.state.add(instance.layerAboveHUD);
	}

	/**
	 * Call this after all UI elements have their cameras set to camHUD in PlayState.create().
	 * @param state 
	 */
	public function postUI(state:PlayState)
	{
		state.strumLineNotes.cameras = [instance.camNotes];
		state.notes.cameras = [instance.camNotes];

		FlxCamera.defaultCameras = [instance.camGameCopy];
		initializeAboveHUD();
	}

	/**
	 * Call this from the PlayState's draw method before calling the superclass method.
	 * @param state 
	 */
	public function preDraw(state:PlayState)
	{
		instance.preDraw();
	}

	/**
	 * Call this from the PlayState's draw method after calling the superclass method.
	 * @param state 
	 */
	public function postDraw(state:PlayState)
	{
		instance.postDraw();
	}

	/**
	 * Call this before startTimer in PlayState.startCountdown().
	 * @param state 
	 */
	public function onCountdown(state:PlayState)
	{
		// instance.initializeFakeExplosionReceptors();
	}

	/**
	 * Call this at the start of PlayState.update().
	 * @param state 
	 * @param elapsed 
	 */
	public function update(state:PlayState, elapsed:Float)
	{
		instance.update(elapsed);
		updateReceptors();
	}

	private function updateReceptors()
	{
		var currentBeat = getCurrentBeat();
		for (receptorIndex in 0...instance.state.strumLineNotes.length)
		{
			var receptor = instance.state.strumLineNotes.members[receptorIndex];
			instance.timeline.updateNotes(currentBeat, receptor, SchmovinUtil.getPlayerOfTotalColumn(receptorIndex), receptorIndex);
		}
		instance.updateFakeExplosionReceptors();
	}

	// Taken from GroovinConductor
	public static function hasBPMChanges()
	{
		return Conductor.bpmChangeMap.length > 0;
	}

	// Taken from GroovinConductor
	public static function getSortedBPMChanges()
	{
		var sortedChanges = Conductor.bpmChangeMap.copy();
		sortedChanges.sort((e1, e2) ->
		{
			return e1.songTime < e2.songTime ? -1 : 1;
		});
		sortedChanges.insert(0, {songTime: 0, stepTime: 0, bpm: PlayState.SONG.bpm});
		return sortedChanges;
	}

	// Taken from GroovinConductor
	public static function getCurrentBeat()
	{
		return SchmovinAdapter.getInstance().getCurrentBeat();
	}

	// Taken from GroovinConductor
	public static function getCrotchetFromBPM(bpm:Float)
	{
		return 60000.0 / bpm;
	}

	/**
	 * Call this after the following line of code:
	 * daNote.y = (strumLine.y - (Conductor.songPosition - daNote.strumTime) * (0.45 * FlxMath.roundDecimal(SONG.speed, 2)));
	 * 
	 * Make sure to comment out or remove the clipping rectangle code if it's still there.
	 * @param state 
	 * @param strumLine 
	 * @param daNote 
	 * @param SONG 
	 * @return Bool
	 */
	public function postNotePosition(state:PlayState, strumLine:FlxSprite, daNote:Note, SONG:SwagSong):Bool
	{
		if (daNote.alive && daNote.visible)
			instance.timeline.updateNotes(getCurrentBeat(), daNote, daNote.getPlayer());
		return true;
	}
}
