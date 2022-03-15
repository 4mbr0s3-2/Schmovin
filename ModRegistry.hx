/**
 * @ Author: 4mbr0s3 2
 * @ Create Time: 2021-07-15 16:25:02
 * @ Modified by: 4mbr0s3 2
 * @ Modified time: 2022-03-14 23:33:00
 */

package schmovin;

import flixel.FlxG;
import schmovin.misc_mods.MiscModCamCopyPosition;
import schmovin.misc_mods.MiscModCamRaymarch;
import schmovin.note_mods.ISchmovinNoteMod;
import schmovin.note_mods.NoteModBase;
import schmovin.note_mods.NoteModBeat;
import schmovin.note_mods.NoteModBlink;
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

	function AddNoteMod(modName:String, mod:ISchmovinNoteMod, aux:Bool = false, parent:String = '')
	{
		_modList.AddNoteMod(modName, mod, aux, parent);
	}

	function AddNoteAuxMod(modName:String, parent:String = '')
	{
		AddNoteMod(modName, new NoteModBase(), true, parent);
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
		AddNoteAuxMod('split', 'reverse');
		AddNoteAuxMod('cross', 'reverse');
		for (i in 0...4)
			AddNoteAuxMod('reverse${i}', 'reverse');
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
			AddNoteAuxMod('confusion${axis}offset', 'confusion');
			for (i in 0...4)
				AddNoteAuxMod('confusion${axis}offset${i}', 'confusion');
		}

		AddNoteMod('confusion', new NoteModConfusion());

		for (i in 0...4)
		{
			AddNoteAuxMod('tiny${i}', 'tiny');
			AddNoteAuxMod('tinyx${i}', 'tiny');
			AddNoteAuxMod('tinyy${i}', 'tiny');
		}
		AddNoteAuxMod('tinyx', 'tiny');
		AddNoteAuxMod('tinyy', 'tiny');
		AddNoteMod('tiny', new NoteModTiny());

		AddNoteMod('bumpy', new NoteModBumpy());

		AddNoteAuxMod('rotatex', 'rotate');
		AddNoteAuxMod('rotatey', 'rotate');
		AddNoteAuxMod('rotatez', 'rotate');
		AddNoteMod('rotate', new NoteModRotate());

		AddNoteAuxMod('centerrotatex', 'centerrotate');
		AddNoteAuxMod('centerrotatey', 'centerrotate');
		AddNoteAuxMod('centerrotatez', 'centerrotate');
		AddNoteMod('centerrotate', new NoteModRotate('centerrotate', new lime.math.Vector4(FlxG.width / 2, FlxG.height / 2)));

		AddNoteAuxMod('xoffset', 'translation');
		AddNoteAuxMod('yoffset', 'translation');
		AddNoteAuxMod('zoffset', 'translation');
		AddNoteAuxMod('y', 'translation');
		AddNoteAuxMod('z', 'translation');
		AddNoteAuxMod('x', 'translation');
		AddNoteMod('translation', new NoteModTranslate());

		AddNoteMod('zigzag', new NoteModZigzag());
		AddNoteMod('square', new NoteModSquare());

		AddNoteMod('gantzgraf', new NoteModGantzGraf());

		AddNoteAuxMod('camgameoverride', 'camgame');
		AddNoteAuxMod('camgameoverridex', 'camgame');
		AddNoteAuxMod('camgameoverridey', 'camgame');
		AddNoteAuxMod('camgamezoom', 'camgame');
		AddNoteAuxMod('camgameangle', 'camgame');
		AddNoteAuxMod('camgamey', 'camgame');
		AddNoteAuxMod('camgamex', 'camgame');
		AddNoteMod('camgame', new MiscModCamCopyPosition(_modList.GetSchmovinInstance().camGameCopy, 0, 'camgame'));

		// Modifying the note camera directly is discouraged (since the scrollFactor for notes and receptors default to 0)
		// Instead, use the note mod transformations.

		AddNoteMod('sine', new NoteModSine());

		AddNoteMod('blink', new NoteModBlink());

		AddNoteAuxMod('camx', 'cam');
		AddNoteAuxMod('camy', 'cam');
		AddNoteAuxMod('camz', 'cam');
		AddNoteAuxMod('campitch', 'cam');
		AddNoteAuxMod('camyaw', 'cam');
		AddNoteAuxMod('camroll', 'cam');
		AddNoteAuxMod('camfov', 'cam');
		AddNoteMod('cam', new NoteModPerspective());

		AddNoteMod('drawdistance', new NoteModBase());
	}
}
