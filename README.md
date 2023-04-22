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
Similar to 'hello', but it's set up as a PGX that can be executed from Basic rather than simply blitted into memory. To execute it using [this kernel](https://github.com/Trinity-11/Kernel_FMX) (others which support a Basic environment may work, this is the one I tested), run it with

```
brun "exec.pgx"
```
The program outputs a message then exits cleanly back into Basic.

-----

### wormhole

Do you remember DirectDraw? The DirectX 5 SDK disc came with a bunch of samples, including one called "Wormhole". 

This is a port of that sample.

## Build

These applications were set up using Visual Studio 2019.

These applications are built using Visual Studio custom build steps which call into the [64tass](https://tass64.sourceforge.net) assembler. You may need to update them to point to wherever the 64tass executable lives on your machine. If there is an error when assembling, the message pointing to the line number gets conveniently reported through to the IDE that way.

For a best experience, consider using [this Visual Studio extension](https://github.com/clandrew/vscolorize65c816) for 65c816-based syntax highlighting.
