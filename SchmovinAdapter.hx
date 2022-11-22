package schmovin;

/**
 * This class is important for defining some implementation that other engines may override for Schmovin'.
 * It decouples code from Groovin' and Groovin' Input.
 * Subclass this class and implement each function, then pass an instance of the subclass with setInstance().
 */
class SchmovinAdapter
{
	public function new() {}

	static var _adapterInstance:SchmovinAdapter;

	public static function getInstance()
	{
		return _adapterInstance;
	}

	public function getDefaultNoteX(column:Int, player:Int)
	{
		return 0.0;
	}

	public static function setInstance(a:SchmovinAdapter)
	{
		_adapterInstance = a;
	}

	public function getSongPosition()
	{
		// return Conductor.songPosition;
		return 0.0;
	}

	// This accounts for custom notes with custom textures
	public function shouldCacheNoteBitmap(note:Note)
	{
		return true;
	}

	public function grabScrollSpeed()
	{
		// return PlayState.SONG;
		return 1.0;
	}

	public function getCrotchetNow()
	{
		// return Conductor.crochet;
		return 500.0;
	}

	// For use by Groovin', no need to add anything here if used by other engines
	public function forEveryMod(param:Array<Dynamic>) {}

	public function log(string:Dynamic)
	{
		trace('[Schmovin\'] ${string}');
	}

	public function grabGlobalVisualOffset()
	{
		return 0.0;
	}

	public function grabReverse()
	{
		return false;
	}

	public function getCrotchetAtTime(time:Float)
	{
		return 2.0;
	}

	public function getCurrentBeat()
	{
		return getSongPosition() / getCrotchetNow();
	}

	public function getHoldNoteSubdivisions()
	{
		return 4;
	}

	public function getArrowPathSubdivisions()
	{
		return 80;
	}

	public function getOptimizeHoldNotes()
	{
		#if desktop
		return true;
		#else
		return false;
		#end
	}
}
