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
	public function GetName():String;
	public function SetName(v:String):Void;
	public function GetParent():String;
	public function SetParent(v:String):Void;
	public function IsMiscMod():Bool;
	public function SetOrder(v:Int):Void;
	public function GetOrder():Int;
	public function IsVertexModifier():Bool;

	/**
	 * By default, note mods at 0% are not executed. Return true to force execution.
	 * @return Bool
	 */
	public function MustExecute():Bool;

	public function Initialize(state:PlayState, modList:SchmovinNoteModList, playfields:SchmovinPlayfieldManager):Void;

	@:deprecated
	public function SetLegacyPercent(f:Float, player:Int):Void;
	@:deprecated('Use SchmovinPlayfield.SetPercent() instead.')
	public function SetPercent(f:Float, playfield:SchmovinPlayfield):Void;
	@:deprecated
	public function GetLegacyPercent(player:Int):Float;
	@:deprecated
	public function GetPercent(playfield:SchmovinPlayfield):Float;
	public function IsActive():Bool;
	public function ExecuteReceptor(currentBeat:Float, receptor:Receptor, player:Int, pos:Vector4, playfield:SchmovinPlayfield):Void;
	public function ExecuteNote(currentBeat:Float, note:Note, player:Int, pos:Vector4, playfield:SchmovinPlayfield):Void;
	public function ExecuteNoteVertex(currentBeat:Float, strumTime:Float, column:Int, player:Int, vert:Vector4, vertIndex:Int, pos:Vector4,
		playfield:SchmovinPlayfield):Vector4;

	public function ExecutePath(currentBeat:Float, strumTime:Float, column:Int, player:Int, pos:Vector4, playfield:SchmovinPlayfield):Vector4;
	public function ExecuteOther(currentBeat:Float, strumTime:Float, column:Int, player:Int, map:Map<String, Dynamic>, playfield:SchmovinPlayfield):Void;

	public function Update(currentBeat:Float):Void;

	/**
	 * This function probably does nothing
	 * @return Bool
	 */
	public function ShouldDoUpdate():Bool;

	public function Activate(receptors:Array<Receptor>, notes:Array<Note>):Void;
	public function Deactivate(receptors:Array<Receptor>, notes:Array<Note>):Void;
}
