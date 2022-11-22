/**
 * @ Author: 4mbr0s3 2
 * @ Create Time: 2021-06-22 12:05:21
 * @ Modified by: 4mbr0s3 2
 * @ Modified time: 2022-07-30 20:08:01
 */

package schmovin;

import flixel.FlxSprite;
import flixel.math.FlxMath;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween.FlxTweenManager;
import flixel.tweens.FlxTween.TweenCallback;
import haxe.Exception;
import hscript.Expr.ModuleDecl;
import hscript.Interp;
import hscript.Parser;
import schmovin.SchmovinTimeline;
import schmovin.note_mods.ISchmovinNoteMod;
import schmovin.note_mods.NoteModBase;

using schmovin.SchmovinUtil;

class SchmovinClient
{
	var _timeline:SchmovinTimeline;
	var _state:PlayState;
	var _instance:SchmovinInstance;
	var _tween:FlxTweenManager = new FlxTweenManager();

	public function toString()
	{
		return '';
	}

	public function addPlayfield(name:String, playerToCopy:Int)
	{
		var p = new SchmovinPlayfield(name, playerToCopy, _timeline.getModList());
		_instance.playfields.addPlayfield(p);
		return p;
	}

	public function removePlayfield(p:SchmovinPlayfield)
	{
		_instance.playfields.removePlayfield(p);
	}

	public function initialize() {}

	private function setInterpreterValues(interp:Interp)
	{
		interp.variables.set('FlxEase', FlxEase);
		interp.variables.set('Alt', alt);
		interp.variables.set('Math', Math);
		interp.variables.set('E', e);
		interp.variables.set('S', s);
		interp.variables.set('F', f);
		interp.variables.set('ease', ease);
		interp.variables.set('set', set);
		interp.variables.set('Func', func);
		interp.variables.set('SchmovinClient', this);
		interp.variables.set('PlayState', _state);
		interp.variables.set('Timeline', _timeline);
		interp.variables.set('TweenManager', _tween);
		interp.variables.set('FlxMath', FlxMath);
		interp.variables.set('FlxSprite', FlxSprite);
	}

	public function parseHScript(script:String)
	{
		_timeline.clearEvents();
		var parser = new Parser();
		var ast = parser.parseString(script);
		var interp = new Interp();
		setInterpreterValues(interp);

		var res = interp.execute(ast);
		return res;
	}

	public function destroy() {}

	private function getElapsedInBeats(elapsed:Float)
	{
		return elapsed * 1000 / SchmovinAdapter.getInstance().getCrotchetNow();
	}

	public function update(elapsed:Float)
	{
		_tween.update(getElapsedInBeats(elapsed));
	}

	public function new(instance:SchmovinInstance, timeline:SchmovinTimeline, state:PlayState)
	{
		setParams(instance, timeline, state);
		initialize();
	}

	/**
		For use in Polymod mods.

		Apparently, Polymod doesn't call the superclass constructor when calling ScriptedClass.init() inside hscripts.
		So, despite needing the parameters, the parameters never get passed.

		You can just call this from the abstract script class (_asc.setParams()) to initialize these parameters and call _asc.initialize() manually.
	**/
	public function setParams(instance:SchmovinInstance, timeline:SchmovinTimeline, state:PlayState)
	{
		_instance = instance;
		_timeline = timeline;
		_state = state;
	}

	private function ease(beat:Float, length:Float, easeFunc:Float->Float, target:Float, mod:String, player:Int = -1)
	{
		_timeline.ease(beat, length, easeFunc, target, mod, player);
	}

	private function e(barstep:Array<Float>, length:Float, easeFunc:Float->Float, target:Float, mod:String, player:Int = -1)
	{
		_timeline.ease(barStepToBeats(barstep[0], barstep[1]), length, easeFunc, target, mod, player);
	}

	private function set(beat:Float, target:Float, mod:String, player:Int = -1)
	{
		_timeline.set(beat, target, mod, player);
	}

	private function s(barstep:Array<Float>, target:Float, mod:String, player:Int = -1)
	{
		_timeline.set(barStepToBeats(barstep[0], barstep[1]), target, mod, player);
	}

	private function func(beat:Float, callback:Void->Void)
	{
		_timeline.func(beat, callback);
	}

	private function f(barstep:Array<Float>, callback:Void->Void)
	{
		func(barStepToBeats(barstep[0], barstep[1]), callback);
	}

	private function t(barstep:Array<Float>, object:Dynamic, length:Float, easeFunc:Float->Float, values:Dynamic, onComplete:TweenCallback = null,
			onUpdate:TweenCallback = null)
	{
		f(barstep, () ->
		{
			_tween.tween(object, values, length, {ease: easeFunc, onComplete: onComplete, onUpdate: onUpdate});
		});
	}

	private function alt(num:Int)
	{
		return ((num % 2) - 0.5) / 0.5;
	}

	private inline function barStepToBeats(bar:Float, step:Float)
	{
		return (bar - 1) * 4 + (step - 1) / 4.0;
	}

	private function addNoteMod(modName:String, mod:ISchmovinNoteMod, aux:Bool = false)
	{
		var modList = _timeline.getModList();
		modList.addNoteMod(modName, mod, aux);
	}

	private function addNoteAuxMod(modName:String)
	{
		addNoteMod(modName, new NoteModBase());
	}

	private function removeNoteModFromName(modName:String)
	{
		var modList = _timeline.getModList();
		modList.removeNoteModFromName(modName);
	}
}
