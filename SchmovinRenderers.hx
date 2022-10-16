/**
 * @ Author: 4mbr0s3 2
 * @ Create Time: 2021-07-07 13:26:53
 * @ Modified by: 4mbr0s3 2
 * @ Modified time: 2022-07-23 14:37:02
 */

package schmovin;

import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.graphics.tile.FlxDrawTrianglesItem;
import flixel.math.FlxMath;
import flixel.system.FlxAssets.FlxShader;
import flixel.util.FlxColor;
import lime.math.Vector2;
import lime.math.Vector4;
import openfl.Vector;
import openfl.display.BitmapData;
import openfl.display.BlendMode;
import openfl.display.Graphics;
import openfl.display.GraphicsPathCommand;
import openfl.display.OpenGLRenderer;
import openfl.display.Shape;
import openfl.display.Sprite;
import openfl.geom.ColorTransform;
import openfl.geom.Matrix;
import openfl.geom.Rectangle;
import schmovin.SchmovinTimeline;
import schmovin.SchmovinUtil.Receptor;

using StringTools;

interface ISchmovinRenderer
{
	public function PreDraw():Void;
	public function PostDraw():Void;
	public function Destroy():Void;
}

class SchmovinRenderer implements ISchmovinRenderer
{
	var _timeline:SchmovinTimeline;
	var _instance:SchmovinInstance;
	var _defaultCameras:Array<FlxCamera>;
	var _playState:PlayState;

	public function PreDraw() {}

	public function PostDraw() {}

	public function Destroy() {}

	public function new(playState:PlayState, cameras:Array<FlxCamera>, timeline:SchmovinTimeline, instance:SchmovinInstance)
	{
		_instance = instance;
		_timeline = timeline;
		_defaultCameras = cameras;
		_playState = playState;
	}
}

class SchmovinNotePathRenderer extends SchmovinRenderer
{
	static var ARROW_PATH_SUBDIVISIONS(get, null):Int;

	static function get_ARROW_PATH_SUBDIVISIONS()
	{
		return SchmovinAdapter.GetInstance().GetArrowPathSubdivisions();
	}

	public function new(playState:PlayState, cameras:Array<FlxCamera>, timeline:SchmovinTimeline, instance:SchmovinInstance)
	{
		super(playState, cameras, timeline, instance);
	}

	override function PreDraw()
	{
		var currentBeat = SchmovinAdapter.GetInstance().GetCurrentBeat();
		var length = -2000.0;
		var subdivisions:Int = cast ARROW_PATH_SUBDIVISIONS / _instance.playfields.list.length;
		var boundary = 300;
		var bitmap = new Shape();

		// This gets REALLY laggy because of those GetPath() calls, but I have no idea how else to optimize it...

		for (playfield in _instance.playfields.list)
		{
			@:privateAccess
			if (playfield.GetPercent('arrowpath') == 0)
				continue;
			for (column in 0...4)
			{
				var alpha = playfield.GetPercent('arrowpath${column}') + playfield.GetPercent('arrowpath');

				var commands = new Vector<Int>();
				var data = new Vector<Float>();
				var player = SchmovinUtil.GetPlayerOfTotalColumn(column);

				var size = _timeline.GetNoteMod('arrowpathsize${column}').GetPercent(playfield) + _timeline.GetNoteMod('arrowpathsize').GetPercent(playfield);
				var path1 = _timeline.GetPath(currentBeat, 0, column, player, playfield);
				bitmap.graphics.lineStyle(1 + size, 0xFFFFFF, 1);
				commands.push(GraphicsPathCommand.MOVE_TO);
				data.push(path1.x);
				data.push(path1.y);
				for (i in 0...subdivisions)
				{
					var path2 = _timeline.GetPath(currentBeat, length / subdivisions * (i + 1), column, player, playfield);
					if (FlxMath.inBounds(path2.x, -boundary, FlxG.width + boundary)
						&& FlxMath.inBounds(path2.y, -boundary, FlxG.height + boundary))
					{
						commands.push(GraphicsPathCommand.LINE_TO);
						data.push(path2.x);
						data.push(path2.y);
					}
				}
				bitmap.graphics.drawPath(commands, data);
			}
			// For some reason, drawing to a bitmap here THEN copying to camera buffer is more efficient than copying to camera buffer directly
			// (FPS increased from 35 to 50 in Windows build, rest of the lag caused by path computation I think)
			// How does that even work??? - 4mbr0s3 2 (maybe it has to do with the set resolution or something)
			// EDIT: This explains a little bit I think
			// https://community.openfl.org/t/drawed-lines-uses-too-much-cpu-neko/8651/7
			// EDIT 2: OK, so it looks like copying to camera buffer gives higher FPS on HTML (~100 to 190), so we'll use different methods accordingly

			var cameras = playfield.cameras != null ? playfield.cameras : _defaultCameras;
			#if html5
			for (camera in cameras)
			{
				camera.canvas.graphics.copyFrom(bitmap.graphics);
			}
			#else
			var bitmapData = new BitmapData(FlxG.width, FlxG.height, true, 0);
			bitmapData.draw(bitmap);
			for (camera in cameras)
			{
				camera.canvas.graphics.beginBitmapFill(bitmapData, new Matrix());
				camera.canvas.graphics.drawRect(0, 0, FlxG.width, FlxG.height);
				camera.canvas.graphics.endFill();
			}
			#end
		}
	}
}

/**
 * "Perspective oriented notes are deff not possible" - haya3218
 */
class SchmovinTapNoteRenderer extends SchmovinRenderer
{
	static inline var HOLD_ALPHA_DIVISIONS = 20;

	public function Initialize() {}

	override function Destroy() {}

	override function PreDraw()
	{
		Draw();
	}

	function updateFramePixels(s:FlxSprite, alpha:Float)
	{
		var data = s.frame.paint();
		if (alpha < 1)
			data.colorTransform(new Rectangle(0, 0, s.frameWidth, s.frameHeight), new ColorTransform(1, 1, 1, alpha));
		return data;
	}

	inline function GetQuadAlongPath(strumTime:Float, pos:Vector4, playfield:SchmovinPlayfield, obj:FlxSprite, column:Int, player:Int, targetWidth:Float,
			targetHeight:Float)
	{
		var texWidth = targetWidth;
		var texHeight = targetHeight;

		var halfWidth = texWidth / 2;
		var halfHeight = texHeight / 2;

		var relativeVerts = [
			new Vector4(-halfWidth, -halfHeight),
			new Vector4(halfWidth, -halfHeight),
			new Vector4(-halfWidth, halfHeight),
			new Vector4(halfWidth, halfHeight)
		];

		var outVerts:Array<Vector4> = [];

		// FNF players' CPUs:
		// https://tenor.com/view/better-call-saul-charles-chuck-mcgill-nailed-gif-21607593

		for (vertIndex in 0...relativeVerts.length)
		{
			var vert = relativeVerts[vertIndex];
			vert = _timeline.UpdateNoteVertex(playfield, SchmovinAdapter.GetInstance().GetCurrentBeat(), obj, vert, vertIndex, pos, player, column);
			outVerts.push(vert.add(pos));
		}

		return outVerts;
	}

	function GetReceptors():Array<Receptor>
	{
		var receps = [];
		for (p in 0...2)
			receps = receps.concat(SchmovinUtil.GetReceptors(p, _playState));
		return receps;
	}

	function Draw()
	{
		function GetTapNotes()
		{
			return _playState.notes.members.filter((note) ->
			{
				if (note == null)
					return false;
				var onScreen = !note.isSustainNote && note.alive;
				return onScreen;
			});
		}
		for (receptor in GetReceptors())
			Render(receptor.wrappee, receptor.wrappee.alpha, 0, receptor.column, SchmovinUtil.GetPlayerOfTotalColumn(receptor.column));

		for (tap in GetTapNotes())
		{
			Render(tap, tap.alpha, SchmovinAdapter.GetInstance().GetSongPosition() - tap.strumTime, SchmovinUtil.GetTotalColumn(tap),
				SchmovinUtil.GetPlayer(tap));
		}
	}

	// This is really laggy with OpenGL, but WebGL runs like it's nothing
	// TODO: Figure out how to profile this on desktop??

	function Render(sprite:FlxSprite, alpha:Float, strumTime:Float, column:Int, player:Int)
	{
		for (playfield in _instance.playfields.list)
		{
			if (playfield.player != player)
				continue;
			var cameras = playfield.cameras != null ? playfield.cameras : _defaultCameras;
			for (camera in cameras)
			{
				var bitmap = camera.canvas;

				var currentBeat = SchmovinAdapter.GetInstance().GetCurrentBeat();

				var props = _timeline.GetOtherMap(currentBeat, strumTime, column, player, playfield);

				if (props.exists('alpha'))
					alpha *= props['alpha'];

				var pos = _timeline.GetPath(currentBeat, strumTime, column, player, playfield, ['cam']);

				// TODO: Move to main update loop
				// _timeline.UpdateNote(_instance.playfields.GetPlayfieldAtIndex(player), currentBeat, sprite, pos, player, column);

				var quad = GetQuadAlongPath(strumTime, pos, playfield, sprite, column, player, sprite.frameWidth * sprite.scale.x,
					sprite.frameHeight * sprite.scale.y);

				var topPoints = [new Vector2(quad[0].x, quad[0].y), new Vector2(quad[1].x, quad[1].y)];
				var bottomPoints = [new Vector2(quad[2].x, quad[2].y), new Vector2(quad[3].x, quad[3].y)];

				if (sprite.shader == null)
					sprite.shader = new FlxShader();
				if (sprite.shader != null)
				{
					sprite.shader.bitmap.input = sprite.graphic.bitmap;
					sprite.shader.bitmap.filter = sprite.antialiasing ? LINEAR : NEAREST;
					sprite.shader.hasColorTransform.value = [false];
					sprite.shader.alpha.value = [alpha];
				}

				bitmap.graphics.beginShaderFill(sprite.shader, null);
				var vertices = new Vector<Float>(12, false, [
					   topPoints[0].x,    topPoints[0].y,
					   topPoints[1].x,    topPoints[1].y,
					bottomPoints[1].x, bottomPoints[1].y,
					   topPoints[0].x,    topPoints[0].y,
					bottomPoints[0].x, bottomPoints[0].y,
					bottomPoints[1].x, bottomPoints[1].y
				]);

				bitmap.graphics.drawTriangles(vertices, null, GetUV(sprite, sprite.flipY));

				bitmap.graphics.endFill();
				#if FLX_DEBUG
				if (FlxG.debugger.drawDebug)
				{
					var gfx:Graphics = camera.debugLayer.graphics;
					gfx.lineStyle(1, FlxColor.BLUE, 0.5);
					gfx.drawTriangles(vertices, null);
				}
				#end
			}
		}
	}

	public function new(playState:PlayState, cameras:Array<FlxCamera>, timeline:SchmovinTimeline, instance:SchmovinInstance)
	{
		super(playState, cameras, timeline, instance);
		Initialize();
	}

	function GetUV(sprite:FlxSprite, flipY:Bool)
	{
		var leftX = sprite.frame.frame.left / sprite.graphic.bitmap.width;
		var topY = sprite.frame.frame.top / sprite.graphic.bitmap.height;
		var rightX = sprite.frame.frame.right / sprite.graphic.bitmap.width;
		var bottomY = sprite.frame.frame.bottom / sprite.graphic.bitmap.height;
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

/**
 * An overengineered way to get rid of the most notorious bug in the game: broken hold note spacing.
 * Oh yeah, it also allows you to divide hold notes into sections and bend them.
 * Instead of rectangles, it uses pairs of triangles (aka quadrilaterals) to bend the hold note bitmap. 
 * The ends of each pair are extended from the calculated tangent of the note path.
 * https://imgur.com/a/pI57u3A
 * 
 * If you use this in your own mods, please give credit. 
 * This took forever to figure out... - 4mbr0s3 2
 */
class SchmovinHoldNoteRenderer extends SchmovinRenderer
{
	@:deprecated('Outdated due to a better method of applying alpha (via shaders)')
	static inline var HOLD_ALPHA_DIVISIONS = 1;

	var _holdConditional:Null<Note->Bool>;

	/**
	 * updateFramePixels() grabs the bitmap of the hold note with the alpha channel but is quite costly.
	 * The solution is to cache a few alpha variants of the bitmap for each column and then use them when needed.
	 * 
	 * ADDENDUM: 🦀 HOLD GRAPHICS CACHING IS GONE 🦀
	 * 
	 * hours_wasted = 38
	 */
	static var HOLD_SUBDIVISIONS(get, null):Int;

	override function Destroy() {}

	static function get_HOLD_SUBDIVISIONS()
	{
		return SchmovinAdapter.GetInstance().GetHoldNoteSubdivisions();
	}

	static inline var SEAMLESS_EXTENSION = 2;

	public function Initialize() {}

	override function PreDraw()
	{
		DrawHoldNotes();
	}

	function CalculatePointsAlongPathNormal(targetWidth:Float, hold:Note, strumTime:Float, column:Int, player:Int, playfield:SchmovinPlayfield)
	{
		var currentBeat = SchmovinAdapter.GetInstance().GetCurrentBeat();

		// We do a lil' calculus
		var infinitesimal = 1;

		var path1 = _timeline.GetPath(currentBeat, strumTime, column, player, playfield);
		var pathPerspective = path1.clone();
		path1.z = 0;

		var texWidth = targetWidth;

		var halfWidth = texWidth / 2;

		var relativeVerts = [new Vector4(-halfWidth, 0), new Vector4(halfWidth, 0)];

		if (SchmovinAdapter.GetInstance().GetOptimizeHoldNotes())
		{
			var perp1 = path1.add(relativeVerts[0]);
			var perp2 = path1.add(relativeVerts[1]);
			return [perp1, perp2];
		}

		var path2 = _timeline.GetPath(currentBeat, strumTime + infinitesimal, column, player, playfield);
		path2.z = 0;

		var outVerts = relativeVerts;

		var perspectiveScale = 1.0;
		if (pathPerspective.z != 0)
			perspectiveScale = pathPerspective.z;

		var trueWidth = outVerts[0].subtract(outVerts[1]).length / 2 / perspectiveScale;

		var unit = path2.subtract(path1);

		unit.normalize();

		var off1 = new Vector4(unit.y, -unit.x);
		var off2 = new Vector4(-unit.y, unit.x);
		off1.scaleBy(trueWidth);
		off2.scaleBy(trueWidth);

		var perp1 = path1.add(off1);
		var perp2 = path1.add(off2);

		return [perp1, perp2];
	}

	// TODO: Extract methods, make it a bit neater
	function DrawHoldNotes()
	{
		function GetHoldNotes(playfield:SchmovinPlayfield)
		{
			return _playState.notes.members.filter((hold) ->
			{
				var dist = hold.strumTime - Conductor.songPosition;
				return SchmovinUtil.GetPlayer(hold) == playfield.player
					&& hold.isSustainNote
					&& hold.alive
					&& dist < 1500 + _timeline.GetNoteMod('drawdistance').GetPercent(playfield)
					&& dist >= 0;
			});
		}
		for (playfield in _instance.playfields.list)
		{
			var cameras = playfield.cameras != null ? playfield.cameras : _defaultCameras;
			for (camera in cameras)
			{
				var canvas = camera.canvas;
				var lastShader = null;
				var lastFrame = null;
				for (hold in GetHoldNotes(playfield))
				{
					var verticesArray = [];
					var uvArray = [];

					var subdivisions = HOLD_SUBDIVISIONS;
					var holdEnd = false;
					if (hold.animation.name.contains('end'))
						holdEnd = true;
					var lastBottom = null;
					var crotchet = SchmovinAdapter.GetInstance().GetCrotchetAtTime(hold.strumTime) / 4;
					var strumTimeDiff = SchmovinAdapter.GetInstance().GetSongPosition() - hold.strumTime;

					var alpha = hold.alpha;
					var frame = hold.graphic.bitmap;

					var currentShader = hold.shader;
					var currentFrame = frame;

					if (lastShader != currentShader || lastFrame != currentFrame)
					{
						if (hold.shader == null)
							hold.shader = new FlxShader();
						if (hold.shader != null)
						{
							hold.shader.bitmap.input = currentFrame;
							hold.shader.bitmap.filter = hold.antialiasing ? LINEAR : NEAREST;
							hold.shader.hasColorTransform.value = [false];
							hold.shader.alpha.value = [alpha];
							canvas.graphics.beginShaderFill(currentShader, null);
						}
					}

					lastShader = currentShader;
					lastFrame = currentFrame;

					for (sub in 0...subdivisions)
					{
						if (hold.scale == null)
							continue;

						var subdivisionProg = sub / (subdivisions + 1);
						var nextSubdivisionProg = (sub + 1) / (subdivisions + 1);

						var calcTopWidth = hold.frameWidth * hold.scale.x;
						var calcBottomWidth = hold.prevNote.isSustainNote ? hold.prevNote.width : hold.width;

						var strumLineSub = crotchet / subdivisions;
						var strumLineOffset = strumLineSub * sub;

						// This scaling will be our "clipping rectangle"
						if (strumTimeDiff > -crotchet - SchmovinAdapter.GetInstance().GrabGlobalVisualOffset() && strumTimeDiff <= 0)
						{
							var scale = 1 - (strumTimeDiff + crotchet) / crotchet;
							strumLineSub *= scale;
							strumLineOffset *= scale;
						}

						// This lerps between the two widths to make the hold look smooth.
						// No more jaggy 3D holds :')
						var topWidth = FlxMath.lerp(calcTopWidth, calcBottomWidth, subdivisionProg);
						var bottomWidth = FlxMath.lerp(calcTopWidth, calcBottomWidth, nextSubdivisionProg);

						var totalColumn = SchmovinUtil.GetTotalColumn(hold);
						var player = SchmovinUtil.GetPlayer(hold);

						var top = lastBottom == null ? CalculatePointsAlongPathNormal(topWidth, hold, strumTimeDiff + strumLineOffset, totalColumn, player,
							playfield) : lastBottom;
						var bottom = CalculatePointsAlongPathNormal(bottomWidth, hold, strumTimeDiff + strumLineOffset + strumLineSub, totalColumn, player,
							playfield);
						lastBottom = bottom;
						var topPoints = [new Vector2(top[0].x, top[0].y), new Vector2(top[1].x, top[1].y)];
						var bottomPoints = [new Vector2(bottom[0].x, bottom[0].y), new Vector2(bottom[1].x, bottom[1].y)];

						// Fancy method
						verticesArray = verticesArray.concat([
							   topPoints[0].x,    topPoints[0].y,
							   topPoints[1].x,    topPoints[1].y,
							bottomPoints[1].x, bottomPoints[1].y,
							   topPoints[0].x,    topPoints[0].y,
							bottomPoints[0].x, bottomPoints[0].y,
							bottomPoints[1].x, bottomPoints[1].y
						]);
						uvArray = uvArray.concat(GetUV(hold, hold.flipY, sub, subdivisions));
					}
					var vertices = new Vector<Float>(verticesArray.length, false, cast verticesArray);
					var uv = new Vector<Float>(uvArray.length, false, uvArray);

					var indices = new Vector<Int>();
					for (i in 0...vertices.length)
						indices.push(i);

					canvas.graphics.drawTriangles(vertices, indices, uv);

					#if FLX_DEBUG
					if (FlxG.debugger.drawDebug)
					{
						var gfx:Graphics = camera.debugLayer.graphics;
						gfx.lineStyle(1, FlxColor.BLUE, 0.5);
						gfx.drawTriangles(vertices, null);
					}
					#end
				}
			}
		}
	}

	function GetUV(sprite:FlxSprite, flipY:Bool, sub:Int, subdivisions:Int)
	{
		var leftX = sprite.frame.frame.left / sprite.graphic.bitmap.width;
		var topY = sprite.frame.frame.top / sprite.graphic.bitmap.height;
		var rightX = sprite.frame.frame.right / sprite.graphic.bitmap.width;
		var height = sprite.frame.frame.height / sprite.graphic.bitmap.height;

		if (!flipY)
			sub = (subdivisions - 1) - sub;
		var uvSub = 1.0 / subdivisions;
		var uvOffset = uvSub * sub;
		if (flipY)
		{
			return [
				 leftX,           topY + uvOffset * height,
				rightX,           topY + uvOffset * height,
				rightX, topY + (uvOffset + uvSub) * height,
				 leftX,           topY + uvOffset * height,
				 leftX, topY + (uvOffset + uvSub) * height,
				rightX, topY + (uvOffset + uvSub) * height
			];
		}
		return [
			 leftX, topY + (uvSub + uvOffset) * height,
			rightX, topY + (uvSub + uvOffset) * height,
			rightX,           topY + uvOffset * height,
			 leftX, topY + (uvSub + uvOffset) * height,
			 leftX,           topY + uvOffset * height,
			rightX,           topY + uvOffset * height
		];
	}

	public function new(playState:PlayState, cameras:Array<FlxCamera>, timeline:SchmovinTimeline, instance:SchmovinInstance,
			holdConditional:Null<Note->Bool> = null)
	{
		_holdConditional = holdConditional;
		super(playState, cameras, timeline, instance);
		Initialize();
	}
}
