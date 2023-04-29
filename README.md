# Foenix Platform Appcode
This is a repo for hosting experiments and test code for C256 Foenix platform.

## List of Projects:

### hello
A very simple "kick the tires". It outputs "Hello, world" text output then loops indefinitely. This is loaded by copying it into memory as an [Intel .hex](https://en.wikipedia.org/wiki/Intel_HEX) file.

-----

### div
An edge-case test for a 65816 debugger. This program contains code that is executed twice: once in 8-bit mode and once in 16-bit mode. Since it's impossible to convey that idea using language, the source code has a bunch of code bytes dumped in the middle as data directives.

The motive and result of doing this is described more in [this blog post](http://cml-a.com/content/2022/12/15/cursed/).

-----

### exec
Similar to 'hello', a dead-simple program that outputs a message. Except instead of being blitted into memory, these are organized as proper executables.

PGX and PGZ are Foenix executables. The file format names are inspired by Commodore 64 PRG files, where PRG stands for "Program". The concept of PGX came first. Its name comes from "PRG for FMX", shorted to "PGX'. Then the concept of PGZ came second. Its name comes from "PGX, with a Z signature byte", shortened to "PGZ". PGZ are strictly more capable than PGX, so if you're in doubt I recommend using PGZ, but if you're really optimizing for size you may be able to save a couple bytes using PGX.

If you're comparing the build process, you'll notice that PGX and PGZ are concepts set up in the source code, they're not for the assembler. They don't really affect how you invoke the assembler. 
Both executable formats are output the same way from 64tass, using the -o directive. The logistics of setting up the programs as executables is all done in code, not really in how the assembler is invoked. Each format has a header with a signature, and these are set up in the source code.

The C256 kernel understands PGX and PGZ format, and its BASIC can load them.

To execute these using [this kernel](https://github.com/Trinity-11/Kernel_FMX) (others which support a Basic environment may work, this is the one I tested), run it with

```
brun "execpgx.pgx"
```
or

```
brun "execpgz.pgz"
```

The program outputs a message then exits cleanly back into BASIC.

-----


#### exec/pgx

This is a PGX-format executable. PGX formats are a single segment. For more information on the PGX format, see [here](https://wiki.c256foenix.com/index.php?title=Executable_binary_file#PGX).

#### exec/pgz

This is a PGZ-format executable. PGZ formats can be multiple segments, although this example only has one segment. For more information on the PGZ format, see [here](https://wiki.c256foenix.com/index.php?title=Executable_binary_file#PGZ).

Note that PGZ segments are not like *sections* in many x86-based portable executables, e.g., a Windows portable executable (PE) or Linux executable and linkable format (ELF), in that code does not need to be organized separately from the data. Both code and data can be put in a section together. They can also be intermixed if you prefer to do that.

### wormhole

Do you remember DirectDraw? The DirectX 5 SDK disc came with a bunch of samples, including one called "Wormhole". 

This is a port of that sample. Some details are described more [in this blog post](http://cml-a.com/content/).

## Build

These applications were set up using Visual Studio 2019.

These applications are built using Visual Studio custom build steps which call into the [64tass](https://tass64.sourceforge.net) assembler. You may need to update them to point to wherever the 64tass executable lives on your machine. If there is an error when assembling, the message pointing to the line number gets conveniently reported through to the IDE that way.

For a best experience, consider using [this Visual Studio extension](https://github.com/clandrew/vscolorize65c816) for 65c816-based syntax highlighting.
