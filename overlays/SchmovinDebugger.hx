/**
 * @ Author: 4mbr0s3 2
 * @ Create Time: 2021-08-13 22:26:14
 * @ Modified by: 4mbr0s3 2
 * @ Modified time: 2022-01-24 22:30:27
 */

package schmovin.overlays;

import flixel.FlxG;
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

/**
 * inb4 someone compares this to Thread of Fate Manipulator (midi would be cool tho)
 */
class ModSlider extends FlxBar
{
	static inline var WIDTH = 200;
	static inline var HEIGHT = 30;
	static inline var MARGIN = 20;

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
		InitializeDisplayName();
	}

	function InitializeDisplayName()
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

	override function update(elapsed:Float)
	{
		FlxG.mouse.visible = true;
		displayName.x = this.x + this.frameWidth / 2 - displayName.frameWidth / 2;
		displayName.y = this.y + this.frameHeight / 2 - displayName.frameHeight / 2;
		function isHovering()
		{
			var posX = FlxG.mouse.cursorContainer.x;
			var posY = FlxG.mouse.cursorContainer.y;
			return posX > this.x - MARGIN && posX < this.x + this.frameWidth + MARGIN && posY > this.y && posY < this.y + this.frameHeight;
		}
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
					_debugger.SetPercentPlayfield(noteModName, outPercent, p);
				return;
			}
			_debugger.SetPercentPlayfield(noteModName, outPercent, player);
		}
	}
}

class SchmovinDebugger extends Sprite
{
	private var _client:SchmovinClient;
	private var _timeline:SchmovinTimeline;
	private var _eventsDisplay:Sprite;
	private var _zoomX:Float = 500;
	private var _zoomY:Float = 20;
	private var _displayEvents:Bool = false;
	private var _labels = new Map<String, DisplayObject>();
	private var _sliders = new FlxTypedGroup<ModSlider>();

	public function new(client:SchmovinClient, timeline:SchmovinTimeline, displayEvents:Bool = false)
	{
		super();
		_client = client;
		_timeline = timeline;
		_displayEvents = displayEvents;
		addEventListener(Event.ENTER_FRAME, OnEnterFrame);
		InitializeSprites();
		AddToDebugger();
		InitializeSliders();
	}

	public function ITGApplyModifiers(stringOptions:String, player:Int)
	{
		_timeline._mods.ITGApplyModifiers(stringOptions, player);
	}

	public function AddAllTheSliders(player:Int)
	{
		for (mod in _timeline._mods._mods)
		{
			AddSlider(mod.GetName(), player);
		}
	}

	function InitializeSprites()
	{
		_eventsDisplay = new Sprite();
		addChild(_eventsDisplay);
	}

	public function Destroy()
	{
		removeChild(_eventsDisplay);
	}

	function AddToDebugger()
	{
		FlxG.console.registerObject('SchmovinDebugger', this);
	}

	public function ParseHScript(script:String)
	{
		SchmovinAdapter.GetInstance().Log('Script: ${script}');
		return _client.ParseHScript(script);
	}

	public function AddSlider(modName:String, player:Int = -1, min:Float = -1.0, max:Float = 1.0)
	{
		SchmovinAdapter.GetInstance().Log('Added slider ${modName} for player ${player}');
		_sliders.add(new ModSlider(this, _sliders.length, player, modName, min, max));
	}

	public function AddSliders(modNames:Array<String>, player:Int = -1, min:Float = -1.0, max:Float = 1.0)
	{
		for (name in modNames)
			AddSlider(name, player, min, max);
	}

	public function GetExecutingMods()
	{
		@:privateAccess
		for (mod in _timeline._mods._modExecuteList)
			FlxG.log.add(mod.GetName());
	}

	public function RemoveSlider(modName:String, player:Int)
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

	function InitializeSliders()
	{
		var ps = cast(FlxG.state, PlayState);
		_sliders.cameras = [ps.camHUD];
		FlxG.state.add(_sliders);
	}

	public function SetPercentPlayfield(modName:String, percent:Float, index:Int)
	{
		_timeline._mods.SetPercentPlayfieldIndex(modName, percent, index);
	}

	public function SetPercent(modName:String, percent:Float, player:Int)
	{
		_timeline._mods.SetPercent(modName, percent, player);
	}

	public function GetPercent(modName:String, player:Int)
	{
		return _timeline._mods.GetPercent(modName, player);
	}

	function AddEventsDisplay()
	{
		function NoPercent(mod:ISchmovinNoteMod)
		{
			return mod.GetLegacyPercent(0) == 0 && mod.GetLegacyPercent(1) == 0;
		}
		var iterator = _timeline._events.keyValueIterator();
		var row = 0;
		_eventsDisplay.removeChildren();
		while (iterator.hasNext())
		{
			var current = iterator.next();
			var mod = _timeline.GetNoteMod(current.key);
			if (mod == null)
				continue;
			if (NoPercent(mod))
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

	function OnEnterFrame(_)
	{
		Update();
	}

	function Update()
	{
		AddEventsDisplay();
		for (childIndex in 0..._eventsDisplay.numChildren)
		{
			var child = _eventsDisplay.getChildAt(childIndex);
			cast(child, IUpdateable).Update([_zoomX, _zoomY]);
		}
	}
}
