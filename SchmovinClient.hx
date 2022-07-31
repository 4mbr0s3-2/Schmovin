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

	function AddPlayfield(name:String, playerToCopy:Int)
	{
		var p = new SchmovinPlayfield(name, playerToCopy, _timeline.GetModList());
		_instance.playfields.AddPlayfield(p);
		return p;
	}

	function RemovePlayfield(p:SchmovinPlayfield)
	{
		_instance.playfields.RemovePlayfield(p);
	}

	public function Initialize() {}

	private function SetInterpreterValues(interp:Interp)
	{
		interp.variables.set('FlxEase', FlxEase);
		interp.variables.set('Alt', Alt);
		interp.variables.set('Math', Math);
		interp.variables.set('E', E);
		interp.variables.set('S', S);
		interp.variables.set('F', F);
		interp.variables.set('Ease', Ease);
		interp.variables.set('Set', Set);
		interp.variables.set('Func', Func);
		interp.variables.set('SchmovinClient', this);
		interp.variables.set('PlayState', _state);
		interp.variables.set('Timeline', _timeline);
		interp.variables.set('TweenManager', _tween);
		interp.variables.set('FlxMath', FlxMath);
		interp.variables.set('FlxSprite', FlxSprite);
	}

	public function ParseHScript(script:String)
	{
		_timeline.ClearEvents();
		var parser = new Parser();
		var ast = parser.parseString(script);
		var interp = new Interp();
		SetInterpreterValues(interp);

		var res = interp.execute(ast);
		return res;
	}

	public function Destroy() {}

	function GetElapsedInBeats(elapsed:Float)
	{
		return elapsed * 1000 / SchmovinAdapter.GetInstance().GetCrotchetNow();
	}

	public function Update(elapsed:Float)
	{
		_tween.update(GetElapsedInBeats(elapsed));
	}

	public function new(instance:SchmovinInstance, timeline:SchmovinTimeline, state:PlayState)
	{
		SetParams(instance, timeline, state);
		Initialize();
	}

	/**
		For use in Polymod mods.

		Apparently, Polymod doesn't call the superclass constructor when calling ScriptedClass.init() inside hscripts.
		So, despite needing the parameters, the parameters never get passed.

		You can just call this from the abstract script class (_asc.SetParams()) to initialize these parameters and call _asc.Initialize() manually.
	**/
	public function SetParams(instance:SchmovinInstance, timeline:SchmovinTimeline, state:PlayState)
	{
		_instance = instance;
		_timeline = timeline;
		_state = state;
	}

	function Ease(beat:Float, length:Float, easeFunc:Float->Float, target:Float, mod:String, player:Int = -1)
	{
		_timeline.Ease(beat, length, easeFunc, target, mod, player);
	}

	function E(barstep:Array<Float>, length:Float, easeFunc:Float->Float, target:Float, mod:String, player:Int = -1)
	{
		_timeline.Ease(BarStepToBeats(barstep[0], barstep[1]), length, easeFunc, target, mod, player);
	}

	function Set(beat:Float, target:Float, mod:String, player:Int = -1)
	{
		_timeline.Set(beat, target, mod, player);
	}

	function S(barstep:Array<Float>, target:Float, mod:String, player:Int = -1)
	{
		_timeline.Set(BarStepToBeats(barstep[0], barstep[1]), target, mod, player);
	}

	function Func(beat:Float, callback:Void->Void)
	{
		_timeline.Func(beat, callback);
	}

	function F(barstep:Array<Float>, callback:Void->Void)
	{
		Func(BarStepToBeats(barstep[0], barstep[1]), callback);
	}

	function T(barstep:Array<Float>, object:Dynamic, length:Float, easeFunc:Float->Float, values:Dynamic, onComplete:TweenCallback = null,
			onUpdate:TweenCallback = null)
	{
		F(barstep, () ->
		{
			_tween.tween(object, values, length, {ease: easeFunc, onComplete: onComplete, onUpdate: onUpdate});
		});
	}

	function Alt(num:Int)
	{
		return ((num % 2) - 0.5) / 0.5;
	}

	inline function BarStepToBeats(bar:Float, step:Float)
	{
		return (bar - 1) * 4 + (step - 1) / 4.0;
	}

	function AddNoteMod(modName:String, mod:ISchmovinNoteMod, aux:Bool = false)
	{
		var modList = _timeline.GetModList();
		modList.AddNoteMod(modName, mod, aux);
	}

	function AddNoteAuxMod(modName:String)
	{
		AddNoteMod(modName, new NoteModBase());
	}

	function RemoveNoteModByName(modName:String)
	{
		var modList = _timeline.GetModList();
		modList.RemoveNoteModByName(modName);
	}
}
