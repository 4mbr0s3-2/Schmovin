/**
 * @ Author: 4mbr0s3 2
 * @ Create Time: 2021-08-15 01:00:48
 * @ Modified by: 4mbr0s3 2
 * @ Modified time: 2021-12-01 00:08:54
 */

package schmovin.overlays;

import openfl.text.TextField;
import openfl.text.TextFormat;
import schmovin.SchmovinTimeline;
import schmovin.note_mods.ISchmovinNoteMod;

class ModLabel extends TextField implements IUpdateable
{
	private var _noteMod:ISchmovinNoteMod;
	private var _mod:String;

	public var row:Int = 0;

	private var _margin = 10;

	public function update(args:Dynamic)
	{
		if (_noteMod == null)
			return;
		text = '${_mod}: ${_noteMod.getLegacyPercent(0)}, ${_noteMod.getLegacyPercent(1)}';
		x = _margin;
		y = row * args[1];
	}

	public function new(mod:String, noteMod:ISchmovinNoteMod)
	{
		super();
		textColor = 0xFFFFFF;
		defaultTextFormat = new TextFormat(null, 20, 0xFFFFFF);
		width = 400;
		_mod = mod;
		_noteMod = noteMod;
	}
}
