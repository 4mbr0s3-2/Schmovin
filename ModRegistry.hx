/**
 * @ Author: 4mbr0s3 2
 * @ Create Time: 2021-07-15 16:25:02
 * @ Modified by: 4mbr0s3 2
 * @ Modified time: 2022-02-10 21:58:28
 */

package schmovin;

import flixel.FlxG;
import schmovin.misc_mods.MiscModCamCopyPosition;
import schmovin.misc_mods.MiscModCamRaymarch;
import schmovin.note_mods.ISchmovinNoteMod;
import schmovin.note_mods.NoteModBase;
import schmovin.note_mods.NoteModBeat;
import schmovin.note_mods.NoteModBumpy;
import schmovin.note_mods.NoteModColumnSwaps;
import schmovin.note_mods.NoteModConfusion;
import schmovin.note_mods.NoteModDrunk;
import schmovin.note_mods.NoteModGantzGraf;
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

class ModRegistry
{
	var _modList:SchmovinNoteModList;
	var _state:PlayState;

	public function new(modList:SchmovinNoteModList, state:PlayState)
	{
		_modList = modList;
		_state = state;
	}

	function AddNoteMod(modName:String, mod:ISchmovinNoteMod, aux:Bool = false)
	{
		_modList.AddNoteMod(modName, mod, aux);
	}

	function AddNoteAuxMod(modName:String)
	{
		AddNoteMod(modName, new NoteModBase(), true);
	}

	public function Register()
	{
		AddNoteAuxMod('xmod');
		AddNoteAuxMod('forcexmod');
		for (i in 0...4)
		{
			AddNoteAuxMod('xmod${i}');
			AddNoteAuxMod('forcexmod${i}');
		}
		AddNoteAuxMod('split');
		AddNoteAuxMod('cross');
		for (i in 0...4)
			AddNoteAuxMod('reverse${i}');
		AddNoteMod('reverse', new NoteModReverse());

		AddNoteMod('invert', new NoteModInvert());
		AddNoteMod('flip', new NoteModFlip());

		AddNoteMod('tipsy', new NoteModTipsy());

		AddNoteMod('drunk', new NoteModDrunk());

		AddNoteMod('tornado', new NoteModTornado());

		AddNoteMod('beat', new NoteModBeat());

		AddNoteAuxMod('arrowpath');
		for (i in 0...4)
			AddNoteAuxMod('arrowpath${i}');
		AddNoteAuxMod('arrowpathsize');
		for (i in 0...4)
			AddNoteAuxMod('arrowpathsize${i}');

		for (axis in ['x', 'y', 'z'])
		{
			AddNoteAuxMod('confusion${axis}offset');
			for (i in 0...4)
				AddNoteAuxMod('confusion${axis}offset${i}');
		}

		AddNoteMod('confusion', new NoteModConfusion());

		for (i in 0...4)
		{
			AddNoteAuxMod('tiny${i}');
			AddNoteAuxMod('tinyx${i}');
			AddNoteAuxMod('tinyy${i}');
		}
		AddNoteAuxMod('tinyx');
		AddNoteAuxMod('tinyy');
		AddNoteMod('tiny', new NoteModTiny());

		AddNoteMod('bumpy', new NoteModBumpy());

		AddNoteAuxMod('rotatex');
		AddNoteAuxMod('rotatey');
		AddNoteMod('rotatez', new NoteModRotate());

		AddNoteAuxMod('centerrotatex');
		AddNoteAuxMod('centerrotatey');
		AddNoteMod('centerrotatez', new NoteModRotate('centerrotate', new lime.math.Vector4(FlxG.width / 2, FlxG.height / 2)));

		AddNoteAuxMod('xoffset');
		AddNoteAuxMod('yoffset');
		AddNoteAuxMod('zoffset');
		AddNoteAuxMod('y');
		AddNoteAuxMod('z');
		AddNoteMod('x', new NoteModTranslate());

		AddNoteMod('zigzag', new NoteModZigzag());
		AddNoteMod('square', new NoteModSquare());

		AddNoteMod('gantzgraf', new NoteModGantzGraf());

		AddNoteAuxMod('camgameoverride');
		AddNoteAuxMod('camgameoverridex');
		AddNoteAuxMod('camgameoverridey');
		AddNoteAuxMod('camgamezoom');
		AddNoteAuxMod('camgameangle');
		AddNoteAuxMod('camgamey');
		AddNoteMod('camgamex', new MiscModCamCopyPosition(_modList.GetSchmovinInstance().camGameCopy, 0, 'camgame'));

		// Modifying the note camera directly is discouraged (since the scrollFactor for notes and receptors default to 0)
		// Instead, use the note mod transformations.

		AddNoteAuxMod('camnotesrmpitch');
		AddNoteAuxMod('camnotesrmyaw');
		AddNoteAuxMod('camnotesrmx');
		AddNoteAuxMod('camnotesrmy');
		AddNoteAuxMod('camnotesrmz');
		AddNoteAuxMod('camnotesrmlookatx');
		AddNoteAuxMod('camnotesrmlookaty');
		AddNoteAuxMod('camnotesrmlookatz');
		AddNoteMod('camnotesrm', new MiscModCamRaymarch(_modList.GetSchmovinInstance().camNotes, 0));

		AddNoteAuxMod('camgamermpitch');
		AddNoteAuxMod('camgamermyaw');
		AddNoteAuxMod('camgamermx');
		AddNoteAuxMod('camgamermy');
		AddNoteAuxMod('camgamermz');
		AddNoteAuxMod('camgamermlookatx');
		AddNoteAuxMod('camgamermlookaty');
		AddNoteAuxMod('camgamermlookatz');
		AddNoteMod('camgamerm', new MiscModCamRaymarch(_modList.GetSchmovinInstance().camGameCopy, 0, 'camgamerm'));

		AddNoteMod('sine', new NoteModSine());

		AddNoteMod('perspective', new NoteModPerspective());

		AddNoteMod('drawdistance', new NoteModBase());
	}
}
