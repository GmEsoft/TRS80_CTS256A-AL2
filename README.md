G.I. CTS256A-AL2 reimplementation on Z-80
=========================================

Version 0.2.0-alpha

History
-------

### v0.2.0-alpha
- convert text to uppercase to circumvent parsing errors in lower case text by the CTS256 module;
- add rules debugging mode `|r1`.

### v0.1.0-alpha
- converted code-to-speech rules to text using macros to encode them;
- splitted the source code into separate parts.

Overview
--------

This project aims at reimplementing the code contained in the Text-To-Speech processor CTS256A-AL2 from G.I. (General Instruments) to
target the Z-80 processor. The CTS256A-AL2 is a companion chip for the SP0256A-AL2 "Narrator(tm)" voice synthesizer from the same
company. Its role is to convert ASCII English text to Allophone codes for the SP0256A-AL2.

Some time ago, I disassembled and commented the original code of the CTS256A-AL2, to understand how it works. I also wrote a small C
program to extract the conversion rules encoded in the chip. 
See [CTS256A-AL2](https://github.com/GmEsoft/CTS256A-AL2).

Later I wrote a pair of programs in C++, one to emulate the SP0256A-AL2 and produce audio from a stream of allophone codes, the other
to emulate the TMS-7000 CPU (or G.I.'s PIC7041 in this case) on which the CTS256A-AL2 processor is based. 
See [SP0256_CTS256A-AL2](https://github.com/GmEsoft/SP0256_CTS256A-AL2).

In this project, I first wrote a small C++ program to convert the disassembled TMS-7000 source code of the CTS256A-AL2 into Z-80 code.

Then I integrated the generated source code into an executable application that can be run on a TRS-80 Model 4 either on CP/M or LS-DOS
6.3, and into a resident driver and a filter for LS-DOS 6.3.

To use those programs, it is just needed to connect the SP0256A-AL2 in parallel mode to the printer port. For the LS-DOS driver or
filter, 128K or more RAM memory are required, because the resident code is loaded in banked memory. Sufficient memory must also be
available in the low driver area (below $1300). Note that the filter module can also be attached to any device other than the printer
`*PR`.

The CP/M version should also run on other Z-80-based platforms. The output is sent to the standard BDOS `LIST` device.


How to use it
-------------

### CP/M

There is currently no resident CTS256 driver for CP/M. It is only possible to run the executable to say a string or to read aloud a
text file.

#### Executable mode

````
CTS256 string to say
````
or
````
CTS256 filespec
````
The string or the text file just contain some English ASCII text. Some escape codes are recognized:
- `|d1` to enable debug output of allophone mnemonics to the screen;
- `|d0` to disable it;
- `|e1` to echo the ASCII text sent to the CTS256 module;
- `|e0` to disable it;
- `|r1` to enable the rules debugging mode - try `CTS256 |e1 |r1 This is a test.`;
- `|r0` to disable it.


Allophone mnemonics can also be directly converted to codes and sent to the SP0256 device if they are enclosed inside brackets. Refer
to the SP0256A-AL2 data sheet for more info about the allophone mnemonics.

Example (the mnemonics can be spaced):
- `CTS256 I'm a [KK3AAMMPA3PPYY1UW1PA3TT2ER1]`

The SP0256 allophones stream is sent to the LIST device. Use the CP/M CONFIG tool to re-assign the LIST device if needed (for example,
a serial port).


### LS-DOS 6.3

#### Executable mode

````
CTS256 string to say
````
or
````
CTS256 filespec
````

The usage is identical to the CP/M executable version previously discussed.

The output is sent to the `*PR` device. It can be routed to another device or a file using the LS-DOS `ROUTE` command.

#### Driver mode

````
SET *CT [to] CTS256/DVR
````

The driver is assigned to a device name, eg: `*CT`. Any text sent to that device is converted to allophones and sent to the `*PR`
printer device. The `*PR` device can be routed to any other output device (eg: serial port) or a file. Refer to the LS-DOS manual.

Example on how to use it:

````
COPY FALKEN/TXT *CT
````

In BASIC:
````basic
10 ON ERROR GOTO 10000
20 OPEN "O",1,"*CT" 'the device name given at the SET command
30 ON ERROR GOTO 0
40 PRINT #1, "|e1 This is a test."
50 CLOSE
60 END
10000 'Error handler
10010 PRINT "Can't open driver. Error code:";ERR
10020 RESUME 60
````

#### Filter mode

````
SET *CT [to] CTS256/FLT
FILTER *PR [using] *CT
````

The filter is assigned to a device name, eg: `*CT`. Then it is attached to the printer device `*PR` using the `FILTER` command. Any
text sent to that device is converted to allophones and sent to the filtered device. It should also be possible to attach the filter to
the Comms Link device `*CL` (I didn't try...).

Note that it is not possible to use the `CTS256/EXE` program if the filter is attached to the `*PR` device!

Example on how to use it:

````
LIST FALKEN/TXT (P)
````

In BASIC:
````basic
10 LPRINT "|e1 This is a test."
````


How to assemble it
------------------

I selected the assembler [ZMAC](http://48k.ca/zmac.html) from Georges Phillips to build the binaries under Windows.

The same source is used to assemble the different versions. The parameter `-P0=v`, which defines the corresponding system variable
`@@0` to the same value `v`, selects which parts of the code will be selected using conditional assembly:
- `-P0=2` for the CP/M executable `CTS256.COM`;
- `-P0=3` for the LS-DOS 6.3 executable `CTS256/CMD`;
- `-P0=4` for the LS-DOS 6.3 driver `CTS256.DVR`;
- `-P0=5` for the LS-DOS 6.3 filter `CTS256.FLT`.



### CP/M

There is currently no resident CTS256 driver for CP/M.


#### Executable mode

````
ZMAC --zmac CTS256.ASM -P0=2 --od . --oo CIM,LST,BDS
move /Y CTS256.CIM CTS256.COM
````
Then copy `CTS256.COM` to a CP/M disk.


### LS-DOS 6.3

#### Executable mode

````
ZMAC --zmac CTS256.ASM -P0=3 --od . --oo CMD,LST,BDS
````
Then copy `CTS256.CMD` to an LS-DOS 6 disk.


#### Driver mode

````
ZMAC --zmac CTS256.ASM -P0=4 --od . --oo CMD,LST,BDS
move /Y CTS256.CMD CTS256.DVR
````
Then copy `CTS256.DVR` to an LS-DOS 6 disk.


#### Filter mode

````
ZMAC --zmac CTS256.ASM -P0=5 --od . --oo CMD,LST,BDS
move /Y CTS256.CMD CTS256.FLT
````
Then copy `CTS256.FLT` to an LS-DOS 6 disk.




How it works
------------

The original CTS256A-AL2 disassembled source code has been converted to Z-80 instructions using the conversion program
`MCS7000_to_Z80.cpp`. Some fixes have been applied to fix some issues as `JR` value errors and the unsupported `MPY` instructions.
Fortunately the `MPY` instructions were easy to fix with ADD instructions (the multiplicators were 2 and 3). A call to `YLDCTS` (yield)
is also inserted in the idle loops of the CTS256A, to allow some kind of cooperative multitasking between the application and the
CTS256 re-implementation. The converted code is named the "CTS256 module" in this discussion.


The CTS256A-AL2 memory space is handled as:

### Registers R0-255, with the stack and the "internal" device buffers [0000-00FF]:
- The registers are mapped to a region of 256 bytes in the Z-80 RAM space, and the first 128 registers can be accessed via the Z-80
register IX. Because the endianness of the TMS-7000 CPU is reversed wrt. the Z-80, the order of the registers is reversed. This is
needed so the `MOVD` and `DECD` instructions using register pairs can work correctly. So, if IX is initialized to point to R0, the
register R1 is accessed via (IX-1), R2 via (IX-2) and so on. The registers A and B which are mapped to R0 and R1 in the real TMS-7000,
are not mapped in the Z-80 re-implementation. Instead, they simply use the corresponding Z-80 registers A and B  (the Z-80 register A
is saved to C when needed).
- The TMS-7000 stack space is remapped to a "local" stack space of 64 bytes at `CTSSTK`. The Z-80 stack pointer is switched between the
user stack and the local CTS256 module's stack, when the context is switched between the "user" mode and the "CTS256 module" mode. The
Z-80 registers are also saved/restored upon context switching.
- The "internal" device buffers are not used. The CTS256 module is configured to use an external RAM space of 4kB (1000H).

### I/O Ports P0-P255 [0100-01FF]:
- The ports are mapped to a region of 256 bytes in the Z-80 RAM space, and the first 128 ports can be accessed via the Z-80 register
IY. Here the order of the ports is not reversed, as there is no need for that. Some ports are used to write/read the busy status of the
CTS256 module, to enable/disable interrupts and to trigger them.

### Parallel input from host computer [0200-0FFF]:
- The ASCII text bytes from the host are read at the address 0200H. In the re-implementation, this address is mapped to `PARLINP`. When
the host sends a byte to the CTS256 module, it writes the byte at that address, then triggers the INT3 interrupt if enabled.

### SP0256 address space [2000-2FFF]:
- The CTS256A-AL2 device writes the SP0256 allophone codes on the address bus in the space [2000-2FFF]. If an allophone is ready to be
sent to the SP0256, it enables the INT1 interrupt. When the SP0256 is ready to receive a byte, it triggers INT1 and the interrupt
handler sends the byte via the TMS-7000 address bus to the SP0256. In the re-implementation, when a byte is ready to be sent, the INT1
bit is set and the CTS256 module "yields" to the user application. The module wrapper then triggers INT1. The module's INT1 handler
sends the byte to the device's address space in a 256-byte dummy buffer at `SP0256` and the LSB of the address is written to R27. Then
the wrapper reads the LSB of the address in R27 and sends it to the output device.

### ROM code space [F000-FFFF]:
- The original TMS-7000 code has been converted to Z-80 using the conversion tool written in C++. This code space also contains the
packed text-to-speech conversion rules, unmodified.

### Operation

- After the CTS256 module is loaded into memory, it is first configured and prepared to be booted. The configuration initializes
the I/O ports to:
  - use the parallel input mode (vs. serial) from the app (`APORT=xxxxx000`),
  - use the external memory space for the input and output buffers (`APORT=xxx1xxxx`),
  - any delimiter to trigger the conversion (`APORT=1xxxxxxx`).
- Afterwards, the CTS256 module is "booted". The user stack is saved, the local stack pointer is initialized and the initialization
code of the module is executed. At the end of the initialization code, the string `O-K.` is converted and ready to send to the device
output.
- It then enters an idle loop, and in the re-implementation a call to a yield routine `YLDCTS` is made, giving the control back to the
application code. The `YLDCTS` routine first checks if INT1 is enabled, and if so, calls the INT1 handler to let the module send the
next allophone; reads the allophone code and send it to the host device; and repeats until there are no more allophones to send (INT1
disabled). Then the `YLDCTS` routine saves the context (Z-80 registers) and the local stack pointer, switches SP to the application
stack, restores the application registers and returns to the application.
- When the application needs to send a character to the CTS256 module:
  - it stores the character into `PARLIMP`; 
  - switches the context back to the CTS256 module;
  - triggers INT3 to let the module read and process the incoming character;
  - returns to the idle loop from where `YLDCTS` was called;
  - executes the module code to do the text-to-speech conversion, until `YLDCTS` is again invoked in the idle loop.


Program structure
-----------------

The code is divided into the following blocks:


### Driver/Filter Loader

This optional block is assembled only for the LS-DOS 6.3 versions of the Driver `CTS256/DRV` and the Filter `CTS256/FLT`.
It checks the environment to ensure that:
- the loader is invoked by the DOS command `SET *xx CTS256/ext`;
- there is enough memory space in low driver memory to load the Jumper between $LOW and $1300;
- there is at least one bank of 32K extended memory available.

Then:
- it reserves one bank of 32K extended memory;
- it initializes the Jumper module to fix some absolute addresses for its relocation to low driver memory;
- it moves the Jumper to low memory;
- it moves the Driver, the link module, the wrapper and the CTS256 module to the extended memory bank;
- it initializes the Driver.


### Jumper module

This optional block is assembled only for the LS-DOS 6.3 versions of the Driver `CTS256/DRV` and the Filter `CTS256/FLT`.

This module is called by LS-DOS when an I/O operation has to be done with the driver/filter. Its role is to activate
the extended memory bank containing the main part of the code, to call the code in banked memory and to restore the
normal memory banking before returning control to LS-DOS. A small stack in low memory is also used during the activation
of the memory bank. The fact that the banked memory must be mapped to high memory space (8000-FFFF) explains why the 
Jumper memory must be loaded in the low driver memory space (between $LOW and $1300).


### Driver module

This optional block is assembled only for the LS-DOS 6.3 versions of the Driver `CTS256/DRV` and the Filter `CTS256/FLT`.

This module handles the `@PUT` and the filter's `@CTL` requests from the DOS.

The `@PUT` handler:
- handles the parameter sequences `|pn`;
- handles the square brackets to enable/disable the allophone mnemonics parser;
- else sends the character to the CTS256 module or the allophone mnemonics parser.

The `@CTL` handler sends the SP0256 codes produced by the CTS256 module to the output device (`*PR` or other).


### Exec module

This optional block is assembled only for the LS-DOS 6.3 and CP/M versions of the executable application.

This module checks if the command line argument is the name of an existing (text) file.
- If yes, the input for the processing is taken from the file.
- If not, the input is taken from the command line.

The processing done by this module is essentially the same as in the Driver module.


### Link module

This module contains:
- a protected version of the LS-DOS `$SVC` service caller, where the stack is temporarily switched back to low memory, and the
interrupts are disabled before restoring the stack pointer;
- LS-DOS and CP/M versions of the `@DSP`, `@PRT`;
- the incoming character handler, sending the character either to the CTS256 module or to the allophone mnemonics parser;
- the "echo" `|e1` and "debug" `|d1` handlers;
- the intro text.


### SP0256 helper module

This module contains:
- the allophone mnemonics parser;
- the allophone code to mnemonic converter;
- the allophone mnemonics table.


### CTS256 Wrapper module

This module contains:
- the `BOOTCTS` code to initialize and boot the CTS256 module;
- the `YLDCTS` yield routine called by the CTS256 module's idle loop (with context switching);
- the `SENDCTS` resume routine to resume the CTS256 module execution (with context switching).


### CTS256 module

This module contains essentially the code generated by the TMS-7000 to Z-80 source code converter, with some fixes and adaptations.


The C++ conversion program MCS7000_to_Z80
-----------------------------------------

This small program had been written in order to convert the original CTS256A-AL2 disassembled source
code into Z-80 instructions. This was developed ad-hoc to convert only the TMS-7000 instructions that were used by the CTS256A-AL2 device.
So in its current state it could not be used for other applications.

This utility is built on Windows using this Visual Studio C++ compiler command:
````
cl /EHsc MCS7000_to_Z80.cpp
````

Then the generated executable can be used to convert the source code:
````
MCS7000_to_Z80 <CTS256A.ASM >CTS256A_Z80.ASM
````
where `CTS256A.ASM` is the original CTS256A-AL2 disassembled source code and `CTS256A_Z80.ASM` is the converted Z-80 code.


To do next
----------

- Reduce the code size, by removing unneeded generated instructions (`LD C,A` and `LD A,C`).
- Support for exception words EPROM images (as long as they don't contain executable code); see if possible.
- A special flag to enable the output of the matching conversion rules found during the processing.
- A driver mode for CP/M (this can be quite challenging!).
- A Model I/III LDOS version (executable mode only).


Copyright notice
----------------

Microchip, Inc. holds the copyrights to the SP0256-AL2 design and ROM Image, and to the CTS256A-AL2 ROM Image.
Microchip retains the intellectual property rights to the algorithms and data the emulated device CTS256A-AL2 contains.



GPLv3 License
-------------

Created by Michel Bernard (michel_bernard@hotmail.com) - 
<http://www.github.com/GmEsoft/TRS80_CTS256A-AL2>

Copyright (c) 2024 Michel Bernard. All rights reserved.

This file is part of TRS80_CTS256-AL2.

TRS80_CTS256-AL2 is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

TRS80_CTS256-AL2 is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with TRS80_CTS256-AL2.  If not, see <https://www.gnu.org/licenses/>.
