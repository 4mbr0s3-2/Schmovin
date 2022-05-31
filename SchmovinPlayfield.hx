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

	public function CheckActiveMod(modName:String)
	{
		return activeMods.contains(modName);
	}

	public function GetPercent(modName:String):Float
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

	function Sort()
	{
		activeMods.sort((a, b) ->
		{
			return _modList.GetModIndex(a) > _modList.GetModIndex(b) ? 1 : -1;
		});
	}

	public function SetPercent(modName:String, f:Float)
	{
		try
		{
			mods[modName] = f;
			if (f != 0 && !activeMods.contains(modName))
			{
				var mod = _modList.GetModByName(modName);
				var parent = mod.GetParent();
				if (parent != '' && !activeMods.contains(parent))
					activeMods.push(parent);
				else if (parent == '')
					activeMods.push(modName);
				Sort();
			}
			else if (f == 0)
			{
				var parent = _modList.GetModByName(modName).GetParent();
				activeMods.remove(modName);
				for (mod in activeMods)
				{
					if (_modList.GetModByName(mod).GetParent() == parent)
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
	}
}
