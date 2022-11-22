/**
 * @ Author: 4mbr0s3 2
 * @ Create Time: 2021-08-22 19:49:42
 * @ Modified by: 4mbr0s3 2
 * @ Modified time: 2022-07-30 20:25:36
 */

package schmovin;

import flixel.FlxBasic;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.util.FlxColor;
import openfl.filters.ShaderFilter;
import schmovin.SchmovinRenderers.ISchmovinRenderer;
import schmovin.SchmovinRenderers.SchmovinHoldNoteRenderer;
import schmovin.SchmovinRenderers.SchmovinNotePathRenderer;
import schmovin.SchmovinRenderers.SchmovinTapNoteRenderer;
import schmovin.shaders.PlaneRaymarcher;
import schmovin.util.FlxCameraCopy;

using StringTools;

class SchmovinInstance
{
	public var camHUD:FlxCamera;
	public var camGame:FlxCamera;

	public var camBelowGame:FlxCamera;
	public var camGameCopy:FlxCamera;
	public var camAboveGame:FlxCamera;
	public var camPath:FlxCameraCopy;
	public var camNotes:FlxCameraCopy;

	public var planeRaymarcher:PlaneRaymarcher;
	public var planeRaymarcherFilter:ShaderFilter;

	public var timeline:SchmovinTimeline;
	public var playfields:SchmovinPlayfieldManager;

	private var _client:SchmovinClient;

	public var tapNoteRenderer:ISchmovinRenderer;
	public var holdNoteRenderer:ISchmovinRenderer;
	public var notePathRenderer:ISchmovinRenderer;

	public var state:PlayState;

	public var layerBelowGame:FlxTypedGroup<FlxBasic>;
	public var layerAboveGame:FlxTypedGroup<FlxBasic>;
	public var layerAboveHUD:FlxTypedGroup<FlxBasic>;

	private var _destroyed:Bool = false;

	public var fakeExplosionReceptors:FlxTypedGroup<FlxSprite>;

	public function setClient(client:SchmovinClient)
	{
		_client.destroy();
		_client = client;
	}

	private function new() {}

	public static function isPixelStage()
	{
		return PlayState.curStage.startsWith('school');
	}

	@:deprecated('Explosions are already automatically centered by receptor renderer')
	public function initializeFakeExplosionReceptors()
	{
		fakeExplosionReceptors = new FlxTypedGroup<FlxSprite>();
		SchmovinAdapter.getInstance().Log('Initialized fake explosion receptors');
		fakeExplosionReceptors.cameras = [camNotes];
		if (isPixelStage())
			createPixelExplosionReceptors();
		else
			createNormalExplosionReceptors();
		state.add(fakeExplosionReceptors);
	}

	function createPixelExplosionReceptors()
	{
		for (i in 0...state.strumLineNotes.length)
		{
			var receptor:FlxSprite = new FlxSprite(0, state.strumLine.y);
			var realReceptor = state.strumLineNotes.members[i];

			receptor.frames = realReceptor.frames;
			receptor.animation.copyFrom(realReceptor.animation);

			receptor.setGraphicSize(Std.int(receptor.width * PlayState.daPixelZoom));
			receptor.updateHitbox();
			receptor.antialiasing = false;

			receptor.animation.play('confirm');
			fakeExplosionReceptors.add(receptor);
		}
	}

	function createNormalExplosionReceptors()
	{
		for (i in 0...state.strumLineNotes.length)
		{
			var receptor:FlxSprite = new FlxSprite(0, state.strumLine.y);
			var realReceptor = state.strumLineNotes.members[i];

			receptor.frames = realReceptor.frames;
			receptor.animation.copyFrom(realReceptor.animation);

			receptor.antialiasing = true;
			receptor.setGraphicSize(Std.int(receptor.width * 0.7));

			receptor.animation.play('confirm');
			fakeExplosionReceptors.add(receptor);
		}
	}

	private function initializePlayfields()
	{
		playfields.addPlayfield(new SchmovinPlayfield('dad', 0, timeline.getModList()));
		playfields.addPlayfield(new SchmovinPlayfield('bf', 1, timeline.getModList()));
	}

	@:deprecated
	public function updateFakeExplosionReceptors()
	{
		if (fakeExplosionReceptors == null)
			return;
		for (index in 0...state.strumLineNotes.length)
		{
			var explosion = fakeExplosionReceptors.members[index];
			var target = state.strumLineNotes.members[index];
			// target.alpha = target.animation.name != 'confirm' ? 1 : 0;
			// explosion.visible = target.alpha != 1;
			explosion.visible = false;

			// Obsolete due to tap note and receptor rendering
			// Keeping this code just in case the rendering's too laggy...

			if (!explosion.visible)
				continue;

			explosion.animation.frameIndex = target.animation.frameIndex;
			explosion.shader = target.shader;

			var targetPos = target.getPosition();

			explosion.centerOffsets();
			explosion.centerOrigin();

			var offsetX = -(explosion.width - target.width) / 2;
			var offsetY = -(explosion.height - target.height) / 2;

			explosion.setPosition(targetPos.x + offsetX, targetPos.y + offsetY);
			explosion.angle = target.angle;
			explosion.scale.copyFrom(target.scale);
		}
	}

	private function initializeCamBelowGame()
	{
		camBelowGame = new FlxCamera();
		camBelowGame.bgColor = FlxColor.TRANSPARENT;
		FlxG.cameras.add(camBelowGame);

		layerBelowGame = new FlxTypedGroup<FlxBasic>();
		layerBelowGame.cameras = [camBelowGame];
		state.add(layerBelowGame);
	}

	public function initializeAboveHUD()
	{
		layerAboveHUD = new FlxTypedGroup<FlxBasic>();
		layerAboveHUD.cameras = [camHUD];
		state.add(layerAboveHUD);
	}

	public function initialize()
	{
		initializeCameras();
		initializeSchmovin();
	}

	private function initializeCameras()
	{
		initializeCamBelowGame();

		camGameCopy = new FlxCameraCopy(camGame);
		camGameCopy.bgColor = FlxColor.TRANSPARENT;
		FlxG.cameras.add(camGameCopy);

		camAboveGame = new FlxCamera();
		camAboveGame.bgColor = FlxColor.TRANSPARENT;
		FlxG.cameras.add(camAboveGame);

		layerAboveGame = new FlxTypedGroup<FlxBasic>();
		layerAboveGame.cameras = [camAboveGame];
		state.add(layerAboveGame);

		planeRaymarcher = new PlaneRaymarcher();
		planeRaymarcherFilter = new ShaderFilter(planeRaymarcher.shader);

		camPath = new FlxCameraCopy(state.camHUD);
		camPath.bgColor = FlxColor.TRANSPARENT;
		FlxG.cameras.add(camPath);

		camNotes = new FlxCameraCopy(state.camHUD);
		camNotes.bgColor = FlxColor.TRANSPARENT;
		FlxG.cameras.add(camNotes);
	}

	private function initializeSchmovin()
	{
		playfields = new SchmovinPlayfieldManager();
		timeline = SchmovinTimeline.create(state, this, playfields);
		initializePlayfields();
		switchClient();
		initializeRenderers();
	}

	public function isClientNull()
	{
		return Std.is(_client, SchmovinClientNull);
	}

	private function switchClient()
	{
		_client = new SchmovinClientNull(this, timeline, state);
		SchmovinAdapter.getInstance().forEveryMod([this, timeline, state]);
	}

	private function initializeRenderers()
	{
		holdNoteRenderer = new SchmovinHoldNoteRenderer(state, [camNotes], timeline, this);
		tapNoteRenderer = new SchmovinTapNoteRenderer(state, [camNotes], timeline, this);
		notePathRenderer = new SchmovinNotePathRenderer(state, [camPath], timeline, this);
	}

	public function preDraw()
	{
		if (camPath == null)
			return;
		notePathRenderer.preDraw();
	}

	public function postDraw()
	{
		if (_destroyed)
			return;
		holdNoteRenderer.preDraw();
		tapNoteRenderer.preDraw();
	}

	public static function Create(state:PlayState, camHUD:FlxCamera, camGame:FlxCamera)
	{
		var instance = new SchmovinInstance();
		instance.state = state;
		instance.camHUD = camHUD;
		instance.camGame = camGame;
		return instance;
	}

	public function destroy()
	{
		_destroyed = true;
		_client.destroy();
		tapNoteRenderer.destroy();
		holdNoteRenderer.destroy();
		notePathRenderer.destroy();
	}

	public function update(elapsed:Float)
	{
		_client.update(elapsed);
		timeline.update(SchmovinAdapter.getInstance().getCurrentBeat());
	}
}
