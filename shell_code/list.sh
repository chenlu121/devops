#!/bin/bash
for i in `pip list --outdated|awk '{print $1}'|sed -n '3,$p'`
do
    pip install --upgrade $i|tee -a upgrade.log
done