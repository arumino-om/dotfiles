#!/bin/fish
set BASE_DIR ./ubuntu

echo "Copying '.config' directory to your home directory..."
cp -r $BASE_DIR/.config ~/

if test -e /proc/sys/fs/binfmt_misc/WSLInterop
  echo "You are on the WSL2. We'll copy the '/etc/wsl.conf' file to your system..."
  sudo cp $BASE_DIR/etc/wsl.conf /etc/wsl.conf
end
