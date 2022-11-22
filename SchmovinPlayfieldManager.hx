package schmovin;

class SchmovinPlayfieldManager
{
	public var list:Array<SchmovinPlayfield> = [];

	public function new() {}

	public function addPlayfield(p:SchmovinPlayfield)
	{
		list.push(p);
	}

	public function removePlayfield(p:SchmovinPlayfield)
	{
		list.remove(p);
	}

	public function getPlayfieldAtIndex(i:Int)
	{
		if (i > list.length - 1 || i < 0)
			return list[0];
		return list[i];
	}
}
