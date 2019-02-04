####################################################################################
# Call Injection in Delve, part 1: Introduction

This is the first part in a series of essays that will describe how function injection is implemented in Delve.

First a few definitions:
* with 'function call injection' I refer to the mechanism with which Delve enables the user to call a function in the target process, with the `call` command.
* with 'target process' I will refer to the process that's being debugged.
* with 'PC' I will refer to the *Program Counter* register of the CPU; this is the CPU register that contains the memory address of the next assembly instruction that will be executed by the CPU. On x86 this register is usually referred to with IP, or *Instruction Pointer*. I'm going to use PC instead to be consistent with the terminology used by the Go runtime
* with 'SP' I will refer to the 'Stack Pointer* register of the CPU; this is the CPU register that contains the address of the top  of the call stack, I will describe this in greater detail in a future part <!-- TODO figure out which -->

For reference the function call injection protocol was introduced in Go 1.11 with CL XXXX <!-- TODO: figure out which CL it was -->. Before this point it was impossible for any debugger to inject a call in a Go process, because of some complications in the Go runtime that will be discussed in a future part of this series <!-- TODO: figure out which -->.

Delve's side of the protocol was implemented for Linux in PR XXXX <!-- TODO: figure out which PR it was --> and extended to macOS in PR XXXX <!-- TODO: figure out which PR it was -->. The full implementation of function calls, as described in this essay was implemented with PR XXXX, XXXX and XXX <!-- TODO: none of these exists yet -->

## Background: the Continue loop

When a debugger wishes to debug a program it calls a special OS API and from that point on the OS will forward certain messages about the target process to the debugger.

At first approximation this *debugger events* include:

* Thread death and creation
* Process death
* Breakpoints

keeping this in mind the `continue` command of Delve is implemented as follows:

```

func Continue() {
	for {
		call ContinueOnce()
		
		evaluate condition of all breakpoints we hit
		return if a breakpoint has condition == true
	}
}

func ContinueOnce() {
	for {
		resume all threads of the target process
		wait for a debugger event from the OS
		switch {
		case thread creation or death:
			handle thread creation or death
		case breakpoint:
			stop all threads of the target process
			return
		default:
			forward anything else to the target process
		}
	}
}
```

Now, you may be wondering what the *forward anything else to the target process* thing is about. As it turns out when a program registers as the debugger for another process it won't just receive the debugger events I described above. The details of what *anything else* includes vary from operating system to operating system, but on Windows you will receive any [exception](https://docs.microsoft.com/en-us/windows/desktop/debug/structured-exception-handling) and on Unix-like OSes you will receive all [unix signals](https://en.wikipedia.org/wiki/Signal_(IPC)) destined for the target process.

Debuggers need to receive this because the might wish to do interesting things with them; it's fairly common, for example, for debuggers to handle SIGSEGV themselves. Delve, however, is a debugger for Go and we let the Go runtime handle SIGSEGV and any other exception or signal so we just forward everything.

The `Continue` function isn't just called to implement the `continue` command. Any command that resumes the execution of the target process, with the exception of `step-instruction`, is actually implemented by setting some breakpoints and then calling `Continue`. This includes `next`, `step` and `stepout`. At [Gophercon Iceland 2018](https://www.youtube.com/watch?v=IKnTr7Zms1k) I described in more detail how `next` is implemented.

We won't talk about `ContinueOnce` any more, its description was provided here only as background information and you can forget about it. We will talk a lot about Continue however: calling a function involves resuming the execution of the target process and therefore needs to go through Continue.

Since Continue is a loop I will refer to it henceforth as the *Continue loop*.

####################################################################################
# Call Injection in Delve, part 2: the call stack

The [call stack](https://en.wikipedia.org/wiki/Call_stack) (*stack* for short) is a data structure used by high level programming language to store the arguments, local variables and return address of each function call being currently executed. Details of its implementation vary depending on programming language and CPU architecture. In the following we'll focus on how the stack is implmeneted by Go on x86.

Go reserves a CPU register, which we'll call SP (for Stack Pointer), to point to the *topmost* element of the stack. Here topmost actually means *most recently inserted in the stack*. On all architectures supported by Go the stack grows downward in memory, what this means is that Go allocates a chunk of memory for the stack and initializes SP to point to the highest memory address in this chunk. When something needs to be pushed on the stack two things happen:

1. the SP register is decremented
2. the value we wish to push on the stack is written at SP

Conversely removing something from the stack is equivalent to incrementing the SP register.

Go never pushes or pops elements to the stack individually, instead on function entry it decrements the SP register enough to 'allocate' space for all its local variables plus all the arguments of the largest function call it can possibly make. This space is reclaimed just before the function returns, by incrementing the SP register.

For example if we consider this function:

```
func f() {
	var a, b, c int
	
	g(a)
	h(b, c)
}
```

on entry `f` will allocate space for its three local variables (8 bytes * 3) as well as space for the arguments to the largest function call it makes, which in this case is the call to `h` which requires two integer slots: 8 * 2; this means that `f` will need to decrement SP by 8*3 + 8*2 = 40 bytes.

A typical stack layout for Go will look like this:

![Go stack layout](stack-layout.png)

Notes:
1. the return address is pushed automatically on the stack by the `CALL` assembly instruction, and removed automatically by the `RET` instruction
2. 