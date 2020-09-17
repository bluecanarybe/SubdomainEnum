#! /bin/bash
# make sure a domain is given as an argument
if [ -z "$*" ]; then echo "ERROR: no domain given as argument!"; fi

# prep directory
rm -rf /tmp/$1
rm /root/tools/OneForAll/results/*.txt
mkdir /tmp/$1

# variables
domain=$(echo $1 | cut -d'.' -f1)
extension=$(echo $1 | cut -d'.' -f2)
export CHAOS_KEY="_REDACTED_" # add your own API key here https://forms.gle/LkHUjoxAiHE6djtU6

echo 'running Amass'
amass enum -d $1 -active -o /tmp/$1/amass.tmp

echo 'running Turbolist3r'
python3 /root/tools/Turbolist3r/turbolist3r.py -d $1 -o /tmp/$1/turbolist3r.tmp

echo 'running Assetfinder'
/root/go/bin/assetfinder $1 > /tmp/$1/assetfinder.tmp

echo 'running OneForAll'
python3 /root/tools/OneForAll/oneforall.py --target $1 run

echo 'running Chaos'
/root/go/bin/chaos -d $1 -silent -o /tmp/$1/chaos.tmp

echo 'saving results in one file ...'
cat /root/tools/OneForAll/results/*.txt /tmp/$1/amass.tmp /tmp/$1/chaos.tmp /tmp/$1/turbolist3r.tmp /tmp/$1/assetfinder.tmp > /tmp/$1/results1.tmp

echo 'cleaning duplicates and showing results ...'

# first clean <BR> tags from Turbolist3r, then remove blank lines
tr '<BR>' '\n' < /tmp/$1/results1.tmp > /tmp/$1/results2.tmp
#remove blank lines
sed -i '/^$/d' /tmp/$1/results2.tmp
#remove odd ^M chars causing failure of removal of duplicates
sed 's/\r//' < /tmp/$1/results2.tmp > /tmp/$1/results3.tmp
#remove duplicates
awk '!a[$0]++' /tmp/$1/results3.tmp > /tmp/$1/results4.tmp
# remove false positives (non matching domain)
egrep "\.$domain\.$extension$" /tmp/$1/results4.tmp > /tmp/$1/subdomains.txt

RED='\033[0;31m'
printf ''${RED}'---------------------- ENUMERATED SUBDOMAINS ----------------------\n'
sort -u /tmp/$1/subdomains.txt

printf ''${RED}'------------------------ RUNNING HTTPROBE  ------------------------\n'
cat /tmp/$1/subdomains.txt | /root/go/bin/httprobe -p http:8000 -p http:8080 -p http:8443 -p https:8000 -p https:8080 -p https:8443 -c 50 | tee /tmp/$1/http-subdomains.txt

printf ''${RED}'--------------------- RUNNING RESPONSECHECKER ---------------------\n'
/root/scripts/ResponseCodeChecker/ResponseCodeChecker /tmp/$1/http-subdomains.txt | tee /tmp/$1/responsecodes.tmp

# Print only targets with response code 200 + cleanup of tmp files
cat /tmp/$1/responsecodes.tmp | grep 200 | awk '{ print $1 }' > /tmp/$1/200-OK-urls.txt
rm /tmp/$1/*.tmp

printf ''${RED}'---------------------------- FINISHED -----------------------------\n'
