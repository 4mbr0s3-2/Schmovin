package schmovin;

import haxe.Exception;

class SchmovinPlayfield
{
	public var name:String;
	public var player:Int;
	public var mods:Map<String, Float>;

	public function GetPercent(modName:String):Float
	{
		var v = mods.get(modName);
		if (v != null)
			return v;
		return 0.0;
	}

	public function SetPercent(modName:String, f:Float)
	{
		try
		{
			mods[modName] = f;
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
