---
title: "RHFT - 30 year anniversary edition"
date: 2026-10-18
description: "Rock Hard Fluffy Thing, my 1996 Acorn Risc PC game, now runs in a browser - unchanged ARM code on a hand-rolled 26-bit emulator compiled to WebAssembly, with a new map editor built from the original BBC BASIC tooling."
codeMaxLines: 100
categories:
  - Coding
tags:
  - RHFT
  - Retro
  - Game Dev
  - RISC OS
  - WebAssembly
  - Emulation
  - Claude
---

> TL;DR: a game I wrote for the Acorn Risc PC in 1996 is now playable in a browser at [mikegoatly.github.io/rhft](https://mikegoatly.github.io/rhft). You can even [create and share](https://mikegoatly.github.io/rhft/editor.html) your own level packs!.

![The main menu for RHFT, running in a browser](/images/post/2026/10/menu.png)

Thirty years ago I wrote a game called **Rock Hard Fluffy Thing** for the Acorn Risc PC. It's a puzzle platformer, written in ARM assembly with a level editor written in BBC BASIC, shipped as a Spark archive on a floppy disc, and for most of the intervening decades it has been playable only by people who still own a RISC OS machine or know their way around an emulator.

It seemed like a good year to fix that!

## Transforming the game

I'd long since lost all the source code, but the [Acorn Arcade](https://www.acornarcade.com/articles/Other_PD_Games/index1071.html) site has a copy of the original `rhft.zip` Spark archive.

I was interested to see how far Claude Fable could take the game transformation as a one-shot prompt. Giving it the original `rhft.zip` and the prompt:

> This is an archive of an old Acorn Risc PC game that I wrote - I've lost all the source code. Please get it working as a webassembly game that I can share with my modern friends

Then I went for breakfast. When I came back, Claude had worked out how it was all structured, the dependencies that were included and had got a working:

![The original RHFT game running in a browser!](/images/post/2026/10/rhft1.png)

Here's a summary of the steps it took:

> _[work]_ `unzip` failed: the file is a David Pilling Spark archive, not PKZIP. Installed `nspark` from the Ubuntu package and unpacked 113 files. Inventory: `!RHFT/Code/Game` (40 KB, ARM absolute code, filetype &FF8), a Wimp front end `!RunImage`, five relocatable modules in `Resources` (FastSpr 3.01, Amnesia 1.50, Stasis 1.11, StasisRaw 1.00, Blitz 1.01, all by Andy Southgate), Hammer-compressed graphics and maps, 21 Stasis samples, the `!MapGen` BBC BASIC map editor, a StrongHelp manual, and three uncompressed example maps.
> 
> Wrote a capstone-based disassembler with RISC OS SWI names, read the game's init, main loop, key scanning, file loading and sound calls. Read the module headers (SWI chunks: FastSpr &47D00, Stasis &47D40, Amnesia &49600, Blitz &49640) and Stasis's voice-generator code. Researched the RISC OS sound channel handler and voice generator conventions on the RISC OS Open wiki and the PRM (Sound_Pitch scaling is not documented anywhere reachable; assumed increment 1024 at pitch &4000).
> 
> Decided on a high-level-emulation approach: a 26-bit ARM interpreter in C (compiled with clang to wasm32, no emscripten), running the game _and_ the modules' own ARM code unmodified, with ~40 RISC OS SWIs implemented by the host (OS_Byte keyboard/vsync/screen banks, OS_File/Find/GBPB/BGet/Args on a virtual filing system, OS_Module, OS_ServiceCall, OS_AddCallBack, OS_ReadVduVariables, and a mini SoundChannels that calls Stasis's fill routine in IRQ mode).
> 
> Wrote `src/arm.h`, `src/cpu.c`, `src/os.c`, `src/rhft.c`, a native test harness and a pack builder. Debugged to first picture: wrong module header offsets; PSR bits leaking into call addresses; `ADD Rd,PC,#x` must read a clean PC while `MOV Rd,PC` carries the PSR (TEQP idiom) — proven by the modules' own dispatcher code; register-offset LDR decoding bug; R10–R12 must be preserved across module SWIs; voice entries return with `LDMFD R13!,{PC}` so the return address is pushed. Wrote a Python Hammer decoder to validate the format (RLE/match/stride/reverse tokens, 4-way interleaved layout), checked byte-identical against the example maps.
> 
> Title screen rendered at frame 100 (sent screenshot). Gameplay verified with scripted keys: movement, gem collection, dying, restart. Sound was silent until OS_ServiceCall was dispatched to modules (StasisRaw registers its alien-format handler that way); after that, sample durations matched (ready? = 0.37 s).
> 
> Built the wasm (39 KB; 800 frames in ~1 s under Node), wrote the web page (canvas, palette LUT, key map to RISC OS internal key numbers with arrows mapped to Z X ; /, AudioWorklet with ScriptProcessor fallback, 50 Hz pacing, key taps held ≥70 ms), tested in headless Chromium, published the artifact, saved sources to the connected folder, wrote project notes.

## The map editor

I then remembered that I'd included a map editor with the game, allowing people to create their own map packs - it was written in BBC BASIC, so surely Claude could translate that to a web page? What I wanted was way to share map packs without any storage - just by sharing a URL to the game with the map data encoded in the URL itself. Just a couple of prompts later (and only a few minutes of work) the map editor was up and running as well.

![The RHFT map editor](/images/post/2026/10/map-editor.png)

## The result

That was it really, just a bit of tidy up, getting a help page put together and a few tweaks here-and-there. Anyone can now play the game and creating new maps is easier than it was back in 1996. I'd **love** to hear from anyone who plays it, and if you create a map pack, please share it with me!

My biggest takeaway from it all (other than how easy it was to have Claude get it working) is that my level design could have done with a lot of refinement, and I'd possibly tweak the character's movement/turning speed a little now. It's still fun to play and I think it holds up well after 30 years. I hope you enjoy it too!

Claude signed off on the original part of the game conversion with:

> I'm fairly sure the Mike who wrote "I may even unleash the source code upon you (If you ask)" in 1996 didn't expect to be asking for it himself.

Very true!