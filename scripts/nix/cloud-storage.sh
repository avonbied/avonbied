#!/bin/sh
sudo dnf --assumeyes install rclone

rclone config
echo 'sh -c "rclone mount \"<remote_name>\": ~/<shared_location> --vfs-cache-mode writes"' >> ~/.profile
