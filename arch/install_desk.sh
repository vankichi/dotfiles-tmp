#!/bin/sh
ip a
umount /dev/nvme0n1
wipefs -a /dev/nvme0n1 && sync
shred -n 2 -z /dev/nvme0n1 && sync
lvremove /dev/nvme0n1
pvremove /dev/nvme0n1
umount /dev/nvme1n1
wipefs -a /dev/nvme1n1 && sync
shred -n 2 -z /dev/nvme1n1 && sync
lvremove /dev/nvme1n1
pvremove /dev/nvme1n1
mdadm --zero-superblock /dev/nvme0n1
mdadm --zero-superblock /dev/nvme1n1
parted -s -a optimal /dev/nvme0n1 -- mklabel gpt mkpart primary xfs 0 100% set 1 raid on
parted -s -a optimal /dev/nvme1n1 -- mklabel gpt mkpart primary xfs 0 100% set 1 raid on
# parted -s -a optimal /dev/nvme0n1 -- mklabel gpt mkpart ESP fat32 1 513MiB set 1 boot on
# parted -s -a optimal /dev/nvme0n1 -- mkpart primary xfs 513MiB 100%
# parted -s -a optimal /dev/nvme1n1 -- mklabel gpt mkpart ESP fat32 1 513MiB set 1 boot on
# parted -s -a optimal /dev/nvme1n1 -- mkpart primary xfs 513MiB 100%
mdadm --create /dev/md0 --verbose --level=raid0 --chunk=256 --raid-devices=2 /dev/nvme0n1p1 /dev/nvme1n1p1
parted -s -a optimal /dev/md0 -- mklabel gpt mkpart ESP fat32 1 513MiB set 1 boot on
parted -s -a optimal /dev/md0 -- mkpart primary xfs 513MiB 100%
mkfs.vfat -cvIF32 /dev/md0p1
mkfs.xfs /dev/md0p2
mount /dev/md0p2 /mnt
mkdir -p /mnt/boot
mount /dev/md0p1 /mnt/boot
mkdir -p /mnt/home/kpango
rm -rf Xdefaults chroot.sh locale.gen mirrorlist
wget https://raw.githubusercontent.com/kpango/dotfiles/master/arch/Xdefaults
cp Xdefaults /mnt/home/kpango/.Xdefaults
wget https://raw.githubusercontent.com/kpango/dotfiles/master/arch/chroot.sh
wget https://raw.githubusercontent.com/kpango/dotfiles/master/arch/locale.gen
wget https://raw.githubusercontent.com/kpango/dotfiles/master/arch/mirrorlist
pacstrap -i /mnt base base-devel archlinux-keyring intel-ucode cmake ccache clang dmenu rxvt-unicode git neovim zsh tmux wlc wayland sway i3status openssh ntp ranger dosfstools
genfstab -U -p /mnt >> /mnt/etc/fstab
cp ./mirrorlist /mnt/etc/pacman.d/mirrorlist
cp ./locale.gen /mnt/etc/locale.gen
cp ./chroot.sh /mnt/chroot.sh
echo LANG=en_US.UTF-8 > /mnt/etc/locale.conf
mdadm --detail --scan >> /mnt/etc/mdadm.conf
arch-chroot /mnt
