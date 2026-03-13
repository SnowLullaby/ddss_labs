#!/bin/sh

find "$HOME/lr2_backups/base" -mindepth 1 -maxdepth 1 -type d -mtime +7 -exec rm -rf {} \;