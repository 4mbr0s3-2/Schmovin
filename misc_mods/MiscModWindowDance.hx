/**
 * @ Author: 4mbr0s3 2
 * @ Create Time: 2021-07-21 18:18:16
 * @ Modified by: 4mbr0s3 2
 * @ Modified time: 2022-03-19 20:58:12
 */

package schmovin.misc_mods;

import lime.app.Application;
import schmovin.SchmovinUtil.Receptor;
import schmovin.misc_mods.MiscModBase;

class MiscModWindowDance extends MiscModBase
{
	private var _initialX = 0.0;
	private var _initialY = 0.0;

	public function new(primary:Bool = false, prefix:String = 'windowdance')
	{
		super();
	}

	override function activate(receptors:Array<Receptor>, notes:Array<Note>)
	{
		_initialX = Application.current.window.x;
		_initialY = Application.current.window.y;
	}

	override function update(currentBeat:Float) {}
}
