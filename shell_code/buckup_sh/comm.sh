#!/bin/bash
for i in `cat tclist.txt`
do
    echo  "pairvolchk -IH10 -g $i -ss">>comm.txt
done
echo  "\n">>comm.txt
echo  "\n">>comm.txt
for i in `cat tclist.txt`
do
    echo  "pairsplit -IH10 -g $i -rw" >>comm.txt
done
echo  "\n">>comm.txt
echo  "\n">>comm.txt
for i in `cat tclist.txt`
do
    echo  "pairresync -IH10  -g $i">>comm.txt
done