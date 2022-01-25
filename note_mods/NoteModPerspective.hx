/**
 * @ Author: 4mbr0s3 2
 * @ Create Time: 2021-07-19 13:51:43
 * @ Modified by: 4mbr0s3 2
 * @ Modified time: 2022-01-17 23:30:39
 */

package schmovin.note_mods;

import flixel.FlxG;
import flixel.math.FlxMath;
import lime.math.Vector4;

using schmovin.SchmovinUtil;

class NoteModPerspective extends NoteModBase
{
	function FastTan(rad:Float)
	{
		return FlxMath.fastSin(rad) / FlxMath.fastCos(rad);
	}

	override function MustExecute():Bool
	{
		return true;
	}

	function Perspective(pos:Vector4)
	{
		var outPos = pos.clone();

		var halfScreenOffset = new Vector4(FlxG.width / 2, FlxG.height / 2);
		outPos = outPos.subtract(halfScreenOffset);

		var fov = Math.PI / 2;
		var screenRatio = 1;
		var near = 0;
		var far = 2;

		var perspectiveZ = outPos.z / FlxG.height - 1;
		if (perspectiveZ > 0)
			perspectiveZ = 0; // To prevent coordinate overflow :/

		var x = outPos.x / FastTan(fov / 2);
		var y = outPos.y * screenRatio / FastTan(fov / 2);

		var a = (near + far) / (near - far);
		var b = 2 * near * far / (near - far);
		var z = a * perspectiveZ + b;

		return new Vector4(x / z, y / z, outPos.z, outPos.w).add(halfScreenOffset);
	}

	// https://www.youtube.com/watch?v=dul0mui292Q Quick mafs
	override function ExecutePath(currentBeat:Float, strumTime:Float, column:Int, player:Int, pos:Vector4, playfield:SchmovinPlayfield):Vector4
	{
		return Perspective(pos);
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
		var coords = Perspective(vert.add(pos)).subtract(pos);
		return coords;
	}
}
