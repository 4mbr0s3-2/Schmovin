/**
 * @ Author: 4mbr0s3 2
 * @ Create Time: 2021-07-15 16:25:02
 * @ Modified by: 4mbr0s3 2
 * @ Modified time: 2022-09-11 22:42:51
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
import schmovin.note_mods.NoteModITGDrunk;
import schmovin.note_mods.NoteModITGTipsy;
import schmovin.note_mods.NoteModNoteRotate;
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
	private var _modList:SchmovinNoteModList;
	private var _state:PlayState;

	public function new(modList:SchmovinNoteModList, state:PlayState)
	{
		_modList = modList;
		_state = state;
	}

	private function addNoteMod(modName:String, mod:ISchmovinNoteMod, aux:Bool = false, parent:String = '')
	{
		_modList.addNoteMod(modName, mod, aux, parent);
	}

	private function addNoteAuxMod(modName:String, parent:String = '')
	{
		addNoteMod(modName, new NoteModBase(), true, parent);
	}

	public function register()
	{
		addNoteAuxMod('xmod');
		addNoteAuxMod('forcexmod');
		for (i in 0...4)
		{
			addNoteAuxMod('xmod${i}');
			addNoteAuxMod('forcexmod${i}');
		}
		addNoteAuxMod('split', 'reverse');
		addNoteAuxMod('cross', 'reverse');
		for (i in 0...4)
			addNoteAuxMod('reverse${i}', 'reverse');
		addNoteMod('reverse', new NoteModReverse());

		addNoteMod('invert', new NoteModInvert());
		addNoteMod('flip', new NoteModFlip());

		addNoteMod('tipsy', new NoteModTipsy());
		addNoteMod('itgtipsy', new NoteModITGTipsy());

		addNoteMod('drunk', new NoteModDrunk());
		addNoteMod('itgdrunk', new NoteModITGDrunk());

		addNoteMod('tornado', new NoteModTornado());

		addNoteMod('beat', new NoteModBeat());

		addNoteAuxMod('arrowpath');
		for (i in 0...4)
			addNoteAuxMod('arrowpath${i}');
		addNoteAuxMod('arrowpathsize');
		for (i in 0...4)
			addNoteAuxMod('arrowpathsize${i}');

		for (axis in ['x', 'y', 'z'])
		{
			addNoteAuxMod('confusion${axis}offset', 'confusion');
			for (i in 0...4)
				addNoteAuxMod('confusion${axis}offset${i}', 'confusion');
		}

		addNoteMod('confusion', new NoteModConfusion());

		for (i in 0...4)
		{
			addNoteAuxMod('tiny${i}', 'tiny');
			addNoteAuxMod('tinyx${i}', 'tiny');
			addNoteAuxMod('tinyy${i}', 'tiny');
		}
		addNoteAuxMod('tinyx', 'tiny');
		addNoteAuxMod('tinyy', 'tiny');
		addNoteMod('tiny', new NoteModTiny());

		addNoteMod('bumpy', new NoteModBumpy());

		addNoteAuxMod('rotatex', 'rotate');
		addNoteAuxMod('rotatey', 'rotate');
		addNoteAuxMod('rotatez', 'rotate');
		addNoteMod('rotate', new NoteModRotate());

		// Used as temporary places to store angles set by other mods
		addNoteAuxMod('othernoterotatex', 'noterotate');
		addNoteAuxMod('othernoterotatey', 'noterotate');
		addNoteAuxMod('othernoterotatez', 'noterotate');

		addNoteAuxMod('noterotatex', 'noterotate');
		addNoteAuxMod('noterotatey', 'noterotate');
		addNoteAuxMod('noterotatez', 'noterotate');
		addNoteMod('noterotate', new NoteModNoteRotate());

		addNoteAuxMod('centerrotatex', 'centerrotate');
		addNoteAuxMod('centerrotatey', 'centerrotate');
		addNoteAuxMod('centerrotatez', 'centerrotate');
		addNoteMod('centerrotate', new NoteModRotate('centerrotate', new lime.math.Vector4(FlxG.width / 2, FlxG.height / 2)));

		addNoteAuxMod('xoffset', 'translation');
		addNoteAuxMod('yoffset', 'translation');
		addNoteAuxMod('zoffset', 'translation');
		addNoteAuxMod('y', 'translation');
		addNoteAuxMod('z', 'translation');
		addNoteAuxMod('x', 'translation');
		addNoteMod('translation', new NoteModTranslate());

		addNoteMod('zigzag', new NoteModZigzag());
		addNoteMod('square', new NoteModSquare());

		addNoteMod('gantzgraf', new NoteModGantzGraf());

		addNoteAuxMod('camgameoverride', 'camgame');
		addNoteAuxMod('camgameoverridex', 'camgame');
		addNoteAuxMod('camgameoverridey', 'camgame');
		addNoteAuxMod('camgamezoom', 'camgame');
		addNoteAuxMod('camgameangle', 'camgame');
		addNoteAuxMod('camgamey', 'camgame');
		addNoteAuxMod('camgamex', 'camgame');
		addNoteMod('camgame', new MiscModCamCopyPosition(cast(_modList.getSchmovinInstance().camGameCopy), 0, 'camgame'));

		// Modifying the note camera directly is discouraged (since the scrollFactor for notes and receptors default to 0)
		// Instead, use the note mod transformations.

		addNoteMod('sine', new NoteModSine());

		addNoteMod('blink', new NoteModBlink());

		addNoteAuxMod('camx', 'cam');
		addNoteAuxMod('camy', 'cam');
		addNoteAuxMod('camz', 'cam');
		addNoteAuxMod('campitch', 'cam');
		addNoteAuxMod('camyaw', 'cam');
		addNoteAuxMod('camroll', 'cam');
		addNoteAuxMod('camfov', 'cam');
		addNoteMod('cam', new NoteModPerspective());

		addNoteMod('drawdistance', new NoteModBase());
	}
}
