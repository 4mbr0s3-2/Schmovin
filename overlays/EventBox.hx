/**
 * @ Author: 4mbr0s3 2
 * @ Create Time: 2021-08-14 23:42:43
 * @ Modified by: 4mbr0s3 2
 * @ Modified time: 2021-11-13 11:09:37
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

	public function update(args:Dynamic)
	{
		var zoomX = args[0];
		var zoomY = args[1];
		var currentBeat = SchmovinAdapter.getInstance().getSongPosition() / Conductor.crochet;
		x = zoomX * (_event.getBeat() - currentBeat);
		y = zoomY * _row + _marginTop;
		width = zoomX * _event.getBeatLength();
		height = zoomY;
	}
}
