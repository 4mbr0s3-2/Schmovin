/**
 * @ Author: 4mbr0s3 2
 * @ Create Time: 2021-07-19 13:51:43
 * @ Modified by: 4mbr0s3 2
 * @ Modified time: 2022-05-26 21:30:43
 */

package schmovin.note_mods;

import flixel.FlxG;
import lime.math.Vector4;
import schmovin.util.Camera3DTransforms;

using schmovin.SchmovinUtil;

class NoteModPerspective extends NoteModBase
{
	override function MustExecute():Bool
	{
		return false;
	}

	function View(pos:Vector4, playfield:SchmovinPlayfield)
	{
		var props = new Map<String, Float>();
		props.set('camx', GetOtherPercent('camx', playfield));
		props.set('camy', GetOtherPercent('camy', playfield));
		props.set('camz', GetOtherPercent('camz', playfield));
		return Camera3DTransforms.View(pos, props);
	}

	function Projection(pos:Vector4, playfield:SchmovinPlayfield)
	{
		var camfov = GetOtherPercent('camfov', playfield);
		return Camera3DTransforms.Projection(pos, camfov);
	}

	// https://www.youtube.com/watch?v=dul0mui292Q Quick mafs
	// Nooooo broken link :(
	override function ExecutePath(currentBeat:Float, strumTime:Float, column:Int, player:Int, pos:Vector4, playfield:SchmovinPlayfield):Vector4
	{
		var halfScreenOffset = new Vector4(FlxG.width / 2, FlxG.height / 2);

		var modelCoords = pos.subtract(halfScreenOffset); // Center to origin
		modelCoords = Camera3DTransforms.RotateVector4(modelCoords, GetOtherPercent('campitch', playfield), GetOtherPercent('camyaw', playfield),
			GetOtherPercent('camroll', playfield));
		var viewCoords = View(modelCoords, playfield);

		var clipCoords = Projection(viewCoords, playfield);

		return clipCoords.add(halfScreenOffset); // Recenter to viewport
	}

	override function IsVertexModifier():Bool
	{
		return true;
	}

	override function ExecuteNoteVertex(currentBeat:Float, strumTime:Float, column:Int, player:Int, vert:Vector4, vertIndex:Int, pos:Vector4,
			playfield:SchmovinPlayfield):Vector4
	{
		var halfScreenOffset = new Vector4(FlxG.width / 2, FlxG.height / 2);

		var modelCoords = vert.add(pos).subtract(halfScreenOffset); // Center to origin
		modelCoords = Camera3DTransforms.RotateVector4(modelCoords, GetOtherPercent('campitch', playfield), GetOtherPercent('camyaw', playfield),
			GetOtherPercent('camroll', playfield));
		var viewCoords = View(modelCoords, playfield);

		var clipCoords = Projection(viewCoords, playfield);

		return clipCoords.subtract(pos).add(halfScreenOffset); // Recenter to viewport
	}
}
