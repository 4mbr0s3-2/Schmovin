/**
 * @ Author: 4mbr0s3 2
 * @ Create Time: 2021-07-07 13:26:53
 * @ Modified by: 4mbr0s3 2
 * @ Modified time: 2021-11-13 11:28:36
 */

package schmovin;

import flixel.FlxCamera;
import flixel.FlxG;
import flixel.math.FlxMath;
import lime.math.Vector2;
import lime.math.Vector4;
import openfl.Vector;
import openfl.display.BitmapData;
import openfl.display.GraphicsPathCommand;
import openfl.display.Shape;
import openfl.geom.ColorTransform;
import openfl.geom.Matrix;
import openfl.geom.Rectangle;
import schmovin.SchmovinTimeline;

using StringTools;

interface ISchmovinRenderer
{
	public function PreDraw():Void;
	public function PostDraw():Void;
}

class SchmovinRenderer implements ISchmovinRenderer
{
	var _timeline:SchmovinTimeline;
	var _instance:SchmovinInstance;
	var _cameras:Array<FlxCamera>;
	var _playState:PlayState;

	public function PreDraw() {}

	public function PostDraw() {}

	public function new(playState:PlayState, cameras:Array<FlxCamera>, timeline:SchmovinTimeline, instance:SchmovinInstance)
	{
		_instance = instance;
		_timeline = timeline;
		_cameras = cameras;
		_playState = playState;
	}
}

class SchmovinNotePathRenderer extends SchmovinRenderer
{
	public function new(playState:PlayState, cameras:Array<FlxCamera>, timeline:SchmovinTimeline, instance:SchmovinInstance)
	{
		super(playState, cameras, timeline, instance);
	}

	override function PreDraw()
	{
		var bitmap = new Shape();
		var length = -2000.0;
		var subdivisions = 80;
		var boundary = 300;
		for (column in 0...8)
		{
			var commands = new Vector<Int>();
			var data = new Vector<Float>();
			var player = SchmovinUtil.GetPlayerOfTotalColumn(column);
			var alpha = _timeline.GetNoteMod('arrowpath${column % 4}').GetPercent(player) + _timeline.GetNoteMod('arrowpath').GetPercent(player);
			if (alpha <= 0)
				continue;
			var size = _timeline.GetNoteMod('arrowpathsize${column % 4}').GetPercent(player) + _timeline.GetNoteMod('arrowpathsize').GetPercent(player);
			var path1 = _timeline.GetPath(Schmovin.GetCurrentBeat(), 0, column, player);
			bitmap.graphics.lineStyle(1 + size, 0xFFFFFF, 1);
			commands.push(GraphicsPathCommand.MOVE_TO);
			data.push(path1.x);
			data.push(path1.y);
			for (i in 0...subdivisions)
			{
				var path2 = _timeline.GetPath(Schmovin.GetCurrentBeat(), length / subdivisions * (i + 1), column, player);
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

		#if html5
		for (camera in _cameras)
		{
			camera.canvas.graphics.copyFrom(bitmap.graphics);
		}
		#else
		var bitmapData = new BitmapData(FlxG.width, FlxG.height, true, 0);
		bitmapData.draw(bitmap);
		for (camera in _cameras)
		{
			camera.canvas.graphics.beginBitmapFill(bitmapData, new Matrix());
			camera.canvas.graphics.drawRect(0, 0, FlxG.width, FlxG.height);
			camera.canvas.graphics.endFill();
		}
		#end
	}
}

/**
 * An overengineered way to get rid of the most notorious bug in the game: broken hold note spacing.
 * Oh yeah, it also allows you to divide hold notes into sections and bend them.
 * Instead of rectangles, it uses pairs of triangles to bend the hold note bitmap. 
 * The ends of each pair are extended from the calculated tangent of the note path.
 * https://imgur.com/a/pI57u3A
 * 
 * If you use this in your own mods, please give credit. 
 * This took forever to figure out... - 4mbr0s3 2
 */
class SchmovinHoldNoteRenderer extends SchmovinRenderer
{
	static inline var HOLD_ALPHA_DIVISIONS = 20;

	var _holdConditional:Null<Note->Bool>;

	/**
	 * updateFramePixels() grabs the bitmap of the hold note with the alpha channel but is quite costly.
	 * The solution is to cache a few alpha variants of the bitmap for each column and then use them when needed.
	 * 
	 * hours_wasted = 27
	 */
	var _cachedHoldGraphics:Map<Int, Map<Int, BitmapData>> = new Map<Int, Map<Int, BitmapData>>();

	var _cachedHoldEndGraphics:Map<Int, Map<Int, BitmapData>> = new Map<Int, Map<Int, BitmapData>>();

	static var HOLD_SUBDIVISIONS(get, null):Int;

	static function get_HOLD_SUBDIVISIONS()
	{
		return Schmovin.holdNoteSubdivisions;
	}

	static inline var SEAMLESS_EXTENSION = 2;

	public function Initialize() {}

	override function PreDraw()
	{
		DrawHoldNotes();
	}

	function updateFramePixels(note:Note, alpha:Float)
	{
		var data = note.frame.paint();
		if (alpha < 1)
			data.colorTransform(new Rectangle(0, 0, note.frameWidth, note.frameHeight), new ColorTransform(1, 1, 1, alpha));
		return data;
	}

	function InitializeHoldCache(cache:Map<Int, Map<Int, BitmapData>>, note:Note, column:Int)
	{
		var map = new Map<Int, BitmapData>();
		cache.set(column, map);
		for (i in 0...HOLD_ALPHA_DIVISIONS)
		{
			map.set(i, updateFramePixels(note, i / (HOLD_ALPHA_DIVISIONS - 1)).clone());
		}
	}

	function GrabFrame(note:Note, alpha:Float)
	{
		// updateFramePixels() must be called as little as possible, so we use the same BitmapData for connected holds
		var snapAlpha = Math.floor((HOLD_ALPHA_DIVISIONS - 1) * alpha);
		var column = SchmovinUtil.GetTotalColumn(note);

		if (note.animation.name.contains('end'))
		{
			if (_cachedHoldEndGraphics.get(column) == null)
				InitializeHoldCache(_cachedHoldEndGraphics, note, column);
			return _cachedHoldEndGraphics[column][snapAlpha];
		}

		if (_cachedHoldGraphics.get(column) == null)
			InitializeHoldCache(_cachedHoldGraphics, note, column);
		return _cachedHoldGraphics[column][snapAlpha];
	}

	function CalculatePointsAlongPathNormal(width:Float, strumTime:Float, column:Int, player:Int)
	{
		// We do a lil' calculus
		var infinitesimal = 1;

		var path1 = _timeline.GetPath(Schmovin.GetCurrentBeat(), strumTime, column, player);
		var path2 = _timeline.GetPath(Schmovin.GetCurrentBeat(), strumTime + infinitesimal, column, player);

		var unit = path2.subtract(path1);
		unit.normalize();

		var off1 = new Vector4(unit.y, -unit.x);
		var off2 = new Vector4(-unit.y, unit.x);
		off1.scaleBy(width / 2);
		off2.scaleBy(width / 2);

		var perp1 = path1.add(off1);
		var perp2 = path1.add(off2);

		return [perp1, perp2];
	}

	function DrawHoldNotes()
	{
		function GetHoldNotes()
		{
			return _playState.notes.members.filter((note) ->
			{
				if (note == null)
					return false;
				var onScreen = note.isSustainNote && note.alive && Conductor.songPosition <= note.strumTime;
				if (_holdConditional != null)
					onScreen = onScreen && _holdConditional(note);
				return onScreen;
			});
		}
		var bitmap = new Shape();
		for (hold in GetHoldNotes())
		{
			var subdivisions = HOLD_SUBDIVISIONS;
			var holdEnd = false;
			if (hold.animation.name.contains('end'))
				holdEnd = true;
			var crotchet = SchmovinAdapter.GetInstance().GetCrotchetAtTime(hold.strumTime) / 4;
			for (sub in 0...subdivisions)
			{
				if (hold.scale == null)
					continue;

				var strumLineSub = crotchet / subdivisions;
				var strumLineOffset = strumLineSub * sub;
				var strumTimeDiff = SchmovinAdapter.GetInstance().GetSongPosition() - hold.strumTime - SchmovinAdapter.GetInstance().GrabGlobalVisualOffset();

				// This scaling will be our "clipping rectangle"
				if (strumTimeDiff > -crotchet - SchmovinAdapter.GetInstance().GrabGlobalVisualOffset() && strumTimeDiff <= 0)
				{
					var scale = 1 - (strumTimeDiff + crotchet) / crotchet;
					strumLineSub *= scale;
					strumLineOffset *= scale;
				}

				var subdivisionProg = sub / (subdivisions + 1);
				var nextSubdivisionProg = (sub + 1) / (subdivisions + 1);

				var calcTopWidth = hold.frameWidth * hold.scale.x;
				var calcBottomWidth = hold.prevNote.isSustainNote ? hold.prevNote.width : hold.width;

				// This lerps between the two widths to make the hold look smooth.
				// No more jaggy 3D holds :')
				var topWidth = FlxMath.lerp(calcTopWidth, calcBottomWidth, subdivisionProg);
				var bottomWidth = FlxMath.lerp(calcTopWidth, calcBottomWidth, nextSubdivisionProg);

				var top = CalculatePointsAlongPathNormal(topWidth, strumTimeDiff + strumLineOffset, SchmovinUtil.GetTotalColumn(hold),
					SchmovinUtil.GetPlayer(hold));
				var bottom = CalculatePointsAlongPathNormal(bottomWidth, strumTimeDiff + strumLineOffset + strumLineSub, SchmovinUtil.GetTotalColumn(hold),
					SchmovinUtil.GetPlayer(hold));
				var topPoints = [new Vector2(top[0].x, top[0].y), new Vector2(top[1].x, top[1].y)];
				var bottomPoints = [new Vector2(bottom[0].x, bottom[0].y), new Vector2(bottom[1].x, bottom[1].y)];

				var alpha = FlxMath.lerp(hold.alpha, hold.prevNote.alpha, subdivisionProg);

				var frame = GrabFrame(hold, alpha);
				if (hold.shader != null)
				{
					hold.shader.bitmap.input = frame;
					hold.shader.hasColorTransform.value = [true];
					bitmap.graphics.beginShaderFill(hold.shader, null);
				}
				else
					bitmap.graphics.beginBitmapFill(frame, null, true, true);
				bitmap.graphics.drawTriangles(new Vector<Float>(12, false, [
					   topPoints[0].x,    topPoints[0].y,
					   topPoints[1].x,    topPoints[1].y,
					bottomPoints[1].x, bottomPoints[1].y,
					   topPoints[0].x,    topPoints[0].y,
					bottomPoints[0].x, bottomPoints[0].y,
					bottomPoints[1].x, bottomPoints[1].y
				]), null, GetUV(hold.flipY, sub, subdivisions));
				bitmap.graphics.endFill();
			}
		}
		// If we drew to a BitmapData, shader effects would be lost in the rasterization
		// It's better to render directly to the camera's buffer
		for (camera in _cameras)
			camera.canvas.graphics.copyFrom(bitmap.graphics);
	}

	function GetUV(flipY:Bool, sub:Int, subdivisions:Int)
	{
		if (!flipY)
			sub = (subdivisions - 1) - sub;
		var uvSub = 1.0 / subdivisions;
		var uvOffset = uvSub * sub;
		if (flipY)
		{
			return new Vector<Float>(12, false, [
				0,         uvOffset,
				1,         uvOffset,
				1, uvOffset + uvSub,
				0,         uvOffset,
				0, uvOffset + uvSub,
				1, uvOffset + uvSub
			]);
		}
		return new Vector<Float>(12, false, [
			0, uvSub + uvOffset,
			1, uvSub + uvOffset,
			1,         uvOffset,
			0, uvSub + uvOffset,
			0,         uvOffset,
			1,         uvOffset
		]);
	}

	public function new(playState:PlayState, cameras:Array<FlxCamera>, timeline:SchmovinTimeline, instance:SchmovinInstance,
			holdConditional:Null<Note->Bool> = null)
	{
		_holdConditional = holdConditional;
		super(playState, cameras, timeline, instance);
		Initialize();
	}
}
