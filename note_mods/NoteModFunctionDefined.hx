package schmovin.note_mods;

class NoteModFunctionDefined extends NoteModBase
{
	private var _func:(ISchmovinNoteMod, Float, SchmovinPlayfield) -> Void;

	public function new(func:(ISchmovinNoteMod, Float, SchmovinPlayfield) -> Void)
	{
		_func = func;
		super();
	}

	override function onSetPercent(f:Float, playfield:SchmovinPlayfield)
	{
		_func(this, f, playfield);
	}
}
