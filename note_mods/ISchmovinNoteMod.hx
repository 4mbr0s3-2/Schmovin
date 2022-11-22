/**
 * @ Author: 4mbr0s3 2
 * @ Create Time: 2021-07-15 16:28:51
 * @ Modified by: 4mbr0s3 2
 * @ Modified time: 2022-03-14 01:08:23
 */

package schmovin.note_mods;

import lime.math.Vector4;
import schmovin.SchmovinUtil.Receptor;

interface ISchmovinNoteMod
{
	public function getName():String;
	public function setName(v:String):Void;
	public function getParent():String;
	public function setParent(v:String):Void;
	public function isMiscMod():Bool;
	public function setOrder(v:Int):Void;
	public function getOrder():Int;
	public function isVertexModifier():Bool;

	/**
	 * By default, note mods at 0% are not executed. Return true to force execution.
	 * @return Bool
	 */
	public function alwaysExecute():Bool;

	public function initialize(state:PlayState, modList:SchmovinNoteModList, playfields:SchmovinPlayfieldManager):Void;

	@:deprecated
	public function setLegacyPercent(f:Float, player:Int):Void;
	@:deprecated
	public function getLegacyPercent(player:Int):Float;
	@:deprecated
	public function getPercent(playfield:SchmovinPlayfield):Float;
	public function onSetPercent(f:Float, playfield:SchmovinPlayfield):Void;
	public function isActive():Bool;
	public function executeReceptor(currentBeat:Float, receptor:Receptor, player:Int, pos:Vector4, playfield:SchmovinPlayfield):Void;
	public function executeNote(currentBeat:Float, note:Note, player:Int, pos:Vector4, playfield:SchmovinPlayfield):Void;
	public function executeNoteVertex(currentBeat:Float, strumTime:Float, column:Int, player:Int, vert:Vector4, vertIndex:Int, pos:Vector4,
		playfield:SchmovinPlayfield):Vector4;

	public function executePath(currentBeat:Float, strumTime:Float, column:Int, player:Int, pos:Vector4, playfield:SchmovinPlayfield):Vector4;

	/**
		Called before executePath(), so playfield.setPercent() can work here.
	**/
	public function executeOther(currentBeat:Float, strumTime:Float, column:Int, player:Int, map:Map<String, Dynamic>, playfield:SchmovinPlayfield):Void;

	public function update(currentBeat:Float):Void;
	public function activate(receptors:Array<Receptor>, notes:Array<Note>):Void;
	public function deactivate(receptors:Array<Receptor>, notes:Array<Note>):Void;
}
