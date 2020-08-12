#! /bin/bash
# make sure a domain is given as an argument
if [ -z "$*" ]; then echo "ERROR: no domain given as argument!"; fi

# prep directory
rm -rf /tmp/$1
rm /root/tools/OneForAll/results/*.txt
mkdir /tmp/$1

echo 'running Amass'
amass enum -d $1 -active -o /tmp/$1/amass.tmp

echo 'running Turbolist3r'
python3 /root/tools/Turbolist3r/turbolist3r.py -d $1 -o /tmp/$1/turbolist3r.tmp

echo 'running Assetfinder'
/root/go/bin/assetfinder $1 > /tmp/$1/assetfinder.tmp

echo 'running OneForAll'
python3 /root/tools/OneForAll/oneforall.py --target $1 run

echo 'saving results in one file ...'
cat /root/tools/OneForAll/results/*.txt /tmp/$1/amass.tmp /tmp/$1/turbolist3r.tmp /tmp/$1/assetfinder.tmp > /tmp/$1/results1.tmp

echo 'cleaning duplicates and showing results ...'

# first clean <BR> tags from Turbolist3r, then remove blank lines
tr '<BR>' '\n' < /tmp/$1/results1.tmp > /tmp/$1/results2.tmp
#remove blank lines
sed -i '/^$/d' /tmp/$1/results2.tmp
#remove odd ^M chars causing failure of removal of duplicates
sed 's/\r//' < /tmp/ablo.live/results2.tmp > /tmp/ablo.live/results3.tmp
#remove duplicates
awk '!a[$0]++' /tmp/$1/results3.tmp > /tmp/$1/subdomains.txt

RED='\033[0;31m'
printf ''${RED}'---------------------- ENUMERATED SUBDOMAINS ----------------------\n'
sort -u /tmp/$1/subdomains.txt
rm /tmp/$1/*.tmp
