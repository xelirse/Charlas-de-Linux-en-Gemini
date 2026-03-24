#!/bin/sh

log_strace="
execve(/usr/bin/chroot, [chroot, ., sh], 0x7fff0f9ec730 /* 24 vars */) = 0
brk(NULL)                               = 0x56252bfed000
access(/etc/ld.so.preload, R_OK)      = -1 ENOENT (No such file or directory)
openat(AT_FDCWD, /etc/ld.so.cache, O_RDONLY|O_CLOEXEC) = 3
fstat(3, {st_mode=S_IFREG|0644, st_size=181523, ...}) = 0
mmap(NULL, 181523, PROT_READ, MAP_PRIVATE, 3, 0) = 0x7f0685f88000
close(3)                                = 0
openat(AT_FDCWD, /usr/lib/libc.so.6, O_RDONLY|O_CLOEXEC) = 3
read(3, \177ELF\2\1\1\3\0\0\0\0\0\0\0\0\3\0>\0\1\0\0\0px\2\0\0\0\0\0@\0\0\0\0\0\0\0x\215\36\0\0\0\0\0\0\0\0\0@\08\0\17\0@\0?\0>\0\6\0\0\0\4\0\0\0@\0\0\0\0\0\0\0@\0\0\0\0\0\0\0@\0\0\0\0\0\0\0H\3\0\0\0\0\0\0H\3\0\0\0\0\0\0\10\0\0\0\0\0\0\0\3\0\0\0\4\0\0\0\200\31\36\0\0\0\0\0\200\31\36\0\0\0\0\0\200\31\36\0\0\0\0\0\36\0\0\0\0\0\0\0\36\0\0\0\0\0\0\0\20\0\0\0\0\0\0\0\1\0\0\0\4\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0..., 832) = 832
pread64(3, \6\0\0\0\4\0\0\0@\0\0\0\0\0\0\0@\0\0\0\0\0\0\0@\0\0\0\0\0\0\0H\3\0\0\0\0\0\0H\3\0\0\0\0\0\0\10\0\0\0\0\0\0\0\3\0\0\0\4\0\0\0\200\31\36\0\0\0\0\0\200\31\36\0\0\0\0\0\200\31\36\0\0\0\0\0\36\0\0\0\0\0\0\0\36\0\0\0\0\0\0\0\20\0\0\0\0\0\0\0\1\0\0\0\4\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0h3\2\0\0\0\0\0h3\2\0\0\0\0\0\0\20\0\0\0\0\0\0\1\0\0\0\5\0\0\0\0@\2\0\0\0\0\0\0@\2\0\0\0\0\0\0@\2\0\0\0\0\0..., 840, 64) = 840
fstat(3, {st_mode=S_IFREG|0755, st_size=2006328, ...}) = 0
mmap(NULL, 8192, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7f0685f86000
pread64(3, \6\0\0\0\4\0\0\0@\0\0\0\0\0\0\0@\0\0\0\0\0\0\0@\0\0\0\0\0\0\0H\3\0\0\0\0\0\0H\3\0\0\0\0\0\0\10\0\0\0\0\0\0\0\3\0\0\0\4\0\0\0\200\31\36\0\0\0\0\0\200\31\36\0\0\0\0\0\200\31\36\0\0\0\0\0\36\0\0\0\0\0\0\0\36\0\0\0\0\0\0\0\20\0\0\0\0\0\0\0\1\0\0\0\4\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0h3\2\0\0\0\0\0h3\2\0\0\0\0\0\0\20\0\0\0\0\0\0\1\0\0\0\5\0\0\0\0@\2\0\0\0\0\0\0@\2\0\0\0\0\0\0@\2\0\0\0\0\0..., 840, 64) = 840
mmap(NULL, 2030680, PROT_READ, MAP_PRIVATE|MAP_DENYWRITE, 3, 0) = 0x7f0685d96000
mmap(0x7f0685dba000, 1507328, PROT_READ|PROT_EXEC, MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3, 0x24000) = 0x7f0685dba000
mmap(0x7f0685f2a000, 319488, PROT_READ, MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3, 0x194000) = 0x7f0685f2a000
mmap(0x7f0685f78000, 24576, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3, 0x1e1000) = 0x7f0685f78000
mmap(0x7f0685f7e000, 31832, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_ANONYMOUS, -1, 0) = 0x7f0685f7e000
close(3)                                = 0
mmap(NULL, 12288, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7f0685d93000
arch_prctl(ARCH_SET_FS, 0x7f0685d93740) = 0
set_tid_address(0x7f0685d93a10)         = 584243
set_robust_list(0x7f0685d93a20, 24)     = 0
rseq(0x7f0685d93680, 0x20, 0, 0x53053053) = 0
mprotect(0x7f0685f78000, 16384, PROT_READ) = 0
mprotect(0x562506907000, 4096, PROT_READ) = 0
mprotect(0x7f0685ff0000, 8192, PROT_READ) = 0
prlimit64(0, RLIMIT_STACK, NULL, {rlim_cur=8192*1024, rlim_max=RLIM64_INFINITY}) = 0
munmap(0x7f0685f88000, 181523)          = 0
getrandom(\xd1\x63\x5e\xcf\x85\x86\x3d\xa1, 8, GRND_NONBLOCK) = 8
brk(NULL)                               = 0x56252bfed000
brk(0x56252c00e000)                     = 0x56252c00e000
openat(AT_FDCWD, /usr/lib/locale/locale-archive, O_RDONLY|O_CLOEXEC) = 3
fstat(3, {st_mode=S_IFREG|0644, st_size=3062944, ...}) = 0
mmap(NULL, 3062944, PROT_READ, MAP_PRIVATE, 3, 0) = 0x7f0685aa7000
close(3)                                = 0
getcwd(/run/media/manjaro/cfb49c22-87f2-47d9-a25b-310d8d8578af/@, 1024) = 58
chroot(.)                             = 0
chdir(/)                              = 0
execve(/usr/local/sbin/sh, [sh], 0x7ffec0e14668 /* 24 vars */) = -1 ENOENT (No such file or directory)
execve(/usr/local/bin/sh, [sh], 0x7ffec0e14668 /* 24 vars */) = -1 ENOENT (No such file or directory)
execve(/usr/bin/sh, [sh], 0x7ffec0e14668 /* 24 vars */) = 0
brk(NULL)                               = 0x5587f778d000
access(/etc/ld.so.preload, R_OK)      = -1 ENOENT (No such file or directory)
openat(AT_FDCWD, /etc/ld.so.cache, O_RDONLY|O_CLOEXEC) = 3
fstat(3, {st_mode=S_IFREG|0644, st_size=451979, ...}) = 0
mmap(NULL, 451979, PROT_READ, MAP_PRIVATE, 3, 0) = 0x7f5aa1c57000
close(3)                                = 0
openat(AT_FDCWD, /usr/lib/x86_64-linux-gnu/libc.so.6, O_RDONLY|O_CLOEXEC) = 3
read(3, \177ELF\2\1\1\3\0\0\0\0\0\0\0\0\3\0>\0\1\0\0\0000\241\2\0\0\0\0\0@\0\0\0\0\0\0\0H\255\36\0\0\0\0\0\0\0\0\0@\08\0\17\0@\0?\0>\0\6\0\0\0\4\0\0\0@\0\0\0\0\0\0\0@\0\0\0\0\0\0\0@\0\0\0\0\0\0\0H\3\0\0\0\0\0\0H\3\0\0\0\0\0\0\10\0\0\0\0\0\0\0\3\0\0\0\4\0\0\0 \33\0\0\0\0\0 \33\0\0\0\0\0 \33\0\0\0\0\0\34\0\0\0\0\0\0\0\34\0\0\0\0\0\0\0\20\0\0\0\0\0\0\0\1\0\0\0\4\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0..., 832) = 832
pread64(3, \6\0\0\0\4\0\0\0@\0\0\0\0\0\0\0@\0\0\0\0\0\0\0@\0\0\0\0\0\0\0H\3\0\0\0\0\0\0H\3\0\0\0\0\0\0\10\0\0\0\0\0\0\0\3\0\0\0\4\0\0\0 \33\0\0\0\0\0 \33\0\0\0\0\0 \33\0\0\0\0\0\34\0\0\0\0\0\0\0\34\0\0\0\0\0\0\0\20\0\0\0\0\0\0\0\1\0\0\0\4\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0px\2\0\0\0\0\0px\2\0\0\0\0\0\0\20\0\0\0\0\0\0\1\0\0\0\5\0\0\0\0\200\2\0\0\0\0\0\0\200\2\0\0\0\0\0\0\200\2\0\0\0\0\0..., 840, 64) = 840
fstat(3, {st_mode=S_IFREG|0755, st_size=2014472, ...}) = 0
mmap(NULL, 8192, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7f5aa1c55000
pread64(3, \6\0\0\0\4\0\0\0@\0\0\0\0\0\0\0@\0\0\0\0\0\0\0@\0\0\0\0\0\0\0H\3\0\0\0\0\0\0H\3\0\0\0\0\0\0\10\0\0\0\0\0\0\0\3\0\0\0\4\0\0\0 \33\0\0\0\0\0 \33\0\0\0\0\0 \33\0\0\0\0\0\34\0\0\0\0\0\0\0\34\0\0\0\0\0\0\0\20\0\0\0\0\0\0\0\1\0\0\0\4\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0px\2\0\0\0\0\0px\2\0\0\0\0\0\0\20\0\0\0\0\0\0\1\0\0\0\5\0\0\0\0\200\2\0\0\0\0\0\0\200\2\0\0\0\0\0\0\200\2\0\0\0\0\0..., 840, 64) = 840
mmap(NULL, 2055760, PROT_READ, MAP_PRIVATE|MAP_DENYWRITE, 3, 0) = 0x7f5aa1a5f000
mmap(0x7f5aa1a87000, 1474560, PROT_READ|PROT_EXEC, MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3, 0x28000) = 0x7f5aa1a87000
mmap(0x7f5aa1bef000, 339968, PROT_READ, MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3, 0x190000) = 0x7f5aa1bef000
mmap(0x7f5aa1c42000, 24576, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3, 0x1e3000) = 0x7f5aa1c42000
mmap(0x7f5aa1c48000, 52816, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_ANONYMOUS, -1, 0) = 0x7f5aa1c48000
close(3)                                = 0
mmap(NULL, 12288, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7f5aa1a5c000
arch_prctl(ARCH_SET_FS, 0x7f5aa1a5c740) = 0
set_tid_address(0x7f5aa1a5cd68)         = 584243
set_robust_list(0x7f5aa1a5ca20, 24)     = 0
rseq(0x7f5aa1a5c680, 0x20, 0, 0x53053053) = 0
mprotect(0x7f5aa1c42000, 16384, PROT_READ) = 0
mprotect(0x5587c2ed0000, 8192, PROT_READ) = 0
mprotect(0x7f5aa1d02000, 8192, PROT_READ) = 0
prlimit64(0, RLIMIT_STACK, NULL, {rlim_cur=8192*1024, rlim_max=RLIM64_INFINITY}) = 0
writev(2, [{iov_base=*** , iov_len=4}, {iov_base=stack smashing detected, iov_len=23}, {iov_base= ***: terminated\n, iov_len=17}], 3*** stack smashing detected ***: terminated
) = 44
mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7f5aa1a5b000
prctl(PR_SET_VMA, PR_SET_VMA_ANON_NAME, 0x7f5aa1a5b000, 4096,  glibc: fatal) = 0
gettid()                                = 584243
getpid()                                = 584243
tgkill(584243, 584243, SIGABRT)         = 0
--- SIGABRT {si_signo=SIGABRT, si_code=SI_TKILL, si_pid=584243, si_uid=0} ---
"

export disco="n"
tar -C "/$disco" --zstd -xvf "$(ls "/$disco/var/cache/pacman/pkg/glibc-*.pkg.tar.zst")"
ldconfig -r "/$disco"
chroot "/$disco" "/usr/bin/bash" --login
echo "" > "/etc/ld.so.cache"
cp -fv "/$disco/usr/lib/libc.so.6" "/$disco/usr/lib/x86_64-linux-gnu/libc.so.6"
