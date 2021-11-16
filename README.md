<p align="center">
  <img src="https://github.com/4mbr0s3-2/Schmovin/blob/main/SchmovinLogo.png?raw=true" alt="Schmovin' Logo"/>
</p>

# Schmovin' (Groovin' Mod Framework Modchart Engine)
This repository is meant to be a Git submodule for Groovin' Mod Framework, but it can also be used in other engines! (Just make sure to credit.)

### Credits

[4mbr0s3 2](https://www.youtube.com/channel/UCez-Erpr0oqmC71vnDrM9yA) - Made the code and did the note modifier math

[TaroNuke](https://twitter.com/TaroNuke) - Inspiration; really cool rhythm game developer who made [NotITG](https://notitg.heysora.net/)

Roxor Games, Inc. - In the Groove 2 creators who introduced more [arrow modifiers](http://manual.pocitac.com/en/modifiers.html) and mines to Dance Dance Revolution

[Nebula The Zorua](https://twitter.com/Nebula_Zorua) - Basically recreated Schmovin' in [their own FNF engine](https://github.com/nebulazorua/andromeda-engine/blob/e6686c04ccebada08d8574e1c46b6188738debb2/source/modchart/modifiers/PerspectiveModifier.hx) before the source code was even released (kinda epic)

### The Gist
There's a class called `SchmovinClient`. Subclasses of it should contain all the actual modchart implementation. 
To load in a modchart, pass an instance of a subclass of `SchmovinClient` into `SchmovinInstance` with `SetClient(cli:SchmovinClient)`.

### "Porting" to Other Engines
Since Groovin' Mod Framework decouples mod code into separate submodules (like this whole repository), you can easily use it in other engines by instantiating the base class as a singleton (in this case, `Schmovin`) and calling its methods in the base game's code. This requires a bit more work than just using Groovin' since it also involves removing  Groovin' dependencies, but if you're looking at this repository instead of the Groovin' repository, you probably know what you're doing anyway.  

### Plugging in the Modchart (client)
In `SchmovinInstance`, you'll see a method that sends a "cross mod call" to all other loaded Groovin' mods.
The mod that actually implements the modchart calls the `SetClient(cli:SchmovinClient)` method in the `SchmovinInstance` parameter.

In your main mod class, which should be loaded *after* Schmovin', use the following code as a base to instantiate the `SchmovinClient`.
```haxe
override function ReceiveCrossModCall(command:String, sender:Mod, args:Array<Dynamic>)
{
    // Here, you'd actually check the song and pass in the respective modchart
    // If the number of songs with modcharts gets too unwieldy and this code gets too long,
    // use a switch case or a map or some other collection thing 
    if (PlayState.SONG.song == 'false-paradise' && ShouldRun())
    {
        switch (command)
        {
            case 'SchmovinSetClient':
                var instance:SchmovinInstance = cast args[0];
                var cli = new FalseParadiseSchmovinClient(instance, args[1], args[2]);
                instance.SetClient(cli);
                
                // Optional if you want to use debug tools
                // SendCrossModCall('SchmovinPrepareDebug', [cli]);
        }
    }
}
```

If you're *not* using Groovin' and are using a version of Schmovin' in another engine, you can just pass the client in after `SchmovinInstance` is instantiated... They'll probably have their own way of doing that.

### Making the Modchart
In your `SchmovinClient` subclass, override `Initialize()` and define every event there.
Add events to the `SchmovinTimeline` by using the ease, set, function, and tween methods defined in the superclass.
For the ease functions, use `FlxEase`.

You can also make some cooler custom-defined stuff by overriding the `Update()` class.
For the list of note mods at your disposal, look in the `Registry` class.

### Making a Really Cool-Looking Note Mod (WIP)
i'll probably make a video for this but if you're starting out, basically
1. look at the code for each note mod in `/note_mods` (except `NoteModReverse` which defines the original game layout)
2. copy paste them to a new class that subclasses `NoteModBase` and do some math to the passed note position that uses `strumTime` and `Conductor.songPosition`
3. add as a custom note mod in `SchmovinClient` instance with `_timeline.GetModList().addNoteMod('notemodcustomthingy', new NoteModCustomThingy(_state, _timeline.GetModList()))` (optimize where you find necessary)
4. ???
6. profit

if a note mod doesn't work, it probably is being overridden by another note mod so just make sure of the note mod order
