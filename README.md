> This is a fork of _LibreQuake_ that adds `lq-zig`, a Zig conversion of the original QuakeC source code.
>
> By default, the `build.py` script will compile the QuakeC source code, but if you do `./build.py --zig` (or `./build.py -p --zig`, which only compiles the `progs.dat`) then it will compile the Zig version of the code.
>
> This was made to test [`zig-qc`](https://github.com/eira-fransham/zig-qc), a project to compile Zig code to QuakeC.
>
> So far, from my testing, the behaviour of the original QuakeC and the Zig translation is identical.

<p align="center"><a href="https://github.com/lavenderdotpet/LibreQuake">
  <img src="docs/branding/header.png" alt="libre quake header logo" width="75%" />
</a></p>
<h1><p align="center">Quick Access</h1>
<h3><p align="center"><a href="https://github.com/lavenderdotpet/LibreQuake/releases">[Downloads/Releases]</a></p></h3>
<h3><p align="center"><a href="https://librequake.queer.sh">[Project Website]</a></p></h3>
<h3><p align="center"><a href="https://discord.gg/nsr6DTF6RX">[Discord]</a></p></h3>
<h1></h1>
<p align="center"><img src="docs/branding/icon.svg" alt="libre quake icon" width="10%" /></p>
<h1><p align="center">LibreQuake</p></h1>

The _LibreQuake_ project aims to create a complete, free content first-person shooter game, but _LibreQuake_ by itself is just the raw material for a game. It must be paired with a compatible engine to be played.

There is a massive [back catalogue](https://www.quaddicted.com), spanning over two decades, containing thousands of _Quake_ levels and other modifications (“mods”) made by fans of the game. _LibreQuake_ aims to be compatible with these and allows most to be played without the need to use non-free software.

The engine uses a directory called `id1/`, within that directory there are two archives called `pak0.pak` and `pak1.pak`, these archives contain all the game data except the soundtrack. While the _Quake_ engine source code is free, you would usually still need one of the proprietary data files from [id Software](http://www.idsoftware.com) to play _Quake_. _LibreQuake_ aims to create a free alternative: combined with the GPL-licensed _Quake_ source code, this results in a completely free game.

<p align="center">
  <img src="screenshots/maps_example.png" alt="Texture examples screenshot" />
</p>

<p align="center">
  <img src="screenshots/weapons_example.webp" alt="Weapon examples screenshot" />
</p>

<h1><p align="center">How to Play</h1>

Since _LibreQuake_ is only the game data, you will still need to download an engine (or source port). One particularly recommended by the _LibreQuake_ project is [FTEQW](https://fte.triptohell.info/downloads) This engine offers great support for both singleplayer multiplayer and the majority of mods created for both _Quake_ and _LibreQuake_. [vkQuake](https://github.com/Novum/vkQuake/releases), [QuakeSpasmSpiked](https://triptohell.info/moodles/qss) and [Ironwail](https://github.com/andrei-drexler/ironwail/releases) are also good options. For even more options, see the [Quake Wiki](https://quakewiki.org/wiki/Engines).

Once you have downloaded an engine, paste the downloaded id1 (or lq1) folder in the same directory you put the engine executable. This is the executable you will run to start LibreQuake.

If you would like to set up a LAN deathmatch game, see [docs/deathmatch-setup-guide.txt](https://github.com/lavenderdotpet/LibreQuake/blob/main/docs/deathmatch-setup-guide.txt) for more information.

<h1><p align="center">What “Free” Means</h1>

When we speak of free content or software, we refer to the movement in which your freedom to use, copy, modify, and study a work is not infringed. For example, you may freely use _LibreQuake_ for any purpose you see fit, you may redistribute it to anyone without needing to ask for permission, you may modify it (provided you keep the license intact, see `COPYING`), and you may study it. You may read more about free software at the [GNU](http://www.gnu.org/) and [Free Software Foundation](http://www.fsf.org) websites.

<h1><p align="center">Other Info</h1>

<h3><p align="center">Crediting information</h3>

_LibreQuake_ is made up of submissions from many people all over the globe. All of them, including **you**, deserve credit! Please do not forget to provide your name and email when submitting resources.

<h3><p align="center">Using Git</h3>

You can also commit on a clone of the _LibreQuake_ repository, although this is a technical task and it is okay to let other _LibreQuake_ maintainers to do it instead: that is our normal mode of operation. However, pull requests are much appreciated and you may submit them in any manner you wish, with GitHub’s direct pull requests being the simplest, but by far not the only means.

_LibreQuake_ uses the commit message style commonly seen in distributed version control systems, adopted by projects such as Linux and Git. For an explanation of this style, see [How to Write a Git Commit Message](https://chris.beams.io/posts/git-commit/).

For more detailed information on the specifics of contributing to this project, see [How to Contribute to the LibreQuake Project](https://github.com/lavenderdotpet/LibreQuake/blob/main/CONTRIBUTING.md)

<p align="center">
  <img src="docs/branding/boxrotate.webp" alt="Libre Quake game box art rotating animation" width="20%" />
</p>
