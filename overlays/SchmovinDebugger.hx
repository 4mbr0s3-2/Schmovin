/**
 * @ Author: 4mbr0s3 2
 * @ Create Time: 2021-08-13 22:26:14
 * @ Modified by: 4mbr0s3 2
 * @ Modified time: 2022-03-15 20:17:17
 */

package schmovin.overlays;

import flixel.FlxG;
import flixel.FlxState;
import flixel.group.FlxGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.ui.FlxBar;
import flixel.util.FlxColor;
import openfl.desktop.Clipboard;
import openfl.display.DisplayObject;
import openfl.display.Sprite;
import openfl.events.Event;
import schmovin.SchmovinTimeline;
import schmovin.note_mods.ISchmovinNoteMod;

class ModSlider extends FlxBar
{
	private static inline var WIDTH = 200;
	private static inline var HEIGHT = 30;
	private static inline var MARGIN = 20;

	private var _noteMod:ISchmovinNoteMod;
	private var _index:Int;

	private var _min:Float = -1.0;
	private var _max:Float = 1.0;
	private var _percent:Float = 0;

	private var _debugger:SchmovinDebugger;

	public var noteModName:String;
	public var player:Int;

	public var displayName:FlxText;

	public function new(debugger:SchmovinDebugger, index:Int, player:Int, noteModName:String, min:Float, max:Float)
	{
		this.noteModName = noteModName;
		this.player = player;
		_index = index;
		_min = min;
		_max = max;

		_debugger = debugger;
		super(MARGIN, FlxG.height - HEIGHT * (index + 1) - MARGIN, LEFT_TO_RIGHT, WIDTH, HEIGHT, this, '', 0, 100);
		scrollFactor.set();
		createFilledBar(0xFFFF0000, 0xFF66FF33, true, FlxColor.BLACK);
		initializeDisplayName();
	}

	private function initializeDisplayName()
	{
		var ps = cast(FlxG.state, PlayState);
		displayName = new FlxText(0, 0, 0, noteModName, 20);
		displayName.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);

		displayName.scrollFactor.set();
		displayName.cameras = [ps.camHUD];

		ps.add(displayName);
	}

	override function destroy()
	{
		super.destroy();
	}

	private function isHovering()
	{
		var posX = FlxG.mouse.cursorContainer.x;
		var posY = FlxG.mouse.cursorContainer.y;
		return posX > this.x - MARGIN && posX < this.x + this.frameWidth + MARGIN && posY > this.y && posY < this.y + this.frameHeight;
	}

	override function update(elapsed:Float)
	{
		FlxG.mouse.visible = true;
		displayName.x = this.x + this.frameWidth / 2 - displayName.frameWidth / 2;
		displayName.y = this.y + this.frameHeight / 2 - displayName.frameHeight / 2;
		super.update(elapsed);
		this.percent = _percent * 50 + 50;
		if (FlxG.mouse.pressed && isHovering())
		{
			var mousePercent = (FlxG.mouse.cursorContainer.x - this.x - this.frameWidth / 2) / this.frameWidth * 2;
			_percent = mousePercent;
			var outPercent = FlxMath.lerp(_min, _max, (mousePercent + 1.0) / 2.0);
			if (player < 0)
			{
				for (p in 0...2)
					_debugger.setPercentPlayfield(noteModName, outPercent, p);
				return;
			}
			_debugger.setPercentPlayfield(noteModName, outPercent, player);
		}
	}
}

class SchmovinDebugger extends Sprite
{
	private var _schmovinAdapter = SchmovinAdapter.getInstance();
	private var _client:SchmovinClient;
	private var _timeline:SchmovinTimeline;
	private var _eventsDisplay:Sprite;
	private var _zoomX:Float = 500;
	private var _zoomY:Float = 20;
	private var _displayEvents:Bool = false;
	private var _labels = new Map<String, DisplayObject>();
	private var _sliders = new FlxTypedGroup<ModSlider>();
	private var _modsDebugText:FlxText;

	public function new(client:SchmovinClient, timeline:SchmovinTimeline, displayEvents:Bool = false)
	{
		super();
		_client = client;
		_timeline = timeline;
		_displayEvents = displayEvents;
		addEventListener(Event.ENTER_FRAME, onEnterFrame);
		initializeSprites();
		addToDebugger();
		initializeSliders();
	}

	public function itgParseApplyModifiers(stringOptions:String, player:Int)
	{
		_timeline._mods.itgParseApplyModifiers(stringOptions, player);
	}

	public function addAllTheSliders(player:Int)
	{
		@:privateAccess
		for (mod in _timeline._mods._auxModsOrder)
		{
			addSlider(mod, player);
		}
	}

	private function initializeSprites()
	{
		_eventsDisplay = new Sprite();
		addChild(_eventsDisplay);
	}

	public function destroy()
	{
		removeChild(_eventsDisplay);
	}

	private function addToDebugger()
	{
		FlxG.console.registerObject('SchmovinDebugger', this);
	}

	public function parseHScript(script:String)
	{
		_schmovinAdapter.log('Script: ${script}');
		return _client.parseHScript(script);
	}

	public function addDebugText()
	{
		_modsDebugText = new FlxText(10, 10, 0);
		_modsDebugText.scrollFactor.set();
		_modsDebugText.setFormat(Paths.font('vcr.ttf'), 20, FlxColor.WHITE, LEFT);
		_modsDebugText.setBorderStyle(FlxTextBorderStyle.OUTLINE, 0xFF000000, 1, 1);
		var ps = cast(FlxG.state, PlayState);
		_modsDebugText.cameras = [ps.camHUD];
		ps.add(_modsDebugText);
	}

	public function addSlider(modName:String, player:Int = -1, min:Float = -1.0, max:Float = 1.0)
	{
		_schmovinAdapter.log('Added slider ${modName} for player ${player}');
		_sliders.add(new ModSlider(this, _sliders.length, player, modName, min, max));
	}

	public function addSliders(modNames:Array<String>, player:Int = -1, min:Float = -1.0, max:Float = 1.0)
	{
		for (name in modNames)
			addSlider(name, player, min, max);
	}

	public function getActiveMods(player:Int = 0)
	{
		// Ignore this lol
		@:privateAccess
		for (mod in _timeline._mods._playfields.getPlayfieldAtIndex(player).activeMods)
			FlxG.log.add(mod);
	}

	public function getRegisteredMods()
	{
		@:privateAccess
		for (mod in _timeline._mods._modsOrder)
			FlxG.log.add(mod);
	}

	public function getRegisteredMiscMods()
	{
		@:privateAccess
		for (mod in _timeline._mods._miscModsOrder)
			FlxG.log.add(mod);
	}

	public function getRegisteredAuxMods()
	{
		@:privateAccess
		for (mod in _timeline._mods._auxModsOrder)
			FlxG.log.add(mod);
	}

	public function removeSlider(modName:String, player:Int)
	{
		for (slider in _sliders)
		{
			if (slider.noteModName == modName && slider.player == player)
			{
				_sliders.remove(slider);
				break;
			}
		}
	}

	private function initializeSliders()
	{
		var ps = cast(FlxG.state, PlayState);
		_sliders.cameras = [ps.camHUD];
		FlxG.state.add(_sliders);
	}

	public function setPercentPlayfield(modName:String, percent:Float, index:Int)
	{
		_timeline._mods.setPercentPlayfieldIndex(modName, percent, index);
	}

	public function setPercent(modName:String, percent:Float, player:Int)
	{
		_timeline._mods.setPercent(modName, percent, player);
	}

	public function getPercent(modName:String, player:Int)
	{
		return _timeline._mods.getPercent(modName, player);
	}

	private function noPercent(mod:String)
	{
		return _timeline.getModList().getPercent(mod, 0) == 0.0 && _timeline.getModList().getPercent(mod, 1) == 0.0;
	}

	private function addEventsDisplay()
	{
		var iterator = _timeline._events.keyValueIterator();
		var row = 0;
		_eventsDisplay.removeChildren();
		while (iterator.hasNext())
		{
			var current = iterator.next();
			if (noPercent(current.key))
				continue;
			var mod = _timeline.getNoteMod(current.key);
			if (mod == null)
				continue;
			if (current.value.length > 0 && _displayEvents)
			{
				for (value in current.value)
				{
					var event = new EventBox(row, value);
					_eventsDisplay.addChild(event);
				}
			}
			if (!_labels.exists(current.key))
				_labels.set(current.key, new ModLabel(current.key, mod));
			var child = _labels.get(current.key);

			cast(child, ModLabel).row = row;
			_eventsDisplay.addChild(child);
			row++;
		}
	}

	private function onEnterFrame(_)
	{
		update();
	}

	private function updateModsDebugText()
	{
		var text = 'Mods Debug\n';
		var iterator = _timeline._events.keyValueIterator();
		var row = 0;
		while (iterator.hasNext())
		{
			var current = iterator.next();
			if (noPercent(current.key))
				continue;
			var mod = _timeline.getNoteMod(current.key);
			if (mod == null)
				continue;
			text += '${current.key}: [${mod.getLegacyPercent(0)}, ${mod.getLegacyPercent(1)}]\n';
		}
		if (_modsDebugText != null)
			_modsDebugText.text = text;
	}

	private function update()
	{
		updateModsDebugText();
	}
}
