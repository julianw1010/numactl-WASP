SPDX-License-Identifier: LGPL-2.1-only

This project contains a modified [`numactl`](https://github.com/numactl/numactl) 
implementation that adds support for controlling the page table allocation 
policies of processes in addition to changing NUMA allocation policies. 

# Requirements
To run this software, Linux must be configured with the Hydra extension enabled.

# numatl

Simple NUMA policy support. It consists of a numactl program to run other
programs with a specific NUMA policy and a libnuma shared library ("NUMA API")
to set NUMA policy in applications.

The libnuma binary interface is supposed to stay binary compatible.

Incompatible changes will use new symbol version numbers.

In addition there are various test and utility programs, like `numastat` to
display NUMA allocation statistics and `memhog`.

In `test/` there is a small regression test suite.

Note that `regress` assumes a unloaded machine with memory free on each node.
Otherwise you will get spurious failures in the non-strict policies (prefered,
interleave.)

See the manpages [`numactl.8`](https://linux.die.net/man/8/numactl) and
[`numa.3`](https://linux.die.net/man/3/numa) for details.

