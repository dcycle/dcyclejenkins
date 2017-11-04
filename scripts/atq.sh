set -e
# See https://serverfault.com/questions/174678
date;

for j in $(atq | sort -k6,6 -k3,3M -k4,4 -k5,5 |cut -f 1); do atq |grep -P "^$j\t" ;at -c "$j" | tail -n 2; done'
