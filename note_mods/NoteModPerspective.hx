/**
 * @ Author: 4mbr0s3 2
 * @ Create Time: 2021-07-19 13:51:43
 * @ Modified by: 4mbr0s3 2
 * @ Modified time: 2021-08-29 15:08:49
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

	// https://www.youtube.com/watch?v=dul0mui292Q Quick mafs
	override function ExecutePath(currentBeat:Float, strumTimeDiff:Float, column:Int, player:Int, pos:Vector4):Vector4
	{
		var outPos = pos.clone();

		var halfScreenOffset = new Vector4(FlxG.width / 2, FlxG.height / 2);
		outPos = outPos.subtract(halfScreenOffset);

		var fov = Math.PI / 2;
		var screenRatio = 1;
		var near = 0;
		var far = 2;

		var perspectiveZ = outPos.z - 1;
		if (perspectiveZ > 0)
			perspectiveZ = 0; // To prevent coordinate overflow :/

		var x = outPos.x / FastTan(fov / 2);
		var y = outPos.y * screenRatio / FastTan(fov / 2);

		var a = (near + far) / (near - far);
		var b = 2 * near * far / (near - far);
		var z = a * perspectiveZ + b;

		return new Vector4(x / z, y / z, z, outPos.w).add(halfScreenOffset);
	}

	override function ExecuteNote(currentBeat:Float, note:Note, player:Int, pos:Vector4)
	{
		note.scale.scale(1 / pos.z);
	}

	override function ExecuteReceptor(currentBeat:Float, receptor:Receptor, player:Int, pos:Vector4)
	{
		// receptor.scale.scale(2 - path.w); // Guys how do I make the scale consistent??
		receptor.scale.scale(1 / pos.z); // NVM figured it out
	}
}
