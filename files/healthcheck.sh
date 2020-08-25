if [[ ! -z $DDNS ]];
then
	checkIP=$(getent hosts $DDNS | awk '{ print $1 }')
else
	checkIP=$IP
fi

if [[ ! -z $checkIP ]];
then
	ipinfo=$(curl -s -H "Authorization: Bearer $BEARER" 'ipinfo.io' | jq -r '.')
	currentIP=$(jq -r '.ip' <<< "$ipinfo")
	hostname=$(jq -r '.hostname' <<< "$ipinfo")

	if [[ $checkIP = $currentIP ]];
	then
		if [[ ! -z $HEALTHCHECK ]];
		then
			curl https://hc-ping.com/$HEALTHCHECK/fail
			expressvpn disconnect
			expressvpn connect $SERVER
			exit 1
		else
			expressvpn disconnect
			expressvpn connect $SERVER
			exit 1
		fi
	else
		if [[ ! -z $HOSTNAME_PART && ! -z $hostname && $hostname = *"$HOSTNAME_PART"* ]];
		then
			curl https://hc-ping.com/$HEALTHCHECK/fail
			expressvpn disconnect
			expressvpn connect $SERVER
			exit 1
		fi

		if [[ ! -z $HEALTHCHECK ]];
		then
			curl https://hc-ping.com/$HEALTHCHECK
			exit 0
		else
			exit 0
		fi
	fi
else
	exit 0
fi
