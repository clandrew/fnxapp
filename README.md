# Foenix Platform Appcode
This is a repo for hosting experiments and test code for C256 Foenix platform.

## List of Projects:

### hello
A very simple "kick the tires". It outputs "Hello, world" text output then loops indefinitely. This is loaded by copying it into memory as an [Intel .hex](https://en.wikipedia.org/wiki/Intel_HEX) file.

![alt text](https://raw.githubusercontent.com/clandrew/fnxapp/main/Images/hello.PNG?raw=true)

-----

### div
An edge-case test for a 65816 debugger. This program contains code that is executed twice: once in 8-bit mode and once in 16-bit mode. Since it's impossible to convey that idea using language, the source code has a bunch of code bytes dumped in the middle as data directives.

The motive and result of doing this is described more in [this blog post](http://cml-a.com/content/2022/12/15/cursed/).

![alt text](https://raw.githubusercontent.com/clandrew/fnxapp/main/Images/div.PNG?raw=true)
-----

### exec
Similar to 'hello', a dead-simple program that outputs a message. Except instead of being blitted into memory, these are organized as proper executables.

PGX and PGZ are Foenix executables. The file format names are meant to make you think of Commodore 64 PRG files, where PRG stands for "Program". The concept of PGX came first. Its name comes from "PRG for FMX", shorted to "PGX'. Then the concept of PGZ came second. Its name comes from "PGX, with a Z signature byte", shortened to "PGZ". 

PGX and PGZ are unrelated to "FNX" files- FNX is a container format used for different types of data, not for executables.

Trivia: when I asked around why the names "PGX" and "PGZ" were chosen, I heard back that they stood for "Peter's Glorious Xylophone" and "Peter's Glorious Zebra". You heard it here, folks.

The main difference between PGX and PGZ is that PGZ can consist of multiple *segments*, where each segment is loaded contiguously into memory. Apparently the benefit of this is more applicable to the 68k-based Foenix systems, less so for 816-based. That said, you might want to have different parts of your program load into different, specific banks to minimize DBR changes, for example, and to do that without patching a bunch of dead space. PGZ are strictly more capable than PGX, so if you're in doubt I recommend using PGZ, but if you're really optimizing for executable size you may be able to save a couple bytes using PGX.

If you're comparing the build process, you'll notice that PGX and PGZ are concepts set up in the source code, they're not for the assembler. They don't really affect how you invoke the assembler. 

Both executable formats are output the same way from 64tass, using the -o directive. The logistics of setting up the programs as executables is all done in code, not really in how the assembler is invoked. Each format has a header with a signature, and these are set up in the source code.

The C256 kernel understands PGX and PGZ format, and its BASIC can load them. To be more specific, the C256 kernel exposes the functions "F_LOAD" and "F_RUN", and the Foenix's BASIC implementation calls these functions when you use BASIC "BRUN".

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

![alt text](https://raw.githubusercontent.com/clandrew/fnxapp/main/Images/execpgx.PNG?raw=true)

#### exec/pgz

This is a PGZ-format executable. PGZ formats can be multiple segments like this example has. For more information on the PGZ format, see [here](https://wiki.c256foenix.com/index.php?title=Executable_binary_file#PGZ).

Note that PGZ segments are not like *sections* in many x86-based executables, e.g., a Windows portable executable (PE) or Linux executable and linkable format (ELF), in that code does not need to be organized separately from the data. Both code and data can be put in a section together. They can also be intermixed if you prefer to do that. 

Segments are allowed to straddle bank boundaries. You can have one segment take up three banks or however many. Of course, just be careful about code execution that crosses a bank boundary, as crossing out of the program bank isn't allowed by 65816 and 64tass will warn about this (see "-Wno-wrap-pc"). This example is a small executable size that doesn't run into any of that.

![alt text](https://raw.githubusercontent.com/clandrew/fnxapp/main/Images/execpgz.PNG?raw=true)

### spaceoddity
A sample oiginally written by [noyen1973](https://github.com/noyen1973), adapted and reorganized with permission. It displays a title graphic and plays sound on the F256K system.

This sample is written for F256K hardware and has been tested there, as opposed to the FoenixIDE emulator.

Some other details:
* This sample is written entirely in 6502 comaptibility mode.
* Graphics and sound assets are baked into the built binary.
* Although it could talk to F256K microkernel since the microkernel is all 6502-based, it doesn't. Instead, it talks directly to the device. So when loading it, you can feel free to blow away the kernelcode.

How to build and load it:
  * The build step uses [64tass](https://tass64.sourceforge.net) as usual. 
  * The build creates a .bin file, which is a raw dump of bytes to be patched in at an externally-chosen location.
  * Use a tool like the 'F256 Uploader', distributed by the hardware vendor, or FoenixMgr available [here](https://github.com/pweingar/FoenixMgr) to transmit the binary over COM3 (USB) interface. Choose "Boot from RAM" and load it at 0x800.

If you do want to expand this sample to call kernel functions, heads up that it will likely (depending on how your machine is setup) be a completely different layer from what's used by the other samples here. Typically it will be the [TinyCore microkernel](https://github.com/ghackwrench/F256_Jr_Kernel_DOS), where the other samples here use the main [C256 project kernel](https://github.com/Trinity-11/Kernel).

![alt text](https://raw.githubusercontent.com/clandrew/fnxapp/main/Images/spaceoddity.jpg?raw=true)

### img
A sample that uses Vicky II to display a single, 256-color image. The image is baked into the binary. 

Like many of the other samples here it runs on emulator.

![alt text](https://raw.githubusercontent.com/clandrew/fnxapp/main/Images/img.PNG?raw=true)

### wormhole

Do you remember DirectDraw? The DirectX 5 SDK disc came with a bunch of samples, including one called "Wormhole". 

This is a port of that sample. Some details are described more [in this blog post](http://cml-a.com/content/). It's similar to 'img', except the palette is updated every frame.

![alt text](https://raw.githubusercontent.com/clandrew/fnxapp/main/Images/wormhole.PNG?raw=true)

## Build

These applications were set up using Visual Studio 2019.

These applications are built using Visual Studio custom build steps which call into the [64tass](https://tass64.sourceforge.net) assembler. You may need to update them to point to wherever the 64tass executable lives on your machine. If there is an error when assembling, the message pointing to the line number gets conveniently reported through to the IDE that way.

For a best experience, consider using [this Visual Studio extension](https://github.com/clandrew/vscolorize65c816) for 65c816-based syntax highlighting.
