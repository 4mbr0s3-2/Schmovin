/**
 * @ Author: 4mbr0s3 2
 * @ Create Time: 2021-07-25 01:14:35
 * @ Modified by: 4mbr0s3 2
 * @ Modified time: 2021-09-23 20:18:14
 */

package schmovin;

import openfl.Lib;
import openfl.desktop.Clipboard;
import schmovin.overlays.SchmovinDebugger;

class SchmovinClientWithDebugger extends SchmovinClient
{
	private var _debugger:SchmovinDebugger;

	override public function new(instance:SchmovinInstance, timeline:SchmovinTimeline, state:PlayState)
	{
		super(instance, timeline, state);
		_debugger = new SchmovinDebugger(this, _timeline);
		Lib.current.addChild(_debugger);
	}

	override function destroy()
	{
		super.destroy();
		_debugger.destroy();
		Lib.current.removeChild(_debugger);
	}

	public function pasteHScriptFromClipboard()
	{
		var cb = null;
		#if html5
		js.Browser.navigator.clipboard.readText().then((d) ->
		{
			cb = d;
			_debugger.parseHScript(cb);
		});
		#else
		var cb = Clipboard.generalClipboard.getData(TEXT_FORMAT, CLONE_PREFERRED);
		_debugger.parseHScript(cb);
		#end
	}
}
