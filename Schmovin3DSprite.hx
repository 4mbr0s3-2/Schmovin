package schmovin;

import flixel.FlxBasic;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxFrame.FlxFrameType;
import flixel.system.FlxAssets.FlxGraphicAsset;
import flixel.system.FlxAssets.FlxShader;
import lime.math.Vector2;
import lime.math.Vector4;
import openfl.Vector;
import schmovin.util.Camera3DTransforms;

/**
 * A 2D FlxSprite... as a 3D plane!
 * That's right! We're breaking the framework! https://haxeflixel.com/documentation/faq/
 * I know just enough about linear algebra to make it work lol
 * 
 * This is an SM Actor moment
 */
class Schmovin3DSprite extends FlxSprite
{
	public function new(?X:Float = 0, ?Y:Float = 0, ?Z:Float = 0, ?SimpleGraphic:FlxGraphicAsset)
	{
		z = Z;
		super(X, Y, SimpleGraphic);
	}

	public var z:Float = 0.0;

	public var camX:Float = 0.0;
	public var camY:Float = 0.0;
	public var camZ:Float = 0.0;

	public var angleX:Float = 0.0;
	public var angleY:Float = 0.0;
	public var angleZ:Float = 0.0;

	override function draw()
	{
		// super.draw();
		checkEmptyFrame();

		if (alpha == 0 || _frame.type == FlxFrameType.EMPTY)
			return;

		if (dirty) // rarely
			calcFrame(useFramePixels);

		for (camera in cameras)
		{
			if (!camera.visible || !camera.exists || !isOnScreen(camera))
				continue;

			// getScreenPosition(_point, camera).subtractPoint(offset);

			// if (isSimpleRender(camera))
			// 	drawSimple(camera);
			// else
			// 	drawComplex(camera);

			var texWidth = this.frameWidth * this.scale.x;
			var texHeight = this.frameHeight * this.scale.y;

			var halfWidth = texWidth / 2;
			var halfHeight = texHeight / 2;

			var relativeVerts = [
				new Vector4(-halfWidth, -halfHeight),
				new Vector4(halfWidth, -halfHeight),
				new Vector4(-halfWidth, halfHeight),
				new Vector4(halfWidth, halfHeight)
			];

			var outVerts:Array<Vector4> = [];

			var halfScreenOffset = new Vector4(FlxG.width / 2, FlxG.height / 2);

			for (vertIndex in 0...relativeVerts.length)
			{
				var model = Camera3DTransforms.rotateVector4(relativeVerts[vertIndex], angleX, angleY, angleZ)
					.add(new Vector4(this.x, this.y, this.z))
					.subtract(halfScreenOffset);
				var props = new Map<String, Float>();
				props.set('camx', camX);
				props.set('camy', camY);
				props.set('camz', camZ);
				var view = Camera3DTransforms.view(model, props);
				var proj = Camera3DTransforms.projection(view, 1);
				outVerts.push(proj.add(halfScreenOffset));
			}

			var quad = outVerts;

			var topPoints = [new Vector2(quad[0].x, quad[0].y), new Vector2(quad[1].x, quad[1].y)];
			var bottomPoints = [new Vector2(quad[2].x, quad[2].y), new Vector2(quad[3].x, quad[3].y)];

			if (this.shader == null)
				this.shader = new FlxShader();
			if (this.shader != null)
			{
				this.shader.bitmap.input = this.graphic.bitmap;
				this.shader.bitmap.filter = this.antialiasing ? LINEAR : NEAREST;
				this.shader.hasColorTransform.value = [false];
				this.shader.alpha.value = [alpha];
			}

			var bitmap = camera.canvas;

			bitmap.graphics.beginShaderFill(this.shader, null);
			var vertices = new Vector<Float>(12, false, [
				   topPoints[0].x,    topPoints[0].y,
				   topPoints[1].x,    topPoints[1].y,
				bottomPoints[1].x, bottomPoints[1].y,
				   topPoints[0].x,    topPoints[0].y,
				bottomPoints[0].x, bottomPoints[0].y,
				bottomPoints[1].x, bottomPoints[1].y
			]);

			bitmap.graphics.drawTriangles(vertices, null, getUV(this.flipY));

			bitmap.graphics.endFill();

			#if FLX_DEBUG
			FlxBasic.visibleCount++;
			#end
		}

		#if FLX_DEBUG
		if (FlxG.debugger.drawDebug)
			drawDebug();
		#end
	}

	private function getUV(flipY:Bool)
	{
		var leftX = this.frame.frame.left / this.graphic.bitmap.width;
		var topY = this.frame.frame.top / this.graphic.bitmap.height;
		var rightX = this.frame.frame.right / this.graphic.bitmap.width;
		var bottomY = this.frame.frame.bottom / this.graphic.bitmap.height;
		return new Vector<Float>(12, false, [
			 leftX,    topY,
			rightX,    topY,
			rightX, bottomY,
			 leftX,    topY,
			 leftX, bottomY,
			rightX, bottomY
		]);
	}
}
