package schmovin.util;

import flixel.FlxG;
import flixel.math.FlxMath;
import lime.math.Vector4;

class Camera3DTransforms
{
	private static function fastTan(rad:Float)
	{
		// Thanks Maclaurin
		return FlxMath.fastSin(rad) / FlxMath.fastCos(rad);
	}

	public static function view(pos:Vector4, camProperties:Map<String, Float>)
	{
		return pos.subtract(new Vector4(camProperties.get('camx'), camProperties.get('camy'), FlxG.height + camProperties.get('camz')));
	}

	public static function rotate(x:Float, y:Float, angle:Float)
	{
		return [
			x * FlxMath.fastCos(angle) - y * FlxMath.fastSin(angle),
			x * FlxMath.fastSin(angle) + y * FlxMath.fastCos(angle)
		];
	}

	public static function rotateVector4(vec:Vector4, angleX:Float, angleY:Float, angleZ:Float)
	{
		// var rotateZ = rotate(vec.x, vec.y, angleZ);
		// var offZ = new Vector4(rotateZ[0], rotateZ[1], vec.z);

		// var rotateX = rotate(offZ.z, offZ.y, angleX);
		// var offX = new Vector4(offZ.x, rotateX[1], rotateX[0]);

		// var rotateY = rotate(offX.x, offX.z, angleY);
		// var offY = new Vector4(rotateY[0], offX.y, rotateY[1]);

		var rotateZ = rotate(vec.x, vec.y, angleZ);
		var offZ = new Vector4(rotateZ[0], rotateZ[1], vec.z);

		var rotateY = rotate(offZ.x, offZ.z, angleY);
		var offY = new Vector4(rotateY[0], offZ.y, rotateY[1]);

		var rotateX = rotate(offY.z, offY.y, angleX);
		var offX = new Vector4(offY.x, rotateX[1], rotateX[0]);

		// var rotateX = rotate(vec.z, vec.y, angleX);
		// var offX = new Vector4(vec.x, rotateX[1], rotateX[0]);

		// var rotateY = rotate(offX.x, offX.z, angleY);
		// var offY = new Vector4(rotateY[0], offX.y, rotateY[1]);

		// var rotateZ = rotate(offY.x, offY.y, angleZ);
		// var offZ = new Vector4(rotateZ[0], rotateZ[1], offY.z);

		return offX;
	}

	public static function projection(pos:Vector4, pov:Float)
	{
		var camfov = pov;
		var fov = camfov * Math.PI / 2;
		var screenRatio = 1;
		var near = 0;
		var far = 2;

		var perspectiveZ = pos.z / FlxG.height;
		if (perspectiveZ > 0)
			perspectiveZ = 0; // To prevent coordinate overflow :/

		var x = pos.x / fastTan(fov / 2);
		var y = pos.y * screenRatio / fastTan(fov / 2);

		var a = (near + far) / (near - far);
		var b = 2 * near * far / (near - far);
		var z = a * perspectiveZ + b;

		return new Vector4(x / z, y / z, z * camfov, 1);
	}
}
