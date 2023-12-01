<p align="center">
  <img src="https://github.com/4mbr0s3-2/Schmovin/blob/main/SchmovinLogo.png?raw=true" alt="Schmovin' Logo, \"upscaled\" from Bob's Onslaught's shoutouts screen"/>
</p>

# Schmovin' ([FNF](https://github.com/ninjamuffin99/Funkin) Modcharting Submodule)

## Note: This project is no longer being maintained.
I kind of lost the motivation to work on this project any further. I also forgot how to mod FNF.

Initially, I was going to release this once I made a tutorial on how to use Schmovin' or how to design modcharts (lest people make unreadable modcharts), but I didn't really find the time to do that.

Instead, I just waited until people stopped asking me about it. I'm silently releasing this now to see if anyone notices.

There's also... 
![NO DOCUMENTATION](https://github.com/4mbr0s3-2/Schmovin/assets/65193484/ea968dfa-2eab-4900-8732-9234cd6f229e)
...so have fun!

In fact, a lot of this codebase was written while I was a junior in high school and probably reflects opinions that have changed since then or implements things differently than how I would implement things now, so keep that in mind when trying to browse through this repo's commit history...

I'm pretty sure this is the most up-to-date branch that works with Week 6 code. Also, since you're on this branch, don't try to put more than two playfields lol

## Original, Not Up-to-Date README
<h2 align="center">"Those arrows are schmovin'!"</p>

Based heavily on <a href="https://notitg.heysora.net/">NotITG</a>

Schmovin' is basically an attempt at recreating (and porting) some features of NotITG into Friday Night Funkin' while having its own original code structure. 

If you're already familiar with making NotITG files, it's essentially an ease reader and playfield renderer for FNF that comes with a few debug features!

### Want to start making modfiles?
I highly recommend reading the Mods Design Notebook (redacted) first! It covers plenty of aspects of modfile and game design and will hopefully let you make playable and not competely unreadable files that are... fun!

This repository is also meant to be a Git submodule for Groovin' Mod Framework, but it can also be used in other engines! Just make sure to give appropriate credit.

### Credits

[4mbr0s3 2](https://www.youtube.com/channel/UCez-Erpr0oqmC71vnDrM9yA) - Did the project

[XeroOl](https://www.youtube.com/c/XeroOl) - Created [Mirin Template](https://xerool.github.io/notitg-mirin/), which this project's interface is loosely based on

[TaroNuke](https://twitter.com/TaroNuke) - Inspiration; really cool rhythm game developer who pioneered [NotITG](https://notitg.heysora.net/)

Roxor Games, Inc. - In the Groove 2 creators who introduced more [arrow modifiers](http://manual.pocitac.com/en/modifiers.html) and mines to Dance Dance Revolution

### Shoutouts

[Nebula The Zorua](https://twitter.com/Nebula_Zorua) - Recreated Schmovin' in [their own FNF engine](https://github.com/nebulazorua/andromeda-engine/blob/e6686c04ccebada08d8574e1c46b6188738debb2/source/modchart/modifiers/PerspectiveModifier.hx) before the source code was even released (very impressive)

[gedehari/sqirra-rng](https://twitter.com/gedehari) - Very epic

[Aikoyori](https://twitter.com/Aikoyori) - Some bugtesting

[haya3218](https://github.com/haya3218) - Beta Psych Engine implementation of Schmovin'

[Shadowfi1385](https://twitter.com/Shadowfi1385) - Very epic

[KadeDeveloper](https://twitter.com/kade0912) - Very epic

### The Gist
There's a class called `SchmovinClient`. Subclasses of it should contain all the actual modchart implementation. 
To load in a modchart, pass an instance of a subclass of `SchmovinClient` into `SchmovinInstance` with `setClient(cli:SchmovinClient)`.

### "Porting" to Other Engines
Since Groovin' Mod Framework decouples mod code into separate submodules (like this whole repository), you can easily use it in other engines by instantiating the base class as a singleton (in this case, `Schmovin`) and calling its methods in the base game's code.

### Plugging in the Modchart (In Groovin')
In `SchmovinInstance`, you'll see a method that sends a "cross mod call" to all other loaded Groovin' mods.
The mod that actually implements the modchart calls the `setClient(cli:SchmovinClient)` method in the `SchmovinInstance` parameter.

In your main mod class, which should be loaded *after* Schmovin', use the following code as a base to instantiate the `SchmovinClient`.
```haxe
override function receiveCrossModCall(command:String, sender:Mod, args:Array<Dynamic>)
{
    // Here, you'd actually check the song and pass in the respective modchart
    // If the number of songs with modcharts gets too unwieldy and this code gets too long,
    // use a switch case or a map or some other collection thing 
    if (PlayState.SONG.song == 'false-paradise' && shouldRun())
    {
        switch (command)
        {
            case 'SchmovinSetClient':
                var instance:SchmovinInstance = cast args[0];
                var cli = new FalseParadiseSchmovinClient(instance, args[1], args[2]);
                instance.setClient(cli);
                
                // Optional if you want to use debug tools
                // sendCrossModCall('SchmovinPrepareDebug', [cli]);
        }
    }
}
```

### Plugging in the Modchart (In a Standalone / Other Engine)

If you're *not* using Groovin' and are using the standalone version of Schmovin' in another engine, you can just pass the client in after `SchmovinInstance` is instantiated... somewhere. Each engine will probably have their own way of doing that.

### Making the Modchart
In your `SchmovinClient` subclass, override `initialize()` and define every timeline event there.
Add events to the `SchmovinTimeline` by using the ease, set, function, and tween methods defined in the superclass.
For the ease functions, use `FlxEase`.

You can also make some cooler custom-defined stuff by overriding the `update()` class.
For the list of note mods at your disposal, look in the `Registry` class.
