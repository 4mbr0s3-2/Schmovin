package schmovin;

/**
 * This class is important for defining some implementation that other engines may override for Schmovin'.
 * It decouples code from Groovin' and Groovin' Input.
 * Subclass this class and implement each function, then pass an instance of the subclass with SetInstance().
 */
class SchmovinAdapter
{
	public function new() {}

	static var _adapterInstance:SchmovinAdapter;

	public static function GetInstance()
	{
		return _adapterInstance;
	}

	public function GetDefaultNoteX(column:Int, player:Int)
	{
		return 0.0;
	}

	public static function SetInstance(a:SchmovinAdapter)
	{
		_adapterInstance = a;
	}

	public function GetSongPosition()
	{
		// return Conductor.songPosition;
		return 0.0;
	}

	// This accounts for custom notes with custom textures
	public function ShouldCacheNoteBitmap(note:Note)
	{
		return true;
	}

	public function GrabScrollSpeed()
	{
		// return PlayState.SONG;
		return 1.0;
	}

	public function GetCrotchetNow()
	{
		// return Conductor.crochet;
		return 500.0;
	}

	// For use by Groovin', no need to add anything here if used by other engines
	public function ForEveryMod(param:Array<Dynamic>) {}

	public function Log(string:Dynamic)
	{
		trace('[Schmovin\'] ${string}');
	}

	public function GrabGlobalVisualOffset()
	{
		return 0.0;
	}

	public function GrabReverse()
	{
		return false;
	}

	public function GetCrotchetAtTime(time:Float)
	{
		return 2.0;
	}

	public function GetCurrentBeat()
	{
		return GetSongPosition() / GetCrotchetNow();
	}

	public function GetHoldNoteSubdivisions()
	{
		return 4;
	}

	public function GetArrowPathSubdivisions()
	{
		return 80;
	}

	public function GetOptimizeHoldNotes()
	{
		#if desktop
		return true;
		#else
		return false;
		#end
	}
}
