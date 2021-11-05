/**
 * @ Author: 4mbr0s3 2
 * @ Create Time: 2021-07-21 18:24:47
 * @ Modified by: 4mbr0s3 2
 * @ Modified time: 2021-08-29 15:09:14
 */

package schmovin.misc_mods;

import schmovin.note_mods.NoteModBase;

class MiscModBase extends NoteModBase
{
	override function IsPrimaryMod():Bool
	{
		return false;
	}

	override function ShouldDoUpdate():Bool
	{
		return true;
	}
}
