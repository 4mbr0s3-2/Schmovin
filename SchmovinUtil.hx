/**
 * @ Author: 4mbr0s3 2
 * @ Create Time: 2021-06-22 16:25:26
 * @ Modified by: 4mbr0s3 2
 * @ Modified time: 2021-11-13 12:35:53
 */

package schmovin;

import flixel.FlxSprite;
import flixel.math.FlxPoint;
import lime.math.Vector4;

// Decorator for receptor to include column data
class Receptor
{
	public var wrappee:FlxSprite;
	public var column:Int;
	public var x(get, set):Float;
	public var y(get, set):Float;
	public var angle(get, set):Float;
	public var scale(get, set):FlxPoint;

	function get_x()
	{
		return wrappee.x;
	}

	function set_x(v:Float)
	{
		return wrappee.x = v;
	}

	function get_y()
	{
		return wrappee.y;
	}

	function set_y(v:Float)
	{
		return wrappee.y = v;
	}

	function get_angle()
	{
		return wrappee.angle;
	}

	function set_angle(v:Float)
	{
		return wrappee.angle = v;
	}

	function get_scale()
	{
		return wrappee.scale;
	}

	function set_scale(v:FlxPoint)
	{
		return wrappee.scale.set(v.x, v.y);
	}

	public function new(receptor:FlxSprite, column:Int)
	{
		this.wrappee = receptor;
		this.column = column;
	}
}

class SchmovinUtil
{
	public static inline function GetTotalColumn(note:Note)
	{
		return note.noteData + GetPlayer(note) * 4;
	}

	public static inline function NoteWidthHalf()
	{
		return Note.swagWidth / 2;
	}

	public static inline function PosNoteWidthHalf()
	{
		return new Vector4(NoteWidthHalf(), NoteWidthHalf());
	}

	public static inline function Vec4NotePosition(note:Note)
	{
		return new Vector4(note.x, note.y).add(SchmovinUtil.PosNoteWidthHalf());
	}

	public static inline function Vec4ReceptorPosition(rec:Receptor)
	{
		return new Vector4(rec.x, rec.y).add(SchmovinUtil.PosNoteWidthHalf());
	}

	public static inline function Vec4Lerp(vec:Vector4, vec2:Vector4, lerp:Float)
	{
		var out1 = vec.clone();
		out1.scaleBy(1 - lerp);
		var out2 = vec2.clone();
		out2.scaleBy(lerp);
		return out1.add(out2);
	}

	public static inline function GetPlayerOfTotalColumn(column:Int)
	{
		return column > 3 ? 1 : 0;
	}

	public static inline function GetReceptor(note:Note, state:PlayState)
	{
		var column = GetTotalColumn(note);
		return new Receptor(state.strumLineNotes.members[column], column);
	}

	public static inline function GetPlayer(note:Note)
	{
		return note.mustPress ? 1 : 0;
	}

	public static inline function GetReceptors(player:Int, state:PlayState):Array<Receptor>
	{
		var receptors = [];
		for (index in 0...state.strumLineNotes.members.length)
		{
			if (GetPlayerOfTotalColumn(index) == player)
			{
				var receptor = state.strumLineNotes.members[index];
				receptors.push(new Receptor(receptor, index));
			}
		}
		return receptors;
	}

	public static inline function GetNotes(player:Int, state:PlayState):Array<Note>
	{
		var notes = [];
		for (index in 0...state.notes.members.length)
		{
			var note = state.notes.members[index];
			if (GetPlayer(note) == player)
				notes.push(note);
		}
		return notes;
	}
}
