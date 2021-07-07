#! /bin/sh
# make sure a domain is given as an argument
if [ -z "$*" ]; then echo "ERROR: no domain given as argument!"; fi

# check number of domains in given argument
countdots=$(echo $1 | grep -o "\." | wc -l)

# prep directory
rm -rf /tmp/$1 2>/dev/null
rm -rf /var/tmp/OneForAll/results/* 2>/dev/null
mkdir /tmp/$1

# variables
if [ "$countdots" == "1" ]; then
domain1=$(echo $1 | cut -d'.' -f1)
extension=$(echo $1 | cut -d'.' -f2)
elif [ "$countdots" == "2" ]; then
domain1=$(echo $1 | cut -d'.' -f1)
domain2=$(echo $1 | cut -d'.' -f2)
extension=$(echo $1 | cut -d'.' -f3)
else
echo ''
fi

echo 'running Amass'
/root/go/bin/amass enum -d $1 -active -noalts -src -timeout 20 -norecursive -o /tmp/$1/amass1.tmp
cat /tmp/$1/amass1.tmp | cut -d']' -f 2 | awk '{print $1}' | sort -u > /tmp/$1/amass2.tmp

echo 'running Turbolist3r'
python3 /var/tmp/Turbolist3r/turbolist3r.py -d $1 -o /tmp/$1/turbolist3r.tmp

echo 'running Assetfinder'
/root/go/bin/assetfinder $1 > /tmp/$1/assetfinder.tmp

echo 'running OneForAll'
python3 /var/tmp/OneForAll/oneforall.py --target $1 --brute False run

echo 'running Chaos'
/root/go/bin/chaos -d $1 -silent -o /tmp/$1/chaos.tmp

echo 'saving results in one file ...'
cat /var/tmp/OneForAll/results/temp/*.txt /tmp/$1/amass2.tmp /tmp/$1/chaos.tmp /tmp/$1/turbolist3r.tmp /tmp/$1/assetfinder.tmp > /tmp/$1/results1.tmp

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

if [ "$countdots" == "1" ]; then
egrep ''$domain1'\.'$extension'' /tmp/$1/results4.tmp > /tmp/$1/subdomains.txt
elif [ "$countdots" == "2" ]; then
egrep ''$domain1'\.'$domain2'\.'$extension'' /tmp/$1/results4.tmp > /tmp/$1/subdomains.txt
else
echo ''
fi

RED='\033[0;31m'
printf ''${RED}'---------------------- ENUMERATED SUBDOMAINS ----------------------\n'
sort -u /tmp/$1/subdomains.txt

printf ''${RED}'------------------------ RUNNING HTTPROBE  ------------------------\n'
cat /tmp/$1/subdomains.txt | /root/go/bin/httprobe -p http:8000 -p http:8080 -p http:8443 -p https:8000 -p https:8080 -p https:8443 -c 50 | tee /tmp/$1/http-subdomains.txt

printf ''${RED}'--------------------- RUNNING RESPONSECHECKER ---------------------\n'
/root/go/bin/ResponseChecker /tmp/$1/http-subdomains.txt | tee /tmp/$1/responsecodes.tmp
cat /tmp/$1/responsecodes.tmp | grep 200 | awk '{ print $1 }' > /tmp/$1/200-OK-urls.txt
rm /tmp/$1/*.tmp
printf ''${RED}'--------------------- RUNNING HTTPX ---------------------\n'
cat /tmp/$1/subdomains.txt | /root/go/bin/httpx -title -tech-detect -status-code -follow-redirects
printf ''${RED}'---------------------------- FINISHED -----------------------------\n'

