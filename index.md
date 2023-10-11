---
title: Annotated Debugger Implementation Bibliography
...

This is a hierarchical annotated bibliography of resources related to the development and functioning of debuggers, with a particular emphasis on debugging Go executables and even more in particular about the [Delve debugger](https://github.com/derekparker/delve).

# Table of Contents

1. [Introductory material](#introductory-material)
2. [Delve specific resources](#delve-specific-resources)
3. [Target layer resources](#target-layer-resources)
	1. [86x64 / AMD64](#x64-amd64)
	2. [Windows](#windows)
	3. [Linux](#linux)
	4. [Other](#other)
4. [Symbolic layer resources](#symbolic-layer-resources)
5. [Miscellaneous stuff](#miscellaneous-stuff)


<!-- ---------------------------------------------------------------------------------------------- -->
# Introductory material

* **Backtrace.io series on implementing a debugger**

	Blog series about writing a debugger for linux using `ptrace` and DWARF debug symbols.
	
	* [The fundamentals](https://backtrace.io/blog/backtrace/debugger-internals/)
	* [Building a Go Debugger](https://backtrace.io/blog/backtrace/building-a-go-debugger/) (the stuff about stack barriers is obsolete, they were removed in Go 1.9)

* **Michał Łowicki: making a debugger for Golang**

	Blog series about writing a simple debugger for linux using `ptrace` and the Go debugging symbols (gosymtab and gopclntab). In a real debugger you will probably want to use DWARF debug symbols instead of those.
	
	* [Part I](https://medium.com/golangspec/making-debugger-for-golang-part-i-53124284b7c8)
	* [Part II](https://medium.com/golangspec/making-debugger-in-golang-part-ii-d2b8eb2f19e0)
	* [Part III](https://medium.com/golangspec/making-debugger-in-golang-part-iii-5aac8e49f291)

* **Liz Rice: Debuggers from Scratch (Gophercon UK 2018)**

	Recording of a talk (and written version of the talk) about writing a simple debugger for linux using `ptrace` and the Go debugging symbol (gosymtab and gopclntab). In a real debugger you will probably want to use DWARF debug symbols instead of those.
	
	Both this and Michał Łowicki blog series above suffer from a relatively common pitfall: [golang/go#28315](https://github.com/golang/go/issues/28315).
	
	* [Gophercon UK 2018 Talk](https://www.youtube.com/watch?v=ZrpkrMKYvqQ)
	* [Blog post version of the talk](https://medium.com/@lizrice/a-debugger-from-scratch-part-1-7f55417bc85f)

* **Microsoft: Creating a Basic Debugger**

	Microsoft tutorial on creating a debugger for Windows using `ContinueDebugEvent`/`WaitForDebugEvent` and other related Win32 API.
	
	* [Microsoft: Creating a Basic Debugger](https://docs.microsoft.com/en-us/windows/desktop/debug/creating-a-basic-debugger)

* **Jonathan B. Rosenberg: How Debuggers Work**
	
	The only book I could find about writing debuggers. It explains how to write a debugger for Windows using Win32 API calls and the STI debug format (aka CodeView debug format, which is what Microsoft compilers used to produce until Visual Studio 4). It's pretty outdated, being written in 1996 and the "step over" algorithm is, AFAICT, needlessly complicated and wrong.
	
	Not recommended.
	
	```
	How Debuggers Work (Algorithms, Data Structures, and Architecture)
	Jonathan B. Rosenberg, 1996
	Wiley Computer Publishing (John Wiley & Sons, Inc.)
	ISBN 0-471-14966-7
	```

* **David J. Agans: Debugging**
	
	This doesn't have anything to do with writing debuggers. Instead it's a book about debugging that I really like. It isn't even about using debuggers in particular, it just talks about how to approach a debugging problem in general. The 9 rules it outlays are crucial to using debuggers effectively.
	
	```
	Debugging—The Nine Indispensable Rules for Finding Even the Most Elusive Software and Hardware Problems
	David J. Agans, 2002
	American Management Association
	ISBN 0−8144−7168−4
	```

* **Tim Misiak's stuff**

	Former Microsoft Debugger Platform engineer, he worked on WinDbg and KD. Has a blog where he talks about debuggers (including a tutorial on implementing a toy debugger for Windows in Rust) and a Youtube channel with interviews (also about debuggers).
	
	* [Timdbg blog](https://www.timdbg.com/)
	* [Tim Misiak's Youtube channel](https://www.youtube.com/channel/UCyQ7p63-9V9PZJvgHLKgsaw)
	* [Tim Misiak on the website formerly known as Twitter](https://x.com/timmisiak)

<!-- ---------------------------------------------------------------------------------------------- -->
# Delve specific resources

* **Derek Parker: Advanced Go debugging with Delve (Fosdem 2018)**

	Details of the Go runtime that make Delve necessary.
	
	* [Fosdem 2018 Talk](https://www.youtube.com/watch?v=VBiFiguj52I)

* **Alessandro Arzilli: Architecture of Delve (Gophercon Iceland 2018)**
	
	My talk about Delve internals. Also describes the three layer architecture of Delve (UI, symbolic, target) which is appropriate for other debuggers as well.
	
	If you want to contribute to Delve this is probably the quickest introduction there is.
	
	Also contains a description of a Step Over algorithm that actually works, unlike other algorithms you might find on the internet.
	
	* [Gophercon Iceland 2018 Talk](https://www.youtube.com/watch?v=IKnTr7Zms1k)
	* [Slides](https://speakerdeck.com/aarzilli/internal-architecture-of-delve)

* **How to write a Delve Client**

	Tutorial on how to write a client for Delve (for example an editor plugin using delve to debug code).
	
	* [Delve Client How-to](https://github.com/derekparker/delve/blob/master/Documentation/api/ClientHowto.md )
	* [Edge-case tests for Delve clients](https://github.com/aarzilli/delve_client_testing)

<!-- ---------------------------------------------------------------------------------------------- -->
# Target Layer Resources
This lists reference useful for writing the "target layer" of a debugger, i.e. that part of the debugger that is responsible for managing the target process and manipulating its memory.

## 86x64 / AMD64

* **Intel® 64 and IA-32 Architectures Software Developer’s Manual**
	
	At the end of the day, everything boils down to assembly. So why not read this agile 5000 pages booklet now, and get it over with?
	
	Of particular interest to debuggers the XSAVE format, the INT 3 instruction and debug registers
	
	* [Intel® 64 and IA-32 Architectures Software Developer’s Manual](https://software.intel.com/en-us/articles/intel-sdm)
	* "Managing state using the XSAVE feature set", Vol. 1, Chapter 13 of the previous book set
	* "INT n/INT0/INT3/INT1 - Call to Interrupt Procedure", Vol. 2A, Chapter 3, Page 461
	* "Debug, branch profile, TSC, and Intel® resource director technology (Intel® RDT) features", Vol. 3B, Chapter 17, Page 1 and following (in particular chapter 17.2)

* **Hardware breakpoints**

	* [Debugger flow control: Hardware breakpoints vs software breakpoints](http://www.nynaeve.net/?p=80)
	* [Toggle hardware data/read/execute breakpoints programmatically](https://www.codeproject.com/Articles/28071/Toggle-hardware-data-read-execute-breakpoints-prog)
	* [Stackoverflow: How to set the value of dr7 register in order to create a hardware breakpoint on x86-64?
](https://stackoverflow.com/questions/40818920/how-to-set-the-value-of-dr7-register-in-order-to-create-a-hardware-breakpoint-on), see also `/usr/include/sys/user.h`


## Windows

* **Microsoft: Basic Debugging**

	MSDN entry point for documentation about the Win32 debugging API.
	
	* [Microsoft: Basic Debugging](https://docs.microsoft.com/en-us/windows/desktop/debug/basic-debugging)
	
* **Minidump file format**

	This is the file format used on Windows to record core dumps of running applications. It's called minidump to distinguish it from crashdumps, which are full-system kernel dumps. 
	
	Unlike linux and macOS, which use the same file format for executables and core dumps, the file format for core dumps on Windows is completely different from executables.
	
	It can be produced automatically by Windows, by a WinDbg command or by using the Procdump utility.
	
	A minidump is divide into streams: it has a header, followed by a stream directory and then a bunch of streams. Each stream either describes things about the process in general, about a thread in particular or contains a chunk of memory from the dumped process.
	
	To read a minidump start reading the header, get the offset of the stream directory from it, then read the stream directory and form that read the streams you need.
	
	* [_MINIDUMP_HEADER structure](https://docs.microsoft.com/en-us/windows/desktop/api/minidumpapiset/ns-minidumpapiset-_minidump_header): describes the minidump header format, follow links for a description of the stream directory and each individual stream.
	* [Chromium breakpad minidump format header](https://chromium.googlesource.com/breakpad/breakpad/+/master/src/google_breakpad/common/minidump_format.h)

* **Thread Naming on Windows**

	Windows has a couple of facilities to give names to threads to aid debugging, even if you don't care about supporting this you should know about it or you might get an exception that you don't know what to do with.
	
	* [Microsoft: How to: Set a Thread Name in Native Code](https://docs.microsoft.com/en-us/visualstudio/debugger/how-to-set-a-thread-name-in-native-code?view=vs-2015)
	* [Random ASCII: Thread Naming in Windows: Time for Something Better](https://randomascii.wordpress.com/2015/10/26/thread-naming-in-windows-time-for-something-better/)

## Linux

* **Linux Multithreading implementation**
	
	Linux has a weird way of implementing threads. Basically, there are no threads. Instead a multithreaded process is actually a group of processes that share memory, file handles and signal handling.
	
	As a linux user you don't need to care about this, because the user-space utilities and libc do a decent job of hiding the complexity. If you are writing a debugger backend for linux, however, there is no way to avoid all the weirdness.
	
	* [Robert Love: Linux Kernel Process Management](http://man7.org/linux/man-pages/man2/ptrace.2.html)
	* [man clone](http://man7.org/linux/man-pages/man2/clone.2.html): manpage of the system call used to create new threads, processes or weird thread-process hybrids that shouldn't exist.

* **Ptrace**

	Ptrace is the name of the POSIX syscall used to control a process you want to debug. It's very powerful but also very complicated and janky. Use with caution.
	
	* [man ptrace](http://man7.org/linux/man-pages/man2/ptrace.2.html)

## Other

* **Gdb Remote Serial Protocol**

	This protocol was originally devised to debug programs running in environment that were too constrained to host the full gdb program, such as embedded processors or operating system kernels. The idea was that you would embed a small assembly level debugger, implementing only what I call the "target layer",  and then connect gdb to it using this protocol and end up with a full symbolic debugger.
	
	Notable programs implementing this protocol are gdbserver, lldb-server, debugserver (a stripped down version of lldb-server available on macOS) and [Mozilla RR](https://rr-project.org/).
	
	Beware that there are two different wire encodings for packets, the "binary" encoding and the "not-binary" encoding that differ on whether RLE compression is available and which character is the escape code. There is no good way to tell which packet uses which encoding and sometimes it isn't even documented.
	
	* [Gdb Remote Serial Protocol](https://sourceware.org/gdb/onlinedocs/gdb/Remote-Protocol.html): base specification of the protocol
	* [LLDB extensions](https://github.com/llvm-mirror/lldb/blob/master/docs/lldb-gdb-remote.txt): protocol extensions supported by LLDB

* [**Notes on hardware breakpoints/watchpoints**](hwbreak.html)
	
<!-- ---------------------------------------------------------------------------------------------- -->
# Symbolic Layer Resources

This section contains anything pertaining interpreting debug symbols and extracting them from executable files.

For a modern debugger you only need to be concerned with three executable formats (PE, ELF and Mach-O) and two debug formats (DWARF and PDB). Anything else is of historical interest only at this point.

* **Practical Binary Analysis**
	
	This book has a good introduction to both ELF and PE, as well as other interesting things.
	
	```
	Practical Binary Analysis
	Build Your Own Linux Tools for Binary Instrumentation, Analysis, and Disassembly
	by Dennis Andriesse
	no starch press, December 2018, 456 pp.
	ISBN-13: 978-1-59327-912-7
	```

* **Portable Executable (PE)**

	This is the executable file format used on Windows. It obsoletes the MS-DOS MZ file format and is derived from COFF (Common Object File Format), an older UNIX executable file format.
	
	* [Wikipedia: Portable Executable article](https://en.wikipedia.org/wiki/Portable_Executable)
	* [Microsoft: PE Format](https://docs.microsoft.com/en-us/windows/desktop/Debug/pe-format)

* **Program Database (PDB)**
	
	This is the debug format currently used in Windows. It is supported by Visual Studio, WinDbg and the DbgHelp library. Unfortunately it's also largely undocumented. Gcc, LLVM and Go do not produce debug symbols in this format, instead they opt for embedding DWARF symbols inside PE files even on Windows.
	
	Unlike [stabs](https://en.wikipedia.org/wiki/Stabs) and DWARF this debug format is not embedded inside the executable file and lives instead in separate `.PDB` files.
	
	* [Wikipedia: Program database article](https://en.wikipedia.org/wiki/Program_database)
	* [Microsoft PDB repository on github](https://github.com/Microsoft/microsoft-pdb/), the ultimate form of documentation: source code dumps that don't even compile.

* **Executable and Linkable Format (ELF)** and **System V release 4 Application Binary Interface**

	This is the executable format used on Linux and most other unix-like operating systems. Originally introduced by UNIX System V release 4, it replaces [COFF](https://en.wikipedia.org/wiki/COFF) and the older [a.out](https://en.wikipedia.org/wiki/A.out). It is used to represent executables, object files, shared objects and core dumps.
	
	If you start reading the source code of GDB you'll come across a file called solib-svr4.c the name is a reference to the document introducing the ELF file format: "Shared Object LIBrary - System V Release 4".
	
	* [man elf](https://manpages.debian.org/stretch/manpages/elf.5.en.html): Linux manpage for ELF
	* [System V Release 4 Application Binary Interface](http://www.sco.com/developers/devspecs/gabi41.pdf), in particular:
		* "Chapter 4: Object Files", original description of ELF
		* "Chapter 5: Program Loading and Dynamic Linking", also contains a description of the PT_DYNAMIC section, which is used to locate dynamically loaded libraries.
	* [System V Application Binary Interface AMD64 Architecture Processor Supplement](https://www.uclibc.org/docs/psABI-x86_64.pdf): supplement describing the architecture-specific parts of svr4 ABI for the amd64 architecture. Of particular interest to debuggers:
		* "Section 3.4.3: Auxiliary Vector" describes the format of the auxiliary vector on amd64
		* "Section 3.6: DWARF Definition" and Table 3.36 describes a mapping between DWARF register numbers and actual amd64 registers. 
		* "Section 4.2.4: EH_FRAME sections" describes the format of the .eh_frame section. The document claims that the formats of eh_frame and debug_frame (defined by DWARF) are identical but this is not true.
	* [ELF Handling For Thread-Local Storage](https://www.uclibc.org/docs/tls.pdf): describes how Thread-Local Storage should be handled in ELF files. If you ever hear the words "local exec model" this is what you are looking for.

* **Mach-O**
	
	The file format used on macOS to represent executables, dynamic libraries and core dumps.
	
	* [Wikipedia: Mach-O article](https://en.wikipedia.org/wiki/Mach-O)
	* [Mac OS X ABI Mach-O File Format Reference](https://web.archive.org/web/20090901205800/http://developer.apple.com/mac/library/documentation/DeveloperTools/Conceptual/MachORuntime/Reference/reference.html)

* **Examining executable files**
	
	To examine executable files you can use `objdump` on Linux or `otool` on macOS. My [diexplorer](https://github.com/aarzilli/diexplorer) can show the debug sections inside a browser window, with cross-references. Sometimes it is useful to examine executable files for an architecture other than the one you are using, diexplorer can do that, objdump from GNU's binutils can also do that, but only if it is build in a special way -- which Linux distributions usually don't do. See [compiling a cross-platform objdump](compile-objdump.html).

* **DWARF debug format**

	This is the debug format used on most unix-like systems, including Linux and macOS. It obsoletes [stabs](https://en.wikipedia.org/wiki/Stabs).
	
	* [Michael Eager: Introduction to the DWARF Debugging Format](http://dwarfstd.org/doc/Debugging%20using%20DWARF-2012.pdf). An introduction to the DWARF format, mostly focuses on the debug_info section but also briefly touches on the other two main DWARF sections: debug_line and debug_frame.
	* [DWARF version 2](http://dwarfstd.org/doc/dwarf-2.0.0.pdf) the first version of the DWARF standard (version 1 was retconned out of existence because nobody liked it).
	* [DWARF version 3](http://dwarfstd.org/doc/Dwarf3.pdf): introduces the 64-bit version of DWARF to handle huge executable files.
	* [DWARF version 4](http://dwarfstd.org/doc/DWARF4.pdf): adds debug_types section
	* [DWARF version 5](http://dwarfstd.org/DownloadDwarf5.php): removes debug_types section, major backwards-incompatible changes to the location and ranges sections, minor backwards incompatible changes to debug_info.
	* [Ian Lance Taylor: .eh_frame](https://www.airs.com/blog/archives/460): another description of the eh_frame section, a section derived from the format of debug_frame (see also "System V Application Binary Interface AMD64 Architecture Processor Supplement" above)


<!-- ---------------------------------------------------------------------------------------------- -->
# Miscellaneous stuff

* **Software Exorcism: A Handbook for Debugging and Optimizing Legacy Code** 
	
	If you are interested in obsolete things, like me.
	
	```
	Software Exorcism: A Handbook for Debugging and Optimizing Legacy Code
	Reverend Bill Blunden, 2003
	Apress
	ISBN: 978-1-4302-0788-7
	```

* **Embecosm: Howto: Porting the GNU Debugger**

	A detailed document describing how to port GDB to a different CPU architecture. Also a good introduction to the GDB architecture.
	
	* [Embecosm: Howto: Porting the GNU Debugger](https://www.embecosm.com/appnotes/ean3/embecosm-howto-gdb-porting-ean3-issue-2.pdf)

* **r_debug and link_map**
	
	The DT_DEBUG entry in the .dynamic section can be used to find out which shared libraries are used by a Linux program. Code using this entry is not portable.
	
	* `/usr/include/elf/link.h`

* **Mozilla RR Project**

	A time traveling debugger backend. Can be used as a backend of any debugger that speaks the Gdb Remote Serial Protocol. By default it starts GDB as its frontend.
	
	* [Mozilla RR Project Home Page](https://rr-project.org/)
	* [Engineering Record And Replay For Deployability Extended Technical Report](https://arxiv.org/pdf/1705.05937.pdf)
	* [Quick rr demo (video)](https://www.youtube.com/watch?v=hYsLBcTX00I)
	* [rr 1.2 basic demo (video)](https://youtu.be/61kD3x4Pu8I)
	* [Robert O'Callahan - Corporation Taming Nondeterminism (video)](https://www.youtube.com/watch?v=H4iNuufAe_8)

* **Peter B. Kessler: Fast Breakpoints**

	Details of an implementation for fast conditional breakpoints using jumps to generated code.
	
	* [CiteSeerX download](http://citeseerx.ist.psu.edu/viewdoc/download?doi=10.1.1.90.2322&rep=rep1&type=pdf)
	
	```
	Fast Breakpoints
	Peter B. Kessler, 1990
	Proceedings of the ACM SIGPLAN '90
	White Plains, New York, June 20-22, 1990.
	DOI: 10.1.1.90.2322
	```
* **Acid: A Debugger Built From A Language**

	Plan 9's debugger, built around a programming language. The same programming language is used as the command line of Acid, to build most of Acid's functionality and by the compiler to describe debug symbols.

	* [CiteSeerX download](http://citeseerx.ist.psu.edu/viewdoc/download?doi=10.1.1.472.8070&rep=rep1&type=pdf)
	* [Online version](http://doc.cat-v.org/plan_9/2nd_edition/papers/acid/)
	
	```
	Acid: A Debugger Built From A Language
	Phil Winterbottom, Lucent Technologies Inc.
	Proc. of the Winter 1994 USENIX Conf., pp. 211-222, San Francisco, CA
	DOI: 10.1.1.472.8070
	```
