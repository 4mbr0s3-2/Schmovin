<p align="center">
  <img src="https://github.com/4mbr0s3-2/Schmovin/blob/main/SchmovinLogo.png?raw=true" alt="Schmovin' Logo, \"upscaled\" from Bob's Onslaught's shoutouts screen"/>
</p>

# Schmovin' ([FNF](https://github.com/ninjamuffin99/Funkin) Modcharting Submodule)
<h2 align="center">"Those arrows are schmovin'!"</p>

Based heavily on <a href="https://notitg.heysora.net/">NotITG</a>

## Note: Keep the code private until the documentation is done and the tutorial video is ready!

Schmovin' is basically an attempt at recreating (and porting) some features of NotITG into Friday Night Funkin' while having its own original code structure. 

If you're already familiar with making NotITG files, it's essentially an ease reader and playfield renderer for FNF that comes with a few debug features!

### Want to start making modfiles?
I highly recommend reading the [Mods Design Notebook](https://docs.google.com/document/d/1XSSPSpIuE9S20lc3O3WfixzX_G6zYmLmlmJH1e43YN8/edit?usp=sharing) first! It covers plenty of aspects of modfile and game design and will hopefully let you make playable and not competely unreadable files that are... fun!

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

### FAQ
Q: Why recreate NotITG in FNF? Wouldn't it be better to just use NotITG due to its better performance and features?

A: I just figured that it'd be neat to allow people to make simple modcharts in FNF with HaxeFlixel in a similar fashion to how NotITG modfiles are made. It's great low-level graphics programming practice, anyway, since HaxeFlixel is only meant to be a 2D game engine.

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
