--
title: Compiling a cross-platform objdump
...
The version of objdump included in GNU's binutils is, in theory, capable of understanding executable files for a platform (OS/CPU architecture combination) different from the one you are using. However this is disabled by default and Linux distributions do not bother enabling it. The result is that, for example, trying to view a Mach-O file on Linux will result in the `File format not recognized` error.

Building your cross-platform version of objdump used to be easy, just use `./configure --enable-targets=all` when building binutils. However since the repositories of binutils and gdb have been merged things got more complicated.

There might be an easier way to do this, but I don't know it:

* In the cloned binutils-gdb repository run `./configure --without-gdb --without-gas --without-gdbserver --without-gdbsupport --without-gold --without-gprof --without-ld --without-libiberty --with-binutils` (maybe the correct version is `--disabled-gdb`?)
* Edit the generated Makefile, Add the `--enable-targets=all` option to the `configure-binutils` and `configure-bfd` targets, on the same line that contains the `--target=${target_alias}` option
* Run `make -j4`
* Your cross-platform objdump is in `binutils/objdump`

You can see a list of all supported targets by running `objdump -i` and set the target explicitly with `objdump -b BFDNAME`, usually this is not necessary, objdump will determine the correct target on its own. See also [Binutils Target Selection](https://sourceware.org/binutils/docs/binutils/Target-Selection.html).
