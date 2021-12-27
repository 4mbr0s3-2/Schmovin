<p align="center">
  <img src="https://github.com/4mbr0s3-2/Schmovin/blob/main/SchmovinLogo.png?raw=true" alt="Schmovin' Logo"/>
</p>

# Schmovin' ([FNF](https://github.com/ninjamuffin99/Funkin) Modchart Engine)
<h2 align="center">"<a href="https://notitg.heysora.net/">NotITG</a> Gateway Drug"</p>

## Note: Keep the code private until the documentation is done and the tutorial video is ready!

Schmovin' is basically an attempt at recreating (not porting) some features of NotITG in Friday Night Funkin'.
This project was just meant to be a way to learn HaxeFlixel and OpenFL... but it kind of grew out of proportion.

This repository is also meant to be a Git submodule for Groovin' Mod Framework, but it can also be used in other engines! (Just make sure to credit.)

### Credits

[4mbr0s3 2](https://www.youtube.com/channel/UCez-Erpr0oqmC71vnDrM9yA) - Did the code and the note mod math

[XeroOl](https://www.youtube.com/c/XeroOl) - Created [Mirin Template](https://xerool.github.io/notitg-mirin/), which this engine is mostly based on

[TaroNuke](https://twitter.com/TaroNuke) - Inspiration; really cool rhythm game developer who pioneered [NotITG](https://notitg.heysora.net/)

Roxor Games, Inc. - In the Groove 2 creators who introduced more [arrow modifiers](http://manual.pocitac.com/en/modifiers.html) and mines to Dance Dance Revolution

### Shoutouts

[Nebula The Zorua](https://twitter.com/Nebula_Zorua) - Recreated Schmovin' in [their own FNF engine](https://github.com/nebulazorua/andromeda-engine/blob/e6686c04ccebada08d8574e1c46b6188738debb2/source/modchart/modifiers/PerspectiveModifier.hx) before the source code was even released (very impressive)

[gedehari/sqirra-rng](https://twitter.com/gedehari) - Very epic

[Aikoyori](https://twitter.com/Aikoyori) - Some bugtesting, first person to actually use Schmovin' in a personal mod

[haya3218](https://github.com/haya3218) - Did a more proper Psych Engine implementation of Schmovin'

[Shadowfi1385](https://twitter.com/Shadowfi1385) - Very epic

### Q&A
Q: Why recreate NotITG in FNF? Wouldn't it be better to just use NotITG due to its better performance and features?

A: Yes.

Q: Isn't it concerning that this might bring a more young and naive audience to the NotITG community?

A: ...No? Modcharts will probably be more appealing to people who are already well-versed with rhythm games anyway.

Q: Why can't the Funkin' Team just hire you guys at this point?

A: what

Q: How do you even play modfiles/modcharts? Are NotITG players even sane?

A: Practice makes perfect. It can take years to get good, and some people have been playing these kinds of files for more than a decade... Can you believe it?

### The Gist
There's a class called `SchmovinClient`. Subclasses of it should contain all the actual modchart implementation. 
To load in a modchart, pass an instance of a subclass of `SchmovinClient` into `SchmovinInstance` with `SetClient(cli:SchmovinClient)`.

### "Porting" to Other Engines
Since Groovin' Mod Framework decouples mod code into separate submodules (like this whole repository), you can easily use it in other engines by instantiating the base class as a singleton (in this case, `Schmovin`) and calling its methods in the base game's code.

### Plugging in the Modchart (In Groovin')
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

### Plugging in the Modchart (In a Standalone / Other Engine)

If you're *not* using Groovin' and are using the standalone version of Schmovin' in another engine, you can just pass the client in after `SchmovinInstance` is instantiated... somewhere. Each engine will probably have their own way of doing that.

### Making the Modchart
In your `SchmovinClient` subclass, override `Initialize()` and define every timeline event there.
Add events to the `SchmovinTimeline` by using the ease, set, function, and tween methods defined in the superclass.
For the ease functions, use `FlxEase`.

You can also make some cooler custom-defined stuff by overriding the `Update()` class.
For the list of note mods at your disposal, look in the `Registry` class.
