/**
 * @ Author: 4mbr0s3 2
 * @ Create Time: 2021-06-22 11:55:58
 * @ Modified by: 4mbr0s3 2
 * @ Modified time: 2021-11-13 13:32:39
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
	private var instance:SchmovinInstance;

	public static var holdNoteSubdivisions:Int = 4;

	function ShouldRun():Bool
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
	public function OnGameOver(state:PlayState)
	{
		instance.Destroy();
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
	public function AfterCameras(camGame:FlxCamera, camHUD:FlxCamera)
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

	/**
	 * Call this when exiting the PlayState.
	 * @param nextState 
	 */
	public function OnExitPlayState(nextState:FlxState)
	{
		instance.Destroy();
	}

	function InitializeAboveHUD()
	{
		instance.layerAboveHUD = new FlxTypedGroup<FlxBasic>();
		instance.layerAboveHUD.cameras = [instance.camHUD];
		instance.state.add(instance.layerAboveHUD);
	}

	/**
	 * Call this after all UI elements have their cameras set to camHUD in PlayState.create().
	 * @param state 
	 */
	public function PostUI(state:PlayState)
	{
		state.strumLineNotes.cameras = [instance.camNotes];
		state.notes.cameras = [instance.camNotes];

		FlxCamera.defaultCameras = [instance.camGameCopy];
		InitializeAboveHUD();
	}

	/**
	 * Call this from the PlayState's draw method before calling the superclass method.
	 * @param state 
	 */
	public function PreDraw(state:PlayState)
	{
		if (instance.camPath == null)
			return;
		instance.notePathRenderer.PreDraw();
	}

	/**
	 * Call this from the PlayState's draw method after calling the superclass method.
	 * @param state 
	 */
	public function PostDraw(state:PlayState)
	{
		if (instance.camPath == null)
			return;
		instance.holdNoteRenderer.PreDraw();
	}

	/**
	 * Call this before startTimer in PlayState.startCountdown().
	 * @param state 
	 */
	public function OnCountdown(state:PlayState)
	{
		instance.InitializeFakeExplosionReceptors();
	}

	/**
	 * Call this at the start of PlayState.Update().
	 * @param state 
	 * @param elapsed 
	 */
	public function Update(state:PlayState, elapsed:Float)
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

	// Taken from GroovinConductor
	public static function HasBPMChanges()
	{
		return Conductor.bpmChangeMap.length > 0;
	}

	// Taken from GroovinConductor
	public static function GetSortedBPMChanges()
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
	public static function GetCurrentBeat()
	{
		var targetTime = SchmovinAdapter.GetInstance().GetSongPosition();
		if (!HasBPMChanges())
			return SchmovinAdapter.GetInstance().GetSongPosition() / Conductor.crochet;

		var beats = 0.0;
		var bpmChanges = GetSortedBPMChanges();

		for (i in 0...bpmChanges.length - 1)
		{
			var curChange = bpmChanges[i];
			var nextChange;
			if (i >= bpmChanges.length - 1)
				nextChange = {songTime: Math.POSITIVE_INFINITY, stepTime: 0, bpm: 0.0};
			else
				nextChange = bpmChanges[i + 1];
			if (curChange.songTime < targetTime)
			{
				var endTimeWithinChange = FlxMath.bound(targetTime, curChange.songTime, nextChange.songTime);
				var beatsInChange = (endTimeWithinChange - curChange.songTime) / GetCrotchetFromBPM(curChange.bpm);
				beats += beatsInChange;
			}
		}

		return beats;
	}

	// Taken from GroovinConductor
	public static function GetCrotchetFromBPM(bpm:Float)
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
	public function PostNotePosition(state:PlayState, strumLine:FlxSprite, daNote:Note, SONG:SwagSong):Bool
	{
		if (daNote.alive && daNote.visible)
			instance.timeline.UpdateNotes(GetCurrentBeat(), daNote, daNote.GetPlayer());
		return true;
	}
}
