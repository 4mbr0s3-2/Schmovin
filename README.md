# Schmovin' (Groovin' Mod Framework Internal Module)
This repository is meant to be a Git submodule for Groovin' Mod Framework, but it can also be used in other engines! (Just make sure to credit)

### "Porting" to Other Engines
Since Groovin' Mod Framework decouples mod code into separate submodules (like this whole repository), you can easily use it in other engines by instantiating the base class as a singleton (in this case, `Schmovin`) and calling its methods in the base game's code. This requires a bit more work than just using Groovin' since it also involves removing  Groovin' dependencies, but if you're looking at this repository instead of the Groovin' repository, you probably know what you're doing anyway.  
