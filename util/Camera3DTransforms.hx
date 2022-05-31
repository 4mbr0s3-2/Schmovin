package schmovin.util;

import flixel.FlxG;
import flixel.math.FlxMath;
import lime.math.Vector4;

class Camera3DTransforms
{
	static function FastTan(rad:Float)
	{
		// Thanks Maclaurin
		return FlxMath.fastSin(rad) / FlxMath.fastCos(rad);
	}

	public static function View(pos:Vector4, camProperties:Map<String, Float>)
	{
		return pos.subtract(new Vector4(camProperties.get('camx'), camProperties.get('camy'), FlxG.height + camProperties.get('camz')));
	}

	public static function Rotate(x:Float, y:Float, angle:Float)
	{
		return [
			x * FlxMath.fastCos(angle) - y * FlxMath.fastSin(angle),
			x * FlxMath.fastSin(angle) + y * FlxMath.fastCos(angle)
		];
	}

	public static function RotateVector4(vec:Vector4, angleX:Float, angleY:Float, angleZ:Float)
	{
		var rotateZ = Rotate(vec.x, vec.y, angleZ);
		var offZ = new Vector4(rotateZ[0], rotateZ[1], vec.z);

		var rotateX = Rotate(offZ.z, offZ.y, angleX);
		var offX = new Vector4(offZ.x, rotateX[1], rotateX[0]);

		var rotateY = Rotate(offX.x, offX.z, angleY);
		var offY = new Vector4(rotateY[0], offX.y, rotateY[1]);

		return offY;
	}

	public static function Projection(pos:Vector4, pov:Float)
	{
		var camfov = pov;
		var fov = camfov * Math.PI / 2;
		var screenRatio = 1;
		var near = 0;
		var far = 2;

		var perspectiveZ = pos.z / FlxG.height;
		if (perspectiveZ > 0)
			perspectiveZ = 0; // To prevent coordinate overflow :/

		var x = pos.x / FastTan(fov / 2);
		var y = pos.y * screenRatio / FastTan(fov / 2);

		var a = (near + far) / (near - far);
		var b = 2 * near * far / (near - far);
		var z = a * perspectiveZ + b;

		return new Vector4(x / z, y / z, z * camfov, 1);
	}
}
