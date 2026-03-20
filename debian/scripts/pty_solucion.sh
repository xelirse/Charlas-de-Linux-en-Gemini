# Solucionar problema pty
mount -t devpts devpts /dev/pts -o nosuid,noexec,gid=5,mode=620
chmod 666 /dev/ptmx
