/**
 * @ Author: 4mbr0s3 2
 * @ Create Time: 2021-07-21 18:18:16
 * @ Modified by: 4mbr0s3 2
 * @ Modified time: 2021-12-26 16:16:51
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
		super(primary);
	}

	override function Activate(receptors:Array<Receptor>, notes:Array<Note>)
	{
		_initialX = Application.current.window.x;
		_initialY = Application.current.window.y;
	}

	override function Update(currentBeat:Float) {}
}
