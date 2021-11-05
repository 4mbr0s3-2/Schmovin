/**
 * @ Author: 4mbr0s3 2
 * @ Create Time: 2021-08-14 23:42:43
 * @ Modified by: 4mbr0s3 2
 * @ Modified time: 2021-08-29 15:08:19
 */

package schmovin.overlays;

import openfl.display.GradientType;
import openfl.display.Shape;
import schmovin.SchmovinEvent.ISchmovinEvent;

class EventBox extends Shape implements IUpdateable
{
	private var _event:ISchmovinEvent;
	private var _row:Int;
	private var _marginTop = 3;

	public function new(row:Int, event:ISchmovinEvent)
	{
		super();
		_event = event;
		_row = row;
		graphics.beginGradientFill(GradientType.LINEAR, [0xFFFFFF, 0x000000], [0, 0], [127, 127]);
		graphics.drawRect(48, 0, 2, 50);
		graphics.endFill();
	}

	public function Update(args:Dynamic)
	{
		var zoomX = args[0];
		var zoomY = args[1];
		var currentBeat = Conductor.songPosition / Conductor.crochet;
		x = zoomX * (_event.GetBeat() - currentBeat);
		y = zoomY * _row + _marginTop;
		width = zoomX * _event.GetBeatLength();
		height = zoomY;
	}
}
