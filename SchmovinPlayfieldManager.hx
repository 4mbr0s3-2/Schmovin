package schmovin;

class SchmovinPlayfieldManager
{
	public var list:Array<SchmovinPlayfield> = [];

	public function new() {}

	public function AddPlayfield(p:SchmovinPlayfield)
	{
		list.push(p);
	}

	public function RemovePlayfield(p:SchmovinPlayfield)
	{
		list.remove(p);
	}

	public function GetPlayfieldAtIndex(i:Int)
	{
		if (i > list.length - 1 || i < 0)
			return list[0];
		return list[i];
	}
}
