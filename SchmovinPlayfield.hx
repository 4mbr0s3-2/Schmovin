package schmovin;

import flixel.FlxCamera;
import haxe.Exception;

class SchmovinPlayfield
{
	private var _modList:SchmovinNoteModList;

	public var name:String;
	public var player:Int;
	public var mods:Map<String, Float>;
	public var activeMods:Array<String> = [];
	public var cameras:Array<FlxCamera>;

	public function checkActiveMod(modName:String)
	{
		return activeMods.contains(modName);
	}

	public function getPercent(modName:String):Float
	{
		try
		{
			var v = mods[modName];
			if (v == null)
				return 0.0;
			return v;
		}
		catch (e)
		{
			return 0.0;
		}
		return 0.0;
	}

	private function Sort()
	{
		activeMods.sort((a, b) ->
		{
			return _modList.getModIndex(a) > _modList.getModIndex(b) ? 1 : -1;
		});
	}

	public function setPercent(modName:String, f:Float)
	{
		try
		{
			mods[modName] = f;
			var mod = _modList.getModFromName(modName);
			var parent = mod.getParent();
			mod.onSetPercent(f, this);
			if (f != 0 && !activeMods.contains(modName))
			{
				if (parent != '' && !activeMods.contains(parent))
					activeMods.push(parent);
				else if (parent == '')
					activeMods.push(modName);
				Sort();
			}
			else if (f == 0 && !_modList.GetMustExecuteMods().contains(modName))
			{
				activeMods.remove(modName);
				for (mod in activeMods)
				{
					if (_modList.getModFromName(mod).getParent() == parent)
					{
						Sort();
						return;
					}
				}
				activeMods.remove(parent);
				Sort();
			}
		}
		catch (e)
		{
			throw new Exception('No mod ${modName} found!');
		}
	}

	public function new(name:String = '', player:Int = -1, modList:SchmovinNoteModList, cameras:Array<FlxCamera> = null)
	{
		this.name = name;
		this.player = player;
		this.mods = new Map<String, Float>();
		this._modList = modList;
		this.cameras = cameras;
		activeMods = _modList.GetMustExecuteMods();
	}
}
