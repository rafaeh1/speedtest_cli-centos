#!/bin/bash
export SHELL=/bin/bash
export PATH=/usr/local/sbain:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin


Color_Off="$(printf '\033[0m')" #returns to "normal"
BBlue="$(printf '\e[1;36m')" #set green
BGreen="$(printf '\e[1;32m')" #set green
BRed="$(printf '\033[0;31m')" #set red

pInfo() {
  echo "${BBlue}$1${Color_Off}"
}

pError() {
  echo "${BRed}$1${Color_Off}"
}

pSuccess() {
  echo "${BGreen}$1${Color_Off}"
}

id=99 #SITE ID
pInfo ">> getting path & file name"
datetime=`date +"%Y-%m-%d %T"`
path=~/results/
now=$(date +"%Y-%m-%d__%H-%M-%S")
datetime=$(date -u +'%Y-%m-%dT%H:%M:%S.000Z')
pSuccess $now
pSuccess $datetime
filename="$now.json"

pInfo ">> testing"
speedtest -u Mbps -f json-pretty > "$path$filename"

#tranform results
downraw=$(jq -r '.download.bandwidth' $path$filename)
download=$(printf %.2f\\n "$((downraw * 8))e-6")
upraw=$(jq -r '.upload.bandwidth' $path$filename)
upload=$(printf %.2f\\n "$((upraw * 8))e-6")
latency=$(jq -r '.ping.latency' $path$filename)
jitter=$(jq -r '.ping.jitter' $path$filename)
packetLossData=$(jq -r '.packetLoss' $path$filename)
isp=$(jq -r '.isp' $path$filename)
externalIP=$(jq -r '.interface.externalIp' $path$filename)
echo "packetLossData = $packetLossData"

if  [ $packetLossData = null ] || [ $packetLossData = 0 ] ; then
  pSuccess "** null || 0"
  packetloss=0

else
  pSuccess "**ELSE"
  packetloss=$(printf "%.3f" "$packetLossData")
fi

JSON='{"id": { "S": "'"$id"'" }, "date": { "S": "'"$datetime"'" } ,"download": { "S": "'"$download"'" }, "upload": { "S": "'"$upload"'" }, "latency": { "S": "'"$latency"'"}, "jitter": { "S": "'"$jitter"'" }, "packetLoss": { "S": "'"$packetloss"'"}, "isp": { "S": "'"$isp"'"}, "externalIP": { "S": "'"$externalIP"'"}}' 
echo "$JSON" > data.json

pInfo ">> results: "
echo "download = $download Mbps"
echo "upload =  $upload Mbps"
echo "latency =  $latency ms"
echo "jitter = $jitter ms"
echo "packet loss = $packetloss %"

aws dynamodb put-item \
    --table-name link \
    --item file://data.json \
    --return-consumed-capacity TOTAL

pInfo ">> site: $id"
aws dynamodb query \
    --table-name link \
    --key-condition-expression  '#id = :id' \
    --expression-attribute-values  '{":id":{"S": "'"$id"'"}}' \
    --expression-attribute-names '{"#id":"id"}' \
    --select "COUNT"
    #--projection-expression "#date" \
    #--output table
    #--expression-attribute-names '{"#id":"id", "#date":"date"}' \

pInfo ">> file stored in $path$filename"
pSuccess ">> Done!"



