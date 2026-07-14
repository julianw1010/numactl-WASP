# numactl-WASP

A fork of [numactl](https://github.com/numactl/numactl) that adds command-line support for Mitosis page table replication and NUMA-aware page table cache allocation. It requires the [WASP Mitosis kernel](https://github.com/julianw1010/WASP-linux-6.4.0).

## Building

```bash
./install.sh
```

This installs numactl-WASP to `/opt/numactl-wasp` and creates a symlink at `/usr/local/bin/numactl-wasp`. Build dependencies (autoconf, automake, libtool, etc.) are installed automatically.

## Page Table Replication

The `--pgtablerepl` (`-r`) option enables page table replication for a launched process. It takes no argument: the kernel always replicates on **all** online NUMA nodes.

```bash
numactl --pgtablerepl ./my_application
numactl -r ./my_application
```

There is deliberately no node list. Mitosis's `PR_SET_PGTABLE_REPL` prctl takes no nodemask — `mitosis_enable()` always replicates on `node_online_map` — so a node specification would have nothing to select.

Replication is inherited across `fork()` while `/proc/mitosis/inherit` is 1 (the default), and survives `execve()`, so `-r` replicates the whole process tree of the launched command, not just its first process. Note that `waspd` forces `/proc/mitosis/inherit` to 0 while it runs, since it manages each process individually.

Replication is applied after all other policy options have been processed and before the command is executed via `execvp`. This means it can be combined with existing numactl options:

```bash
numactl --interleave=all --pgtablerepl ./my_application
numactl --membind=0,1 --cpunodebind=0,1 --pgtablerepl ./my_application
```

## Page Table Cache Mode

The `--pgtablecache` (`-P`) option enables NUMA-aware page table cache allocation without full replication. In this mode, page table pages are allocated from a per-node cache, placing them on the local NUMA node, but no replicas are created and no writes are broadcast.

```bash
numactl --pgtablecache ./my_application
```

This can be useful as an intermediate configuration between default allocation and full replication.

## How It Works

The `--pgtablerepl` option calls `numa_set_pgtable_replication()` from libnuma, which issues `prctl(PR_SET_PGTABLE_REPL, 1, 0, 0, 0)`. The kernel allocates a replica PGD on every online node, eagerly replicates the entire existing page table tree onto each of them, and switches each CPU to its node-local replica via CR3 writes. Subsequent page table writes are fanned out to every replica, so the replicas stay complete rather than being filled in lazily.

The `--pgtablecache` option calls `numa_set_pgtable_cache_mode(1)`, which issues `prctl(PR_SET_PGTABLE_CACHE_ONLY, 1, ...)`. This enables the per-node page table cache for new allocations without creating replicas.

Both options are applied only after confirming a valid command is present on the command line. If the command is missing, numactl prints usage information and exits without modifying any state.

## libnuma API Additions

This fork adds the following functions to libnuma:

```c
/* Enable page table replication on all NUMA nodes. The kernel always
   replicates on every online node, so there is no node list to pass. */
void numa_set_pgtable_replication(void);

/* Return 1 if page table replication is enabled, 0 if it is not. */
int numa_get_pgtable_replication(void);

/* Enable or disable NUMA-aware page table cache allocation. */
void numa_set_pgtable_cache_mode(int enable);
```

The query counterpart is a plain boolean, not a mask: `PR_GET_PGTABLE_REPL` reports only whether replication is on for the mm, since the node set is never a choice. Per-process replication state is also visible in `/proc/mitosis/status`.

These are exported in `libnuma_1.5` in the versioning script.

## Compatibility

All existing numactl functionality is preserved. The added options and library functions are only meaningful on kernels with the Mitosis patch applied. On unpatched kernels, the prctl calls will return `EINVAL` and numactl will report an error.

## License

numactl is dual-licensed: libnuma under LGPL 2.1, numactl binaries under GPL 2. See LICENSE.GPL2 and LICENSE.LGPL2.1.
