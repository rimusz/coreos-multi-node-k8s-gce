#!/bin/bash
ssh-add ~/.ssh/google_compute_engine &>/dev/null
# Setup Client SSH Tunnels

# GC project
project=$(cat bootstrap_k8s_cluster.sh | grep project= | head -1 | cut -f2 -d"=")
# master name
master_name=$(cat bootstrap_k8s_cluster.sh | grep master_name= | head -1 | cut -f2 -d"=")

# get master internal IP
master_external_ip=$(gcloud compute instances list --project=$project | grep -v grep | grep $master_name | awk {'print $5'});

# SET
# path to the bin folder where we store our binary files
export PATH=${HOME}/k8s-bin:$PATH
# fleet tunnel
export FLEETCTL_TUNNEL="$master_external_ip"
export FLEETCTL_STRICT_HOST_KEY_CHECKING=false
# etcd
ssh -f -nNT -L 2379:127.0.0.1:2379 core@$master_external_ip
# k8s master
ssh -f -nNT -L 8080:127.0.0.1:8080 core@$master_external_ip

echo " "
etcdctl --no-sync ls /

echo " "
fleetctl list-units

echo " "
kubectl get nodes

echo " "
echo "Type exit when you are finished ..."
/bin/bash

echo "stoping ssh forwarding !!!"
# kill ssh forwarding
kill $(ps aux | grep -v grep | grep "ssh -f -nNT -L 8080:127.0.0.1:8080" | awk {'print $2'})
kill $(ps aux | grep -v grep | grep "ssh -f -nNT -L 2379:127.0.0.1:2379" | awk {'print $2'})
