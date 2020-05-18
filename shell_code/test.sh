#!/bin/bash
set -xeuo pipefail
cat bpplist_bj1nbubk11_20191104010001.txt|sed -n  '/^Policy Name\|Schedule/p'

#cat bpplist_bj1nbubk11_20191104010001.txt|sed -n '/Schedule/p'|wc -l