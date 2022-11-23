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
	override function alwaysExecute():Bool
	{
		return false;
	}

	private function view(pos:Vector4, playfield:SchmovinPlayfield)
	{
		var props = new Map<String, Float>();
		props.set('camx', getOtherPercent('camx', playfield));
		props.set('camy', getOtherPercent('camy', playfield));
		props.set('camz', getOtherPercent('camz', playfield));
		return Camera3DTransforms.view(pos, props);
	}

	private function projection(pos:Vector4, playfield:SchmovinPlayfield)
	{
		var camfov = getOtherPercent('camfov', playfield);
		return Camera3DTransforms.projection(pos, camfov);
	}

	// https://www.youtube.com/watch?v=dul0mui292Q Quick mafs
	// Nooooo broken link :(
	override function executePath(currentBeat:Float, strumTime:Float, column:Int, player:Int, pos:Vector4, playfield:SchmovinPlayfield):Vector4
	{
		var halfScreenOffset = new Vector4(FlxG.width / 2, FlxG.height / 2);

		var modelCoords = pos.subtract(halfScreenOffset); // Center to origin
		modelCoords = Camera3DTransforms.rotateVector4(modelCoords, getOtherPercent('campitch', playfield), getOtherPercent('camyaw', playfield),
			getOtherPercent('camroll', playfield));
		var viewCoords = view(modelCoords, playfield);

		var clipCoords = projection(viewCoords, playfield);

		return clipCoords.add(halfScreenOffset); // Recenter to viewport
	}

	override function isVertexModifier():Bool
	{
		return true;
	}

	override function executeNoteVertex(currentBeat:Float, strumTime:Float, column:Int, player:Int, vert:Vector4, vertIndex:Int, pos:Vector4,
			playfield:SchmovinPlayfield):Vector4
	{
		var halfScreenOffset = new Vector4(FlxG.width / 2, FlxG.height / 2);

		var modelCoords = vert.add(pos).subtract(halfScreenOffset); // Center to origin
		modelCoords = Camera3DTransforms.rotateVector4(modelCoords, getOtherPercent('campitch', playfield), getOtherPercent('camyaw', playfield),
			getOtherPercent('camroll', playfield));
		var viewCoords = view(modelCoords, playfield);

		var clipCoords = projection(viewCoords, playfield);

		return clipCoords.subtract(pos).add(halfScreenOffset); // Recenter to viewport
	}
}
