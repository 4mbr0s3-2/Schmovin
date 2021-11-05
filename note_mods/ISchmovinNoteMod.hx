/**
 * @ Author: 4mbr0s3 2
 * @ Create Time: 2021-07-15 16:28:51
 * @ Modified by: 4mbr0s3 2
 * @ Modified time: 2021-08-29 15:08:30
 */

package schmovin.note_mods;

import lime.math.Vector4;
import schmovin.SchmovinUtil.Receptor;

interface ISchmovinNoteMod
{
	public function GetName():String;
	public function SetName(v:String):Void;
	public function IsPrimaryMod():Bool;

	/**
	 * By default, note mods at 0% are not executed. Return true to force execution.
	 * @return Bool
	 */
	public function MustExecute():Bool;

	public function SetPercent(f:Float, player:Int):Void;
	public function GetPercent(player:Int):Float;
	public function ExecuteReceptor(currentBeat:Float, receptor:Receptor, player:Int, pos:Vector4):Void;
	public function ExecuteNote(currentBeat:Float, note:Note, player:Int, pos:Vector4):Void;
	public function ExecutePath(currentBeat:Float, strumTime:Float, column:Int, player:Int, pos:Vector4):Vector4;
	public function Update(currentBeat:Float):Void;
	public function ShouldDoUpdate():Bool;
}
