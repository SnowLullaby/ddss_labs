#!/bin/sh

echo "pg151"
find ~/lr2_backups/base -mindepth 1 -maxdepth 2 -type f | sort

echo "pg155"
ssh postgres1@pg155 'find ~/lr2_backups/base -mindepth 1 -maxdepth 2 -type f | sort'