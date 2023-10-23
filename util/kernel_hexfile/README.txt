This folder contains utilities and instructions for building the F256 kernel hex file, kernel_F256jr.hex, for use in the FoenixIDE emulator.

Q: Why does the emulator expect all kernels to live in a .hex?
A: That's how it works today. I'd be open to revisiting this in the future.

//////////////////////////////////////////////////////////////////////////////////////

You can find latest release-candidate firmware files in the GitHub respository f256-firmware.

You don't have to build them.

But if you want to build them, here's where they come from:

File				Where it's from
----				---------------
dos.bin				https://github.com/ghackwrench/F256_Jr_Kernel_DOS
v2basic.bin			https://github.com/ghackwrench/OpenFNXKernal
sb1-sb4.bin			https://github.com/FoenixRetro/f256-superbasic
3b-3f.bin			https://github.com/ghackwrench/F256_MicroKernel
pexec.bin			https://github.com/dwsJason/f256_pexec

//////////////////////////////////////////////////////////////////////////////////////

How to update the kernel:

Use a command like

cd /d "D:\repos\fnxapp\util\kernel_hexfile\"
copy "D:\repos\f256-firmware\shipping\firmware\sb01.bin"
copy "D:\repos\f256-firmware\shipping\firmware\sb02.bin"
copy "D:\repos\f256-firmware\shipping\firmware\sb03.bin"
copy "D:\repos\f256-firmware\shipping\firmware\sb04.bin"
copy "D:\repos\f256-firmware\shipping\firmware\dos.bin"
copy "D:\repos\f256-firmware\shipping\firmware\pexec.bin"
copy "D:\repos\f256-firmware\shipping\firmware\help.bin"
copy "D:\repos\f256-firmware\shipping\firmware\docs_superbasic1.bin"
copy "D:\repos\f256-firmware\shipping\firmware\docs_superbasic2.bin"
copy "D:\repos\f256-firmware\shipping\firmware\docs_superbasic3.bin"
copy "D:\repos\f256-firmware\shipping\firmware\docs_superbasic4.bin"
copy "D:\repos\f256-firmware\shipping\firmware\3b.bin"
copy "D:\repos\f256-firmware\shipping\firmware\3c.bin"
copy "D:\repos\f256-firmware\shipping\firmware\3d.bin"
copy "D:\repos\f256-firmware\shipping\firmware\3e.bin"
copy "D:\repos\f256-firmware\shipping\firmware\3f.bin"

d:\64tass\64tass --intel-hex -o kernel_F256jr.hex kernel_F256jr.asm 

This will output the file kernel_F256jr.hex to the local directory.

