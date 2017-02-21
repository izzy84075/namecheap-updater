#/bin/bash
function ipcheck {
        isdiff=1
        hostlist=$2
        ipaddressnew=`dig +short myip.opendns.com @resolver1.opendns.com`
        for host in ${hostlist[@]}
        do
                if [ $host == "@" ]; then
                        ipaddresscurrent=`nslookup $1 | grep Address | grep -v "#" | cut -f2 -d" "`
                else
                        ipaddresscurrent=`nslookup $host.$1 | grep Address | grep -v "#" | cut -f2 -d" "`
                fi
                diffcheck=`echo $ipaddresscurrent | grep -c $ipaddressnew`
                if [ $diffcheck -eq 0 ];then
                        isdiff=0
                fi
        done
}
function update {
        echo $2
        hostlist=$1
        for host in ${hostlist[@]}
        do
                echo $host
                response=`curl http://dynamicdns.park-your-domain.com/update?host=$host\&domain=$2\&password=$3`
                echo
                errorcount=`echo $response | perl -pe "s/.*\<errcount\>(\d+)\<\/ErrCount\>.*/\\$1/gi"`
                if [ $errorcount -gt 0 ]; then
                        echo $response >> /var/log/ddclient.err
                fi
        done

}
isdiff='1'

######################
#Copy and paste this code as many times as you need. Change the values in the hostlist for the a records you wish to update, the domain to your domain, and the password as given out by namecheap
hostlist=("@" "isde")
domain="meldaire.net"
password="abc..."
ipcheck $domain $hostlist
if [ $isdiff -eq 0 ]; then
        update $hostlist $domain $password
fi
###############################

