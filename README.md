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
