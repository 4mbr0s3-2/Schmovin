package schmovin;

import haxe.Exception;

class SchmovinPlayfield
{
	public var name:String;
	public var player:Int;
	public var mods:Map<String, Float>;
	public var activeMods:Array<String> = [];

	public function CheckActiveMod(modName:String)
	{
		return activeMods.contains(modName);
	}

	public function GetPercent(modName:String):Float
	{
		try
		{
			var v = mods[modName];
			return v;
		}
		catch (e)
		{
			return 0.0;
		}
		return 0.0;
	}

	public function SetPercent(modName:String, f:Float)
	{
		try
		{
			mods[modName] = f;
			if (f != 0 && !activeMods.contains(modName))
				activeMods.push(modName);
			else if (f == 0)
				activeMods.remove(modName);
		}
		catch (e)
		{
			throw new Exception('No mod ${modName} found!');
		}
	}

	public function new(name:String = '', player:Int = -1)
	{
		this.name = name;
		this.player = player;
		this.mods = new Map<String, Float>();
	}
}
