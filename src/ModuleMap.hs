{-# LANGUAGE OverloadedStrings #-}

module ModuleMap where

import SimpleConfig
import Data.Monoid ((<>))
import qualified Data.Text as T
import qualified Data.Map as M

data ModuleOpt = Y | M | N | S T.Text | I Int | H T.Text

type KernelConfig = M.Map T.Text ModuleOpt

mkKernelConfig :: Setup -> KernelConfig
mkKernelConfig (Setup _ _ _ _ [] []) = M.unions [ archConfig ]

showKernelConfig :: KernelConfig -> T.Text
showKernelConfig =
  T.unlines . M.elems . M.mapWithKey (\k a -> k <> "=" <> showModuleOpt a)
  where
    showModuleOpt Y = "y"
    showModuleOpt M = "m"
    showModuleOpt N = "n"
    showModuleOpt (S str) = str
    showModuleOpt (I i) = T.pack $ show i
    showModuleOpt (H hx) = hx


graphicsConfig :: Machine -> KernelConfig
graphicsConfig _ = intelGraphics
  where intelGraphics = M.fromList
                          [ ("CONFIG_AGP", Y)
                          , ("CONFIG_AGP_INTEL", Y)
                          , ("CONFIG_DRM", Y)
                          , ("CONFIG_HDMI", Y)
                          , ("CONFIG_FB_CMDLINE", Y)
                          , ("CONFIG_I2C", Y)
                          , ("CONFIG_I2C_ALGOBIT", Y)
                          , ("CONFIG_DMA_SHARED_BUFFER", Y)
                          , ("CONFIG_SYNC_FILE", Y)
                          , ("CONFIG_DRM_FBDEV_EMULATION", Y)
                          , ("CONFIG_DRM_KMS_HELPER", Y)
                          , ("CONFIG_DRM_KMS_FB_HELPER", Y)
                          , ("CONFIG_DRM_I915", Y)
                          , ("CONFIG_INTEL_GTT", Y)
                          , ("CONFIG_INTERVAL_TREE", Y)
                          , ("CONFIG_SHMEM", Y)
                          , ("CONFIG_TMPFS", Y)
                          , ("CONFIG_DRM_PANEL", Y)
                          , ("CONFIG_DRM_MIPI_DSI", Y)
                          , ("CONFIG_RELAY", Y)
                          , ("CONFIG_BACKLIGHT_LCD_SUPPORT", Y)
                          , ("CONFIG_BACKLIGHT_CLASS_DEVICE", Y)
                          , ("CONFIG_INPUT", Y)
                          , ("CONFIG_ACPI_VIDEO", Y)
                          , ("CONFIG_ACPI_BUTTON", Y)
                          , ("CONFIG_IOSF_MBI", Y)
                          ]


systemdConfig :: KernelConfig
systemdConfig = M.fromList
  [ ("CONFIG_DEVTMPFS", Y)
  , ("CONFIG_CGROUPS", Y)
  , ("CONFIG_INOTIFY_USER", Y)
  , ("CONFIG_SIGNALFD", Y)
  , ("CONFIG_TIMERFD", Y)
  , ("CONFIG_EPOLL", Y)
  , ("CONFIG_NET", Y)
  , ("CONFIG_SYSFS", Y)
  , ("CONFIG_PROC_FS", Y)
  , ("CONFIG_FHANDLE", Y)
  , ("CONFIG_CRYPTO_USER_API_HASH", Y)
  , ("CONFIG_CRYPTO_HMAC", Y)
  , ("CONFIG_CRYPTO_SHA256", Y)
  , ("CONFIG_SYSFS_DEPRECATED", N)
  , ("CONFIG_UEVENT_HELPER_PATH", S "")
  , ("CONFIG_FW_LOADER_USER_HELPER", N)
  , ("CONFIG_DMIID", Y)
  , ("CONFIG_BLK_DEV_BSG", Y)
  , ("CONFIG_NET_NS", Y)
  , ("CONFIG_DEVPTS_MULTIPLE_INSTANCES", Y)
  , ("CONFIG_USER_NS", Y)
  ]

inputConfig :: Machine -> KernelConfig
inputConfig machine = inputDrivers machine <> baseInput
  where
    inputDrivers XPS13 = M.fromList
                          [ ("CONFIG_I2C", Y)
                          , ("CONFIG_I2C_HELPER_AUDIO", Y)
                          , ("CONFIG_I2C_DESIGNWARE_PLATFORM", Y)
                          , ("CONFIG_I2C_DESIGNWARE_CORE", Y)
                          , ("CONFIG_HID", Y)
                          , ("CONFIG_HID_MULTITOUCH", Y)
                          , ("CONFIG_I2C_HID", Y)
                          ]
    baseInput = M.fromList
                [ ("CONFIG_INPUT", Y)]

sdcardConfig :: Machine -> KernelConfig
sdcardConfig _ = M.fromList [ ("CONFIG_MMC", Y)
                            , ("CONFIG_MMC_BLOCK", Y)
                            , ("CONFIG_MMC_BLOCK_BOUNCE", Y)
                            ]


audioConfig :: Machine -> KernelConfig
audioConfig machine = audioDrivers machine <> baseAlsa
  where
    audioDrivers XPS13 = intelAudio
    intelAudio = M.fromList
                  [ ("CONFIG_SND_HDA", Y)
                  , ("CONFIG_SND_HDA_INTEL", Y)
                  , ("CONFIG_M68K", N)
                  , ("CONFIG_UML", N)
                  , ("CONFIG_SND_PCI", Y)
                  , ("CONFIG_SND_HDA_GENERIC", Y)
                  , ("CONFIG_SND_HDA_CODEC_HDMI", Y)
                  , ("CONFIG_SND_HDA_CODEC_ANALOG", Y)
                  , ("CONFIG_SND_HDA_CODEC_REALTEK", Y)
                  , ("CONFIG_SND_HDA_PREALLOC_SIZE", I 2048)
                  ]
    baseAlsa = M.fromList
                [ ("CONFIG_SOUND", Y)
                , ("CONFIG_SND", Y)
                ]

wirelessConfig :: Machine -> KernelConfig
wirelessConfig machine = wlDrivers machine <> baseWL
  where
    wlDrivers _ = M.fromList []
    baseWL = M.fromList
                [ ("CONFIG_NET", Y)
                , ("CONFIG_WIRELESS", Y)
                , ("CONFIG_CFG80211", Y)
                , ("CONFIG_CFG80211_WEXT", Y)
                , ("CONFIG_MAC80211", Y)
                , ("CONFIG_NETDEVICES", Y)
                , ("CONFIG_WLAN", Y)
                ]

configNFS :: KernelConfig
configNFS = M.fromList
  [ ("CONFIG_NETWORK_FILESYSTEMS", Y)
  , ("CONFIG_NFS_FS", Y)
  , ("CONFIG_NFSD", Y)
  ]

configBluetooth :: Machine -> KernelConfig
configBluetooth machine = btDrivers machine <> baseBT
  where
    btDrivers _ = M.fromList []
    baseBT = M.fromList
                [ ("CONFIG_NET", Y)
                , ("CONFIG_BT", Y)
                , ("CONFIG_BT_RFCOMM", Y)
                , ("CONFIG_BT_RFCOMM_TTY", Y)
                , ("CONFIG_BT_BNEP", Y)
                , ("CONFIG_BT_BNEP_MC_FILTER", Y)
                , ("CONFIG_BT_BNEP_PROTO_FILTER", Y)
                , ("CONFIG_BT_HIDP", Y)
                , ("CONFIG_RFKILL", Y)
                ]


archConfig :: KernelConfig
archConfig = M.fromList
  -- Support for init systems
  [ ("CONFIG_64BIT", Y)
  , ("CONFIG_X86_64", Y)
  , ("CONFIG_X86", Y)
  , ("CONFIG_BUILDTIME_EXTABLE_SORT", Y)
  , ("CONFIG_THREAD_INFO_IN_TASK", Y)
  , ("CONFIG_INSTRUCTION_DECODER", Y)
  , ("CONFIG_OUTPUT_FORMAT", S "elf64-x86-64")
  , ("CONFIG_ARCH_DEFCONFIG", S "arch/x86/configs/x86_64_defconfig")
  , ("CONFIG_LOCKDEP_SUPPORT", Y)
  , ("CONFIG_STACKTRACE_SUPPORT", Y)
  , ("CONFIG_MMU", Y)
  , ("CONFIG_ARCH_MMAP_RND_BITS_MIN", I 28)
  , ("CONFIG_ARCH_MMAP_RND_BITS_MAX", I 32)
  , ("CONFIG_ARCH_MMAP_RND_COMPAT_BITS_MIN", I 8)
  , ("CONFIG_ARCH_MMAP_RND_COMPAT_BITS_MAX", I 16)
  , ("CONFIG_NEED_DMA_MAP_STATE", Y)
  , ("CONFIG_NEED_SG_DMA_LENGTH", Y)
  , ("CONFIG_GENERIC_BUG", Y)
  , ("CONFIG_GENERIC_BUG_RELATIVE_POINTERS", Y)
  , ("CONFIG_GENERIC_HWEIGHT", Y)
  , ("CONFIG_RWSEM_XCHGADD_ALGORITHM", Y)
  , ("CONFIG_GENERIC_CALIBRATE_DELAY", Y)
  , ("CONFIG_ARCH_HAS_CPU_RELAX", Y)
  , ("CONFIG_ARCH_HAS_CACHE_LINE_SIZE", Y)
  , ("CONFIG_HAVE_SETUP_PER_CPU_AREA", Y)
  , ("CONFIG_NEED_PER_CPU_EMBED_FIRST_CHUNK", Y)
  , ("CONFIG_NEED_PER_CPU_PAGE_FIRST_CHUNK", Y)
  , ("CONFIG_ARCH_HIBERNATION_POSSIBLE", Y)
  , ("CONFIG_ARCH_SUSPEND_POSSIBLE", Y)
  , ("CONFIG_ARCH_WANT_HUGE_PMD_SHARE", Y)
  , ("CONFIG_ARCH_WANT_GENERAL_HUGETLB", Y)
  , ("CONFIG_ZONE_DMA32", Y)
  , ("CONFIG_AUDIT_ARCH", Y)
  , ("CONFIG_ARCH_SUPPORTS_OPTIMIZED_INLINING", Y)
  , ("CONFIG_ARCH_SUPPORTS_DEBUG_PAGEALLOC", Y)
  , ("CONFIG_HAVE_INTEL_TXT", Y)
  , ("CONFIG_X86_64_SMP", Y)
  , ("CONFIG_ARCH_SUPPORTS_UPROBES", Y)
  , ("CONFIG_FIX_EARLYCON_MEM", Y)
  , ("CONFIG_PGTABLE_LEVELS", I 4)
  , ("CONFIG_DEFCONFIG_LIST", S "/lib/modules/$UNAME_RELEASE/.config")
  , ("CONFIG_IRQ_WORK", Y)

  -- Kernel performance events and counters
  , ("CONFIG_HAVE_ARCH_SOFT_DIRTY", Y)
  , ("CONFIG_MODULES_USE_ELF_RELA", Y)
  , ("CONFIG_ARCH_HAS_ELF_RANDOMIZE", Y)
  , ("CONFIG_ARCH_HAS_SET_MEMORY", Y)
  , ("CONFIG_ARCH_HAS_STRICT_KERNEL_RWX", Y)
  , ("CONFIG_ARCH_HAS_STRICT_MODULE_RWX", Y)
  , ("CONFIG_ARCH_HAVE_NMI_SAFE_CMPXCHG", Y)
  , ("CONFIG_ARCH_USE_BUILTIN_BSWAP", Y)
  , ("CONFIG_ARCH_WANTS_DYNAMIC_TASK_STRUCT", Y)
  , ("CONFIG_GENERIC_SMP_IDLE_THREAD", Y)
  , ("CONFIG_HAVE_ALIGNED_STRUCT_PAGE", Y)
  , ("CONFIG_HAVE_ARCH_HUGE_VMAP", Y)
  , ("CONFIG_HAVE_ARCH_JUMP_LABEL", Y)
  , ("CONFIG_HAVE_ARCH_MMAP_RND_BITS", Y)
  , ("CONFIG_HAVE_ARCH_SECCOMP_FILTER", Y)
  , ("CONFIG_HAVE_ARCH_TRACEHOOK", Y)
  , ("CONFIG_HAVE_ARCH_TRANSPARENT_HUGEPAGE", Y)
  , ("CONFIG_HAVE_ARCH_TRANSPARENT_HUGEPAGE_PUD", Y)
  , ("CONFIG_HAVE_ARCH_VMAP_STACK", Y)
  , ("CONFIG_HAVE_ARCH_WITHIN_STACK_FRAMES", Y)
  , ("CONFIG_HAVE_CC_STACKPROTECTOR", Y)
  , ("CONFIG_HAVE_CMPXCHG_DOUBLE", Y)
  , ("CONFIG_HAVE_CMPXCHG_LOCAL", Y)
  , ("CONFIG_HAVE_CONTEXT_TRACKING", Y)
  , ("CONFIG_HAVE_COPY_THREAD_TLS", Y)
  , ("CONFIG_HAVE_DMA_API_DEBUG", Y)
  , ("CONFIG_HAVE_DMA_CONTIGUOUS", Y)
  , ("CONFIG_HAVE_EFFICIENT_UNALIGNED_ACCESS", Y)
  , ("CONFIG_HAVE_EXIT_THREAD", Y)
  , ("CONFIG_HAVE_GCC_PLUGINS", Y)
  , ("CONFIG_HAVE_HW_BREAKPOINT", Y)
  , ("CONFIG_HAVE_IOREMAP_PROT", Y)
  , ("CONFIG_HAVE_IRQ_EXIT_ON_IRQ_STACK", Y)
  , ("CONFIG_HAVE_IRQ_TIME_ACCOUNTING", Y)
  , ("CONFIG_HAVE_KPROBES", Y)
  , ("CONFIG_HAVE_KPROBES_ON_FTRACE", Y)
  , ("CONFIG_HAVE_KRETPROBES", Y)
  , ("CONFIG_HAVE_MIXED_BREAKPOINTS_REGS", Y)
  , ("CONFIG_HAVE_NMI", Y)
  , ("CONFIG_HAVE_OPROFILE", Y)
  , ("CONFIG_HAVE_OPTPROBES", Y)
  , ("CONFIG_HAVE_PERF_EVENTS_NMI", Y)
  , ("CONFIG_HAVE_PERF_REGS", Y)
  , ("CONFIG_HAVE_PERF_USER_STACK_DUMP", Y)
  , ("CONFIG_HAVE_REGS_AND_STACK_ACCESS_API", Y)
  , ("CONFIG_HAVE_STACK_VALIDATION", Y)
  , ("CONFIG_HAVE_USER_RETURN_NOTIFIER", Y)
  , ("CONFIG_PERF_EVENTS", Y)
  , ("CONFIG_COMPAT_BRK",  Y)
  , ("CONFIG_SLUB",  Y)
  , ("CONFIG_SLUB_CPU_PARTIAL",  Y)
  , ("CONFIG_TRACEPOINTS",  Y)
  , ("CONFIG_OPROFILE_NMI_TIMER",  Y)
  , ("CONFIG_UPROBES",  Y)
  , ("CONFIG_HAVE_DMA_CONTIGUOUS",  Y)
  , ("CONFIG_GENERIC_SMP_IDLE_THREAD",  Y)
  , ("CONFIG_HAVE_CLK",  Y)
  , ("CONFIG_HAVE_DMA_API_DEBUG",  Y)
  , ("CONFIG_HAVE_ALIGNED_STRUCT_PAGE",  Y)
  , ("CONFIG_SECCOMP_FILTER",  Y)
  , ("CONFIG_HAVE_CC_STACKPROTECTOR",  Y)
  , ("CONFIG_HAVE_VIRT_CPU_ACCOUNTING_GEN",  Y)
  , ("CONFIG_ARCH_MMAP_RND_BITS", I 28)
  , ("CONFIG_STRICT_KERNEL_RWX",  Y)

  -- RCU Subsystem
  , ("CONFIG_ARCH_SUPPORTS_INT128", Y)
  , ("CONFIG_ANON_INODES", Y)
  , ("CONFIG_ARCH_SUPPORTS_NUMA_BALANCING", Y)
  , ("CONFIG_ARCH_WANT_BATCHED_UNMAP_TLB_FLUSH", Y)
  , ("CONFIG_HAVE_C_RECORDMCOUNT", Y)
  , ("CONFIG_HAVE_PCSPKR_PLATFORM", Y)
  , ("CONFIG_HAVE_PERF_EVENTS", Y)
  , ("CONFIG_HAVE_UNSTABLE_SCHED_CLOCK", Y)
  , ("CONFIG_SRCU", Y)
  , ("CONFIG_SYSCTL_EXCEPTION_TRACE", Y)
  , ("CONFIG_TREE_RCU",  Y)
  , ("CONFIG_TREE_SRCU",  Y)
  , ("CONFIG_RCU_STALL_COMMON",  Y)
  , ("CONFIG_RCU_NEED_SEGCBLIST",  Y)
  , ("CONFIG_TREE_RCU_TRACE",  Y)
  , ("CONFIG_LOG_BUF_SHIFT", I 14)
  , ("CONFIG_LOG_CPU_MAX_BUF_SHIFT", I 14)
  , ("CONFIG_PRINTK_SAFE_LOG_BUF_SHIFT", I 12)
  , ("CONFIG_ARCH_SUPPORTS_NUMA_BALANCING",  Y)
  , ("CONFIG_CHECKPOINT_RESTORE",  Y)
  , ("CONFIG_NAMESPACES",  Y)
  , ("CONFIG_UTS_NS",  Y)
  , ("CONFIG_IPC_NS",  Y)
  , ("CONFIG_PID_NS",  Y)
  , ("CONFIG_RELAY",  Y)
  , ("CONFIG_CC_OPTIMIZE_FOR_PERFORMANCE",  Y)
  , ("CONFIG_SYSCTL",  Y)
  , ("CONFIG_BPF",  Y)
  , ("CONFIG_EXPERT",  Y)
  , ("CONFIG_MULTIUSER",  Y)
  , ("CONFIG_KALLSYMS",  Y)
  , ("CONFIG_KALLSYMS_ABSOLUTE_PERCPU",  Y)
  , ("CONFIG_KALLSYMS_BASE_RELATIVE",  Y)
  , ("CONFIG_PRINTK",  Y)
  , ("CONFIG_PRINTK_NMI",  Y)
  , ("CONFIG_BUG",  Y)
  , ("CONFIG_BASE_FULL",  Y)
  , ("CONFIG_FUTEX",  Y)
  , ("CONFIG_EVENTFD",  Y)
  , ("CONFIG_SHMEM",  Y)
  , ("CONFIG_ADVISE_SYSCALLS",  Y)

  -- RCU Debugging
  , ("CONFIG_HAVE_DYNAMIC_FTRACE", Y)
  , ("CONFIG_HAVE_DYNAMIC_FTRACE_WITH_REGS", Y)
  , ("CONFIG_HAVE_FENTRY", Y)
  , ("CONFIG_HAVE_FTRACE_MCOUNT_RECORD", Y)
  , ("CONFIG_HAVE_FUNCTION_GRAPH_TRACER", Y)
  , ("CONFIG_HAVE_FUNCTION_TRACER", Y)
  , ("CONFIG_HAVE_SYSCALL_TRACEPOINTS", Y)
  , ("CONFIG_USER_STACKTRACE_SUPPORT", Y)
  , ("CONFIG_RCU_CPU_STALL_TIMEOUT", I 21)
  , ("CONFIG_RCU_TRACE",  Y)
  , ("CONFIG_USER_STACKTRACE_SUPPORT",  Y)
  , ("CONFIG_NOP_TRACER",  Y)
  , ("CONFIG_HAVE_C_RECORDMCOUNT",  Y)
  , ("CONFIG_TRACE_CLOCK",  Y)
  , ("CONFIG_RING_BUFFER",  Y)
  , ("CONFIG_EVENT_TRACING",  Y)
  , ("CONFIG_CONTEXT_SWITCH_TRACER",  Y)
  , ("CONFIG_TRACING",  Y)
  , ("CONFIG_GENERIC_TRACER",  Y)
  , ("CONFIG_TRACING_SUPPORT",  Y)
  , ("CONFIG_FTRACE",  Y)
  , ("CONFIG_BRANCH_PROFILE_NONE",  Y)
  , ("CONFIG_BLK_DEV_IO_TRACE",  Y)
  , ("CONFIG_UPROBE_EVENTS",  Y)
  , ("CONFIG_PROBE_EVENTS",  Y)

  -- Executable file formats
  , ("CONFIG_X86_DEV_DMA_OPS", Y)

  -- IRQ subsystem
  , ("CONFIG_ARCH_CLOCKSOURCE_DATA", Y)
  , ("CONFIG_CLOCKSOURCE_VALIDATE_LAST_CYCLE", Y)
  , ("CONFIG_CLOCKSOURCE_WATCHDOG", Y)
  , ("CONFIG_GENERIC_CLOCKEVENTS", Y)
  , ("CONFIG_GENERIC_CLOCKEVENTS_BROADCAST", Y)
  , ("CONFIG_GENERIC_CLOCKEVENTS_MIN_ADJUST", Y)
  , ("CONFIG_GENERIC_CMOS_UPDATE", Y)
  , ("CONFIG_GENERIC_IRQ_PROBE", Y)
  , ("CONFIG_GENERIC_IRQ_SHOW", Y)
  , ("CONFIG_GENERIC_PENDING_IRQ", Y)
  , ("CONFIG_GENERIC_TIME_VSYSCALL", Y)
  , ("CONFIG_IRQ_FORCED_THREADING", Y)
  , ("CONFIG_SPARSE_IRQ", Y)
  , ("CONFIG_IRQ_DOMAIN",  Y)
  , ("CONFIG_IRQ_DOMAIN_HIERARCHY",  Y)
  , ("CONFIG_GENERIC_MSI_IRQ",  Y)
  , ("CONFIG_GENERIC_MSI_IRQ_DOMAIN",  Y)
  , ("CONFIG_SPARSE_IRQ",  Y)

  -- Performance monitoring
  , ("CONFIG_ARCH_DISCARD_MEMBLOCK", Y)
  , ("CONFIG_ARCH_SUPPORTS_DEFERRED_STRUCT_PAGE_INIT", Y)
  , ("CONFIG_GENERIC_EARLY_IOREMAP", Y)
  , ("CONFIG_HAVE_MEMBLOCK", Y)
  , ("CONFIG_HAVE_MEMBLOCK_NODE_MAP", Y)
  , ("CONFIG_VIRT_TO_BUS", Y)
  , ("CONFIG_PERF_EVENTS_INTEL_UNCORE",  Y)
  , ("CONFIG_PERF_EVENTS_INTEL_RAPL",  Y)
  , ("CONFIG_PERF_EVENTS_INTEL_CSTATE",  Y)
  , ("CONFIG_MICROCODE",  Y)
  , ("CONFIG_MICROCODE_INTEL",  Y)
  , ("CONFIG_MICROCODE_OLD_INTERFACE",  Y)
  , ("CONFIG_X86_MSR",  Y)
  , ("CONFIG_X86_CPUID",  Y)
  , ("CONFIG_ARCH_PHYS_ADDR_T_64BIT",  Y)
  , ("CONFIG_ARCH_DMA_ADDR_T_64BIT",  Y)
  , ("CONFIG_X86_DIRECT_GBPAGES",  Y)
  , ("CONFIG_ARCH_SPARSEMEM_ENABLE",  Y)
  , ("CONFIG_ARCH_SPARSEMEM_DEFAULT",  Y)
  , ("CONFIG_ARCH_SELECT_MEMORY_MODEL",  Y)
  , ("CONFIG_ARCH_PROC_KCORE_TEXT",  Y)
  , ("CONFIG_ILLEGAL_POINTER_VALUE", H "0xdead000000000000")
  , ("CONFIG_SELECT_MEMORY_MODEL",  Y)
  , ("CONFIG_SPARSEMEM_MANUAL",  Y)
  , ("CONFIG_SPARSEMEM",  Y)
  , ("CONFIG_HAVE_MEMORY_PRESENT",  Y)
  , ("CONFIG_SPARSEMEM_EXTREME",  Y)
  , ("CONFIG_SPARSEMEM_VMEMMAP_ENABLE",  Y)
  , ("CONFIG_SPARSEMEM_ALLOC_MEM_MAP_TOGETHER",  Y)
  , ("CONFIG_SPARSEMEM_VMEMMAP",  Y)
  , ("CONFIG_HAVE_MEMBLOCK",  Y)
  , ("CONFIG_HAVE_MEMBLOCK_NODE_MAP",  Y)
  , ("CONFIG_SPLIT_PTLOCK_CPUS", I 4)
  , ("CONFIG_ARCH_ENABLE_SPLIT_PMD_PTLOCK",  Y)
  , ("CONFIG_COMPACTION",  Y)
  , ("CONFIG_MIGRATION",  Y)
  , ("CONFIG_ARCH_ENABLE_HUGEPAGE_MIGRATION",  Y)
  , ("CONFIG_PHYS_ADDR_T_64BIT",  Y)
  , ("CONFIG_VIRT_TO_BUS",  Y)
  , ("CONFIG_MMU_NOTIFIER",  Y)
  , ("CONFIG_KSM",  Y)
  , ("CONFIG_DEFAULT_MMAP_MIN_ADDR", I 0)
  , ("CONFIG_ARCH_SUPPORTS_MEMORY_FAILURE",  Y)
  , ("CONFIG_X86_RESERVE_LOW", I 64)
  , ("CONFIG_MTRR",  Y)
  , ("CONFIG_MTRR_SANITIZER",  Y)
  , ("CONFIG_MTRR_SANITIZER_ENABLE_DEFAULT", I 1)
  , ("CONFIG_MTRR_SANITIZER_SPARE_REG_NR_DEFAULT", I 1)
  , ("CONFIG_X86_PAT",  Y)
  , ("CONFIG_ARCH_USES_PG_UNCACHED",  Y)
  , ("CONFIG_ARCH_RANDOM",  Y)
  , ("CONFIG_EFI",  Y)
  , ("CONFIG_SECCOMP",  Y)
  , ("CONFIG_HZ_1000",  Y)
  , ("CONFIG_HZ", I 1000)
  , ("CONFIG_PHYSICAL_START", H "0x1000000")
  , ("CONFIG_PHYSICAL_ALIGN", H "0x200000")
  , ("CONFIG_HOTPLUG_CPU",  Y)
  , ("CONFIG_LEGACY_VSYSCALL_EMULATE",  Y)
  , ("CONFIG_HAVE_LIVEPATCH",  Y)
  , ("CONFIG_ARCH_ENABLE_MEMORY_HOTPLUG",  Y)

  -- Runtime testing
  , ("CONFIG_ARCH_HAS_DEVMEM_IS_ALLOWED", Y)
  , ("CONFIG_HAVE_ARCH_KGDB", Y)
  , ("CONFIG_PROVIDE_OHCI1394_DMA_INIT",  Y)
  , ("CONFIG_ARCH_HAS_UBSAN_SANITIZE_ALL",  Y)
  , ("CONFIG_EARLY_PRINTK_USB",  Y)
  , ("CONFIG_X86_VERBOSE_BOOTUP",  Y)
  , ("CONFIG_EARLY_PRINTK",  Y)
  , ("CONFIG_EARLY_PRINTK_DBGP",  Y)
  , ("CONFIG_DOUBLEFAULT",  Y)
  , ("CONFIG_HAVE_MMIOTRACE_SUPPORT",  Y)
  , ("CONFIG_IO_DELAY_TYPE_0X80", I 0)
  , ("CONFIG_IO_DELAY_TYPE_0XED", I 1)
  , ("CONFIG_IO_DELAY_TYPE_UDELAY", I 2)
  , ("CONFIG_IO_DELAY_TYPE_NONE", I 3)
  , ("CONFIG_IO_DELAY_0X80",  Y)
  , ("CONFIG_DEFAULT_IO_DELAY_TYPE", I 0)
  , ("CONFIG_DEBUG_BOOT_PARAMS",  Y)
  , ("CONFIG_OPTIMIZE_INLINING",  Y)
  , ("CONFIG_X86_DEBUG_FPU",  Y)

  -- Power management and ACPI options
  , ("CONFIG_ACPI", Y)
  , ("CONFIG_ACPI_LEGACY_TABLES_LOOKUP", Y)
  , ("CONFIG_ACPI_SYSTEM_POWER_STATES_SUPPORT", Y)
  , ("CONFIG_ARCH_HAS_ACPI_TABLE_UPGRADE", Y)
  , ("CONFIG_ARCH_MIGHT_HAVE_ACPI_PDC", Y)
  , ("CONFIG_HAVE_ACPI_APEI", Y)
  , ("CONFIG_HAVE_ACPI_APEI_NMI", Y)
  , ("CONFIG_PM",  Y)
  , ("CONFIG_PM_CLK",  Y)
  , ("CONFIG_ACPI_AC",  Y)
  , ("CONFIG_ACPI_BATTERY",  Y)
  , ("CONFIG_ACPI_BUTTON",  Y)
  , ("CONFIG_ACPI_VIDEO",  Y)
  , ("CONFIG_ACPI_FAN",  Y)
  , ("CONFIG_ACPI_CPU_FREQ_PSS",  Y)
  , ("CONFIG_ACPI_PROCESSOR_CSTATE",  Y)
  , ("CONFIG_ACPI_PROCESSOR_IDLE",  Y)
  , ("CONFIG_ACPI_PROCESSOR",  Y)
  , ("CONFIG_ACPI_HOTPLUG_CPU",  Y)
  , ("CONFIG_ACPI_PROCESSOR_AGGREGATOR",  Y)
  , ("CONFIG_ACPI_THERMAL",  Y)
  , ("CONFIG_X86_PM_TIMER",  Y)
  , ("CONFIG_ACPI_CONTAINER",  Y)
  , ("CONFIG_ACPI_HOTPLUG_IOAPIC",  Y)

  -- Memory Debugging
  , ("CONFIG_ARCH_HAS_KCOV", Y)
  , ("CONFIG_ARCH_HAS_DEBUG_VIRTUAL", Y)
  , ("CONFIG_HAVE_ARCH_KASAN", Y)
  , ("CONFIG_HAVE_ARCH_KMEMCHECK", Y)
  , ("CONFIG_HAVE_DEBUG_KMEMLEAK", Y)
  , ("CONFIG_HAVE_DEBUG_STACKOVERFLOW", Y)
  , ("CONFIG_DEBUG_STACK_USAGE",  Y)
  , ("CONFIG_DEBUG_STACKOVERFLOW",  Y)

  -- GCOV-based kernel profiling
  , ("CONFIG_ARCH_HAS_GCOV_PROFILE_ALL", Y)
  , ("CONFIG_ARCH_HAS_GCOV_PROFILE_ALL",  Y)
  , ("CONFIG_RT_MUTEXES",  Y)
  , ("CONFIG_BASE_SMALL", I 0)
  , ("CONFIG_MODULES_TREE_LOOKUP",  Y)
  , ("CONFIG_BLOCK",  Y)
  , ("CONFIG_BLK_SCSI_REQUEST",  Y)

  -- Library routines
  , ("CONFIG_ARCH_HAS_PMEM_API", Y)
  , ("CONFIG_ARCH_USE_CMPXCHG_LOCKREF", Y)
  , ("CONFIG_ARCH_HAS_FAST_MULTIPLIER", Y)
  , ("CONFIG_ARCH_HAS_PMEM_API", Y)
  , ("CONFIG_ARCH_HAS_SG_CHAIN", Y)
  , ("CONFIG_GENERIC_FIND_FIRST_BIT", Y)
  , ("CONFIG_GENERIC_IOMAP", Y)
  , ("CONFIG_GENERIC_STRNCPY_FROM_USER", Y)
  , ("CONFIG_GENERIC_STRNLEN_USER", Y)
  , ("CONFIG_BITREVERSE",  Y)
  , ("CONFIG_RATIONAL",  Y)
  , ("CONFIG_GENERIC_NET_UTILS",  Y)
  , ("CONFIG_GENERIC_PCI_IOMAP",  Y)
  , ("CONFIG_GENERIC_IO",  Y)
  , ("CONFIG_CRC_CCITT",  Y)
  , ("CONFIG_CRC16",  Y)
  , ("CONFIG_CRC32",  Y)
  , ("CONFIG_CRC32_SLICEBY8",  Y)
  , ("CONFIG_ZLIB_INFLATE",  Y)
  , ("CONFIG_ZLIB_DEFLATE",  Y)
  , ("CONFIG_LZO_COMPRESS",  Y)
  , ("CONFIG_LZO_DECOMPRESS",  Y)
  , ("CONFIG_XZ_DEC",  Y)
  , ("CONFIG_XZ_DEC_X86",  Y)
  , ("CONFIG_XZ_DEC_POWERPC",  Y)
  , ("CONFIG_XZ_DEC_IA64",  Y)
  , ("CONFIG_XZ_DEC_ARM",  Y)
  , ("CONFIG_XZ_DEC_ARMTHUMB",  Y)
  , ("CONFIG_XZ_DEC_SPARC",  Y)
  , ("CONFIG_XZ_DEC_BCJ",  Y)
  , ("CONFIG_GENERIC_ALLOCATOR",  Y)
  , ("CONFIG_INTERVAL_TREE",  Y)
  , ("CONFIG_ASSOCIATIVE_ARRAY",  Y)
  , ("CONFIG_HAS_IOMEM",  Y)
  , ("CONFIG_HAS_IOPORT_MAP",  Y)
  , ("CONFIG_HAS_DMA",  Y)
  , ("CONFIG_CHECK_SIGNATURE",  Y)
  , ("CONFIG_CPU_RMAP",  Y)
  , ("CONFIG_DQL",  Y)
  , ("CONFIG_GLOB",  Y)
  , ("CONFIG_NLATTR",  Y)
  , ("CONFIG_OID_REGISTRY",  Y)
  , ("CONFIG_UCS2_STRING",  Y)
  , ("CONFIG_FONT_SUPPORT",  Y)
  , ("CONFIG_FONT_8x8",  Y)
  , ("CONFIG_FONT_8x16",  Y)
  , ("CONFIG_SG_POOL",  Y)
  , ("CONFIG_ARCH_HAS_MMIO_FLUSH",  Y)
  , ("CONFIG_SBITMAP",  Y)

  -- Bus devices
  , ("CONFIG_ARCH_MIGHT_HAVE_PC_PARPORT", Y)

  -- Hardware I/O ports
  , ("CONFIG_ARCH_MIGHT_HAVE_PC_SERIO", Y)


  -- IO Schedulers
  , ("CONFIG_ARCH_SUPPORTS_ATOMIC_RMW", Y)
  , ("CONFIG_ARCH_USE_QUEUED_RWLOCKS", Y)
  , ("CONFIG_ARCH_USE_QUEUED_SPINLOCKS", Y)
  , ("CONFIG_IOSCHED_NOOP",  Y)
  , ("CONFIG_IOSCHED_CFQ",  Y)
  , ("CONFIG_DEFAULT_CFQ",  Y)
  , ("CONFIG_DEFAULT_IOSCHED", S "cfq")
  , ("CONFIG_INLINE_SPIN_UNLOCK_IRQ",  Y)
  , ("CONFIG_INLINE_READ_UNLOCK",  Y)
  , ("CONFIG_INLINE_READ_UNLOCK_IRQ",  Y)
  , ("CONFIG_INLINE_WRITE_UNLOCK",  Y)
  , ("CONFIG_INLINE_WRITE_UNLOCK_IRQ",  Y)
  , ("CONFIG_MUTEX_SPIN_ON_OWNER",  Y)
  , ("CONFIG_RWSEM_SPIN_ON_OWNER",  Y)
  , ("CONFIG_LOCK_SPIN_ON_OWNER",  Y)
  , ("CONFIG_QUEUED_SPINLOCKS",  Y)
  , ("CONFIG_QUEUED_RWLOCKS",  Y)

  -- Clock Source drivers
  , ("CONFIG_CLKEVT_I8253", Y)

  -- File systems
  , ("CONFIG_DCACHE_WORD_ACCESS", Y)


  -- iptables trigger is under Netfilter config (LED target)
  , ("CONFIG_EDAC_ATOMIC_SCRUB", Y)
  , ("CONFIG_EDAC_SUPPORT", Y)
  , ("CONFIG_RTC_LIB", Y)
  , ("CONFIG_RTC_MC146818_LIB", Y)

  -- Generic Driver Options
  , ("CONFIG_GENERIC_CPU_AUTOPROBE", Y)

  -- Compile-time checks and compiler options
  , ("CONFIG_HARDLOCKUP_CHECK_TIMESTAMP", Y)
  , ("CONFIG_ENABLE_MUST_CHECK",  Y)
  , ("CONFIG_FRAME_WARN", I 2048)
  , ("CONFIG_DEBUG_FS",  Y)
  , ("CONFIG_SECTION_MISMATCH_WARN_ONLY",  Y)
  , ("CONFIG_ARCH_WANT_FRAME_POINTERS",  Y)
  , ("CONFIG_FRAME_POINTER",  Y)
  , ("CONFIG_MAGIC_SYSRQ",  Y)
  , ("CONFIG_MAGIC_SYSRQ_DEFAULT_ENABLE", H "0x1")
  , ("CONFIG_MAGIC_SYSRQ_SERIAL",  Y)
  , ("CONFIG_DEBUG_KERNEL",  Y)

  -- General setup
  , ("CONFIG_HAVE_ARCH_AUDITSYSCALL", Y)
  , ("CONFIG_HAVE_KERNEL_BZIP2", Y)
  , ("CONFIG_HAVE_KERNEL_GZIP", Y)
  , ("CONFIG_HAVE_KERNEL_LZ4", Y)
  , ("CONFIG_HAVE_KERNEL_LZMA", Y)
  , ("CONFIG_HAVE_KERNEL_LZO", Y)
  , ("CONFIG_HAVE_KERNEL_XZ", Y)
  , ("CONFIG_KERNEL_LZ4", Y)
  , ("CONFIG_INIT_ENV_ARG_LIMIT", I 32)
  , ("CONFIG_CROSS_COMPILE", S "")
  , ("CONFIG_LOCALVERSION", S "")
  , ("CONFIG_DEFAULT_HOSTNAME", S "Tiny")
  , ("CONFIG_SWAP", Y)
  , ("CONFIG_SYSVIPC", Y)
  , ("CONFIG_SYSVIPC_SYSCTL", Y)

  -- Certificates for signature checking
  , ("CONFIG_HAVE_KVM", Y)

  -- Processor type and features
  , ("CONFIG_X86_FEATURE_NAMES", Y)
  , ("CONFIG_SMP", Y)
  , ("CONFIG_X86_FAST_FEATURE_TESTS", Y)
  , ("CONFIG_IOSF_MBI", Y)
  , ("CONFIG_X86_SUPPORTS_MEMORY_FAILURE", Y)
  , ("CONFIG_SCHED_OMIT_FRAME_POINTER", Y)
  , ("CONFIG_NO_BOOTMEM", Y)
  , ("CONFIG_GENERIC_CPU", Y)
  , ("CONFIG_X86_INTERNODE_CACHE_SHIFT", I 6)
  , ("CONFIG_X86_L1_CACHE_SHIFT", I 6)
  , ("CONFIG_X86_TSC", Y)
  , ("CONFIG_X86_CMPXCHG64",  Y)
  , ("CONFIG_X86_CMOV",  Y)
  , ("CONFIG_X86_MINIMUM_CPU_FAMILY", I 64)
  , ("CONFIG_X86_DEBUGCTLMSR",  Y)
  , ("CONFIG_PROCESSOR_SELECT",  Y)
  , ("CONFIG_CPU_SUP_INTEL",  Y)
  , ("CONFIG_HPET_TIMER",  Y)
  , ("CONFIG_HPET_EMULATE_RTC",  Y)
  , ("CONFIG_DMI",  Y)
  , ("CONFIG_SWIOTLB",  Y)
  , ("CONFIG_IOMMU_HELPER",  Y)
  , ("CONFIG_NR_CPUS", I 8)
  , ("CONFIG_SCHED_SMT", Y)
  , ("CONFIG_PREEMPT_VOLUNTARY", Y)
  , ("CONFIG_X86_LOCAL_APIC", Y)
  , ("CONFIG_X86_IO_APIC", Y)
  , ("CONFIG_X86_MCE", Y)
  , ("CONFIG_X86_MCE_INTEL", Y)
  , ("CONFIG_X86_MCE_THRESHOLD", Y)
  , ("CONFIG_X86_THERMAL_VECTOR", Y)

  -- Timers subsystem
  , ("CONFIG_HZ_PERIODIC",  Y)

  -- CPU/Task time and stats accounting
  , ("CONFIG_TICK_CPU_ACCOUNTING",  Y)

  -- Partition Types
  , ("CONFIG_PARTITION_ADVANCED",  Y)
  , ("CONFIG_MSDOS_PARTITION",  Y)
  , ("CONFIG_EFI_PARTITION",  Y)
  , ("CONFIG_BLK_MQ_PCI",  Y)

  -- CPU Frequency scaling
  , ("CONFIG_CPU_FREQ",  Y)
  , ("CONFIG_CPU_FREQ_GOV_ATTR_SET",  Y)
  , ("CONFIG_CPU_FREQ_GOV_COMMON",  Y)
  , ("CONFIG_CPU_FREQ_DEFAULT_GOV_PERFORMANCE",  Y)
  , ("CONFIG_CPU_FREQ_GOV_PERFORMANCE",  Y)
  , ("CONFIG_CPU_FREQ_GOV_POWERSAVE",  Y)
  , ("CONFIG_CPU_FREQ_GOV_USERSPACE",  Y)
  , ("CONFIG_CPU_FREQ_GOV_ONDEMAND",  Y)

  -- CPU frequency scaling drivers
  , ("CONFIG_X86_INTEL_PSTATE", Y)
  , ("CONFIG_X86_ACPI_CPUFREQ",  Y)

  -- CPU Idle
  , ("CONFIG_CPU_IDLE",  Y)
  , ("CONFIG_CPU_IDLE_GOV_LADDER",  Y)
  , ("CONFIG_CPU_IDLE_GOV_MENU",  Y)

  -- Bus options (PCI etc.)
  , ("CONFIG_PCI",  Y)
  , ("CONFIG_PCI_DIRECT",  Y)
  , ("CONFIG_PCI_MMCONFIG",  Y)
  , ("CONFIG_PCI_DOMAINS",  Y)
  , ("CONFIG_PCIEPORTBUS",  Y)
  , ("CONFIG_PCIEASPM",  Y)
  , ("CONFIG_PCIEASPM_PERFORMANCE",  Y)
  , ("CONFIG_PCIE_PME",  Y)
  , ("CONFIG_PCI_BUS_ADDR_T_64BIT",  Y)
  , ("CONFIG_PCI_MSI",  Y)
  , ("CONFIG_PCI_MSI_IRQ_DOMAIN",  Y)
  , ("CONFIG_HT_IRQ",  Y)
  , ("CONFIG_PCI_ATS",  Y)
  , ("CONFIG_PCI_PRI",  Y)
  , ("CONFIG_PCI_PASID",  Y)
  , ("CONFIG_PCI_LABEL",  Y)

  -- Executable file formats / Emulations
  , ("CONFIG_BINFMT_ELF", Y)
  , ("CONFIG_ELFCORE",  Y)
  , ("CONFIG_BINFMT_SCRIPT",  Y)
  , ("CONFIG_BINFMT_MISC",  Y)

  ]