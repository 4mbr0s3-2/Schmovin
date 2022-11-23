/**
 * @ Author: 4mbr0s3 2
 * @ Create Time: 2021-06-22 16:25:26
 * @ Modified by: 4mbr0s3 2
 * @ Modified time: 2021-11-30 22:33:55
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
	public var visible(get, set):Bool;

	private function get_x()
	{
		return wrappee.x;
	}

	private function set_x(v:Float)
	{
		return wrappee.x = v;
	}

	private function get_y()
	{
		return wrappee.y;
	}

	private function set_y(v:Float)
	{
		return wrappee.y = v;
	}

	private function get_angle()
	{
		return wrappee.angle;
	}

	private function set_angle(v:Float)
	{
		return wrappee.angle = v;
	}

	private function set_visible(v:Bool)
	{
		return wrappee.visible = v;
	}

	private function get_visible()
	{
		return wrappee.visible;
	}

	private function get_scale()
	{
		return wrappee.scale;
	}

	private function set_scale(v:FlxPoint)
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
	public static inline function getTotalColumn(note:Note)
	{
		return note.noteData + getPlayer(note) * 4;
	}

	public static inline function getNoteWidthHalf()
	{
		return Note.swagWidth / 2;
	}

	public static inline function posGetNoteWidthHalf()
	{
		return new Vector4(getNoteWidthHalf(), getNoteWidthHalf());
	}

	public static inline function getVec4NotePosition(note:Note)
	{
		return new Vector4(note.x, note.y).add(SchmovinUtil.posGetNoteWidthHalf());
	}

	public static inline function getVec4ReceptorPosition(rec:Receptor)
	{
		return new Vector4(rec.x, rec.y).add(SchmovinUtil.posGetNoteWidthHalf());
	}

	public static inline function vec4Lerp(vec:Vector4, vec2:Vector4, lerp:Float)
	{
		var out1 = vec.clone();
		out1.scaleBy(1 - lerp);
		var out2 = vec2.clone();
		out2.scaleBy(lerp);
		return out1.add(out2);
	}

	public static inline function getPlayerOfTotalColumn(column:Int)
	{
		return column > 3 ? 1 : 0;
	}

	public static inline function getReceptor(note:Note, state:PlayState)
	{
		var column = getTotalColumn(note);
		return new Receptor(state.strumLineNotes.members[column], column);
	}

	public static inline function getPlayer(note:Note)
	{
		return note.mustPress ? 1 : 0;
	}

	public static inline function getReceptors(player:Int, state:PlayState):Array<Receptor>
	{
		var receptors = [];
		for (index in 0...state.strumLineNotes.members.length)
		{
			if (getPlayerOfTotalColumn(index) == player)
			{
				var receptor = state.strumLineNotes.members[index];
				receptors.push(new Receptor(receptor, index));
			}
		}
		return receptors;
	}

	public static inline function getNotes(player:Int, state:PlayState):Array<Note>
	{
		var notes = [];
		for (index in 0...state.notes.members.length)
		{
			var note = state.notes.members[index];
			if (getPlayer(note) == player)
				notes.push(note);
		}
		return notes;
	}
}
