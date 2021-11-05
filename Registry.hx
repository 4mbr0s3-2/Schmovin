/**
 * @ Author: 4mbr0s3 2
 * @ Create Time: 2021-07-15 16:25:02
 * @ Modified by: 4mbr0s3 2
 * @ Modified time: 2021-11-02 18:29:03
 */

package schmovin;

import flixel.FlxG;
import schmovin.misc_mods.MiscModCamCopyPosition;
import schmovin.misc_mods.MiscModCamRaymarch;
import schmovin.note_mods.ISchmovinNoteMod;
import schmovin.note_mods.NoteModBeat;
import schmovin.note_mods.NoteModColumnSwaps;
import schmovin.note_mods.NoteModConfusion;
import schmovin.note_mods.NoteModDrunk;
import schmovin.note_mods.NoteModPerspective;
import schmovin.note_mods.NoteModReverse;
import schmovin.note_mods.NoteModRotate;
import schmovin.note_mods.NoteModSine;
import schmovin.note_mods.NoteModSquare;
import schmovin.note_mods.NoteModTiny;
import schmovin.note_mods.NoteModTipsy;
import schmovin.note_mods.NoteModTornado;
import schmovin.note_mods.NoteModTranslate;
import schmovin.note_mods.NoteModZigzag;

class Registry
{
	var _modList:SchmovinNoteModList;
	var _state:PlayState;

	public function new(modList:SchmovinNoteModList, state:PlayState)
	{
		_modList = modList;
		_state = state;
	}

	function AddNoteMod(modName:String, mod:ISchmovinNoteMod, putInOrderedList:Bool = true)
	{
		_modList.AddNoteMod(modName, mod, putInOrderedList);
	}

	function AddNoteSubMod(modName:String)
	{
		_modList.AddNoteSubMod(modName);
	}

	public function Register()
	{
		AddNoteSubMod('xmod');
		AddNoteSubMod('forcexmod');
		for (i in 0...4)
		{
			AddNoteSubMod('xmod${i}');
			AddNoteSubMod('forcexmod${i}');
		}
		AddNoteSubMod('split');
		AddNoteSubMod('cross');
		for (i in 0...4)
			AddNoteSubMod('reverse${i}');
		AddNoteMod('reverse', new NoteModReverse(_state, _modList));

		AddNoteMod('invert', new NoteModInvert(_state, _modList));
		AddNoteMod('flip', new NoteModFlip(_state, _modList));

		AddNoteMod('tipsy', new NoteModTipsy(_state, _modList));

		AddNoteMod('drunk', new NoteModDrunk(_state, _modList));

		AddNoteMod('tornado', new NoteModTornado(_state, _modList));

		AddNoteMod('beat', new NoteModBeat(_state, _modList));

		AddNoteSubMod('arrowpath');
		for (i in 0...4)
			AddNoteSubMod('arrowpath${i}');
		AddNoteSubMod('arrowpathsize');
		for (i in 0...4)
			AddNoteSubMod('arrowpathsize${i}');

		AddNoteSubMod('confusionzoffset');
		for (i in 0...4)
			AddNoteSubMod('confusionzoffset${i}');
		AddNoteMod('confusion', new NoteModConfusion(_state, _modList));

		for (i in 0...4)
		{
			AddNoteSubMod('tiny${i}');
			AddNoteSubMod('tinyx${i}');
			AddNoteSubMod('tinyy${i}');
		}
		AddNoteSubMod('tinyx');
		AddNoteSubMod('tinyy');
		AddNoteMod('tiny', new NoteModTiny(_state, _modList));

		AddNoteSubMod('rotatex');
		AddNoteSubMod('rotatey');
		AddNoteMod('rotatez', new NoteModRotate(_state, _modList));

		AddNoteSubMod('centerrotatex');
		AddNoteSubMod('centerrotatey');
		AddNoteMod('centerrotatez', new NoteModRotate(_state, _modList, true, 'centerrotate', new lime.math.Vector4(FlxG.width / 2, FlxG.height / 2)));

		AddNoteSubMod('xoffset');
		AddNoteSubMod('yoffset');
		AddNoteSubMod('zoffset');
		AddNoteSubMod('y');
		AddNoteSubMod('z');
		AddNoteMod('x', new NoteModTranslate(_state, _modList));

		AddNoteMod('zigzag', new NoteModZigzag(_state, _modList));
		AddNoteMod('square', new NoteModSquare(_state, _modList));

		AddNoteSubMod('camgameoverride');
		AddNoteSubMod('camgameoverridex');
		AddNoteSubMod('camgameoverridey');
		AddNoteSubMod('camgamezoom');
		AddNoteSubMod('camgameangle');
		AddNoteSubMod('camgamey');
		AddNoteMod('camgamex', new MiscModCamCopyPosition(_state, _modList, false, _modList.GetSchmovinInstance().camGameCopy, 0, 'camgame'));

		// Modifying the note camera directly is discouraged (since the scrollFactor for notes and receptors default to 0)
		// Instead, use the note mod transformations.

		AddNoteSubMod('camnotesrmpitch');
		AddNoteSubMod('camnotesrmyaw');
		AddNoteSubMod('camnotesrmx');
		AddNoteSubMod('camnotesrmy');
		AddNoteSubMod('camnotesrmz');
		AddNoteSubMod('camnotesrmlookatx');
		AddNoteSubMod('camnotesrmlookaty');
		AddNoteSubMod('camnotesrmlookatz');
		AddNoteMod('camnotesrm', new MiscModCamRaymarch(_state, _modList, false, _modList.GetSchmovinInstance().camNotes, 0));

		AddNoteSubMod('camgamermpitch');
		AddNoteSubMod('camgamermyaw');
		AddNoteSubMod('camgamermx');
		AddNoteSubMod('camgamermy');
		AddNoteSubMod('camgamermz');
		AddNoteSubMod('camgamermlookatx');
		AddNoteSubMod('camgamermlookaty');
		AddNoteSubMod('camgamermlookatz');
		AddNoteMod('camgamerm', new MiscModCamRaymarch(_state, _modList, false, _modList.GetSchmovinInstance().camGameCopy, 0, 'camgamerm'));

		AddNoteMod('sine', new NoteModSine(_state, _modList));
		// These mods are not automatically put in the call order array. They can be added manually to the array by the client.
		AddNoteMod('perspective', new NoteModPerspective(_state, _modList));
	}
}
