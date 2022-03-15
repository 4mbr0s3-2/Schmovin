/**
 * @ Author: 4mbr0s3 2
 * @ Create Time: 2021-07-19 13:51:43
 * @ Modified by: 4mbr0s3 2
 * @ Modified time: 2022-03-15 00:43:32
 */

package schmovin.note_mods;

import flixel.FlxG;
import flixel.math.FlxMath;
import lime.math.Vector4;
import openfl.geom.Matrix3D;
import openfl.geom.PerspectiveProjection;
import openfl.geom.Vector3D;

using schmovin.SchmovinUtil;

class NoteModPerspective extends NoteModBase
{
	function FastTan(rad:Float)
	{
		// Thanks Maclaurin
		return FlxMath.fastSin(rad) / FlxMath.fastCos(rad);
	}

	override function MustExecute():Bool
	{
		return false;
	}

	function View(pos:Vector4, playfield:SchmovinPlayfield)
	{
		return pos.subtract(new Vector4(GetOtherPercent('camx', playfield), GetOtherPercent('camy', playfield), GetOtherPercent('camz', playfield)));
	}

	function Projection(pos:Vector4, playfield:SchmovinPlayfield)
	{
		var fov = GetOtherPercent('camfov', playfield) * Math.PI / 2;
		var screenRatio = 1;
		var near = 0;
		var far = 2;

		var perspectiveZ = pos.z / FlxG.height - 1;
		if (perspectiveZ > 0)
			perspectiveZ = 0; // To prevent coordinate overflow :/

		var x = pos.x / FastTan(fov / 2);
		var y = pos.y * screenRatio / FastTan(fov / 2);

		var a = (near + far) / (near - far);
		var b = 2 * near * far / (near - far);
		var z = a * perspectiveZ + b;

		return new Vector4(x / z, y / z, z, 1);
	}

	// https://www.youtube.com/watch?v=dul0mui292Q Quick mafs
	// Nooooo broken link :(
	override function ExecutePath(currentBeat:Float, strumTime:Float, column:Int, player:Int, pos:Vector4, playfield:SchmovinPlayfield):Vector4
	{
		var halfScreenOffset = new Vector4(FlxG.width / 2, FlxG.height / 2);

		var modelCoords = pos.subtract(halfScreenOffset); // Center to origin
		var viewCoords = View(modelCoords, playfield);

		var clipCoords = Projection(viewCoords, playfield);

		return clipCoords.add(halfScreenOffset); // Recenter to viewport
	}

	override function ExecuteNote(currentBeat:Float, note:Note, player:Int, pos:Vector4, playfield:SchmovinPlayfield)
	{
		// if (note.isSustainNote)
		// 	note.scale.scale(1 / pos.z);
	}

	override function ExecuteReceptor(currentBeat:Float, receptor:Receptor, player:Int, pos:Vector4, playfield:SchmovinPlayfield)
	{
		// receptor.scale.scale(2 - path.w); // Guys how do I make the scale consistent??
		// receptor.scale.scale(1 / pos.z); // NVM figured it out
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
		var viewCoords = View(modelCoords, playfield);

		var clipCoords = Projection(viewCoords, playfield);

		return clipCoords.subtract(pos).add(halfScreenOffset); // Recenter to viewport
	}
}
