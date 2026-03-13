#!/bin/sh

find "$HOME/lr2_backups/base" -mindepth 1 -maxdepth 1 -type d -mtime +28 -exec rm -rf {} \;
find "$HOME/lr2_backups/wal" -type f -mtime +28 -delete