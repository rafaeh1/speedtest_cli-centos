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

id=999 #SITE ID
pInfo ">> getting path & file name"
datetime=`date +"%Y-%m-%d %T"`
path=~/results/
now=$(date +"%Y-%m-%d__%H-%M-%S")
datetime=$(date -u +'%Y-%m-%dT%H:%M:%S.000Z')
filepath="${path}${now}.json"
simplifiedjsonpath="${path}${now}_data.json"

pInfo ">> testing"
speedtest -u Mbps -f json-pretty > "$filepath"

pInfo ">> tranforming results"
downraw=$(jq -r '.download.bandwidth' $filepath)
download=$(printf %.2f\\n "$((downraw * 8))e-6")
upraw=$(jq -r '.upload.bandwidth' $filepath)
upload=$(printf %.2f\\n "$((upraw * 8))e-6")
latency=$(jq -r '.ping.latency' $filepath)
jitter=$(jq -r '.ping.jitter' $filepath)
packetLossData=$(jq -r '.packetLoss' $filepath)
isp=$(jq -r '.isp' $filepath)
externalIP=$(jq -r '.interface.externalIp' $filepath)
echo "packetLossData = $packetLossData"

if  [ $packetLossData = null ] || [ $packetLossData = 0 ] ; then
  packetloss=0
else
  packetloss=$(printf "%.3f" "$packetLossData")
fi

pInfo ">> creating simplified JSON file"
JSON='{"id": { "S": "'"$id"'" }, "date": { "S": "'"$datetime"'" } ,"download": { "S": "'"$download"'" }, "upload": { "S": "'"$upload"'" }, "latency": { "S": "'"$latency"'"}, "jitter": { "S": "'"$jitter"'" }, "packetLoss": { "S": "'"$packetloss"'"}, "isp": { "S": "'"$isp"'"}, "externalIP": { "S": "'"$externalIP"'"}}' 
echo "$JSON" > "${simplifiedjsonpath}"

pInfo ">> results: "
echo "download = $download Mbps"
echo "upload =  $upload Mbps"
echo "latency =  $latency ms"
echo "jitter = $jitter ms"
echo "packet loss = $packetloss %"

pInfo ">> Creating item in Database"
aws dynamodb put-item \
    --table-name link \
    --item file://"${simplifiedjsonpath}" \
    --return-consumed-capacity TOTAL \
    --no-cli-pager
    #--item '{"id": { "S": "'"$id"'" }, "date": { "S": "'"$datetime"'" } ,"download": { "S": "'"$download"'" }, "upload": { "S": "'"$upload"'" }, "latency": { "S": "'"$latency"'"}, "jitter": { "S": "'"$jitter"'" }, "packetLoss": { "S": "'"$packetloss"'"}, "isp": { "S": "'"$isp"'"}, "externalIP": { "S": "'"$externalIP"'"}}' \

pInfo ">> site: $id"
pInfo ">> Querying result"
aws dynamodb query \
    --table-name link \
    --key-condition-expression  '#id = :id' \
    --expression-attribute-values  '{":id":{"S": "'"$id"'"}}' \
    --expression-attribute-names '{"#id":"id"}' \
    --select "COUNT" \
    --no-cli-pager
    #--projection-expression "#date" \
    #--output table
    #--expression-attribute-names '{"#id":"id", "#date":"date"}' \

pInfo ">> cleaning up"
rm "${simplifiedjsonpath}"  "${filepath}"

pSuccess ">> Done!"



