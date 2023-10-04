

# Bind9
[Bind9/ Workable Version](https://mpolinowski.github.io/docs/DevOps/Provisioning/2022-01-25--installing-bind9-docker/2022-01-25/)

## Create Docker Network subnet

```bash
    docker network create --subnet=172.24.0.0/16 instar-net

    docker network create --subnet=172.25.0.0/16 instar-net


    docker network ls --format "{{.Name}}" | while read i; do echo $i --- $(docker network inspect $i | grep Subnet); done

    docker network inspect $(docker network ls -q)|grep -E "IPv(4|6)A"

```

## Build the Docker Image
```bash
    docker build -t ddns-master .
```

## Run the Container
```bash
    docker run -d --rm --name=ddns-master --net=instar-net --ip=172.25.0.2 ddns-master
```

## Veriry My Server configuration
```bash
I   # Connect to the container
    docker exec -ti ddns-master /bin/bash 
    
    named-checkconf
    
    # Connect to the container
    named-checkzone instar-net.io /etc/bind/zones/db.instar-net.io
    
    zone instar-net.io/IN: loaded serial 3
    
    OK
```


## Connecting Services
```bash

docker run -d --rm --name=service1 --net=instar-net --ip=172.24.0.3 --dns=172.24.0.2 nginx:1.21.6-alpine /bin/ash -c "while :; do sleep 10; done"

docker run -d --rm --name=service2 --net=instar-net --ip=172.24.0.4 --dns=172.24.0.2 nginx:1.21.6-alpine /bin/ash -c "while :; do sleep 10; done"

```

## Testing: I can test the DNS Service by connecting to one of the client service and ping the other
```bash
    
    docker exec -it service1 nslookup service2.instar-net.io                                                         
    
    Server:         127.0.0.11
    Address:        127.0.0.11:53

    Name:   service2.instar-net.io
    Address: 172.24.0.4

```

## Forwarded: Also the forwarder is doing it's job allowing me to resolve domains outside of the defined zone
```bash

    docker exec -it service1 nslookup service2.instar-net.io                                                         

    Server:         127.0.0.11
    Address:        127.0.0.11:53

    Name:   service2.instar-net.io
    Address: 172.24.0.4

```

## NSLookUp
```bash
    nslookup youtube.com 10.20.3.4


    # Should Return
    Server:     10.20.3.4
    aDDRESS:    10.20.3.4#53

    Non-authoritative answer:
    Name: youtube.com
    Address 64.233.166.93
    Name: youtube.com
    Address 64.233.166.190
    Name: youtube.com
    Address 64.233.166.913
    Name: youtube.com
    Address 64.233.166.136
    
```
## Scale Delete Pod
```bash
    # If you want to simulate what happens if one of the pods just gets lost, you can scale down the deployment
    # and Kubernetes will terminate all but one of the pods; 
    # you should almost immediately see all of the traffic going to the surviving pod.

    kubectl scale deployment bind9-deployment.yml --replicas=1
    
But if instead you want to simulate what happens if one of the pods crashes and restarts, you can delete the pod

# kubectl scale deployment the-deployment-name --replicas=2
kubectl get pods
kubectl delete pod the-deployment-name-12345-f7h9j
```


## Throubleshoting
```bash
  vim /etc/systemd/resolved.conf

  # Stop to Linster 53 Externaly in your Liunux System/Mac OS etc.
  ...
  ...DNSStubListener=no

# Restart the System

sudo systemclt restart systemd-resolved

```

## Installs
```bash
   apt-get update

   apt-get -y upgrade

   # Install some Tools and Softwares
   apt-get -y install nano vim tar wget default-jre

   # Install Kafka
   wget https://downloads.apache.org/kafka/3.4.1/kafka_2.12-3.4.1.tgz

   # untar
   tar -xzvf kafka_2.12-3.4.1.tgz
  
   # remove zip file
   rm -rf kafka_2.12-3.4.1.tgz

   Get the AWS IAM Connector
   # Kafka can connects via IAM
   wget https://github.com/aws/aws-msk-iam-auth/releases/download/v1.1.6/aws-msk-iam-auth-1.1.6-all.jar
  
   # Move to Kafka /libs
   mv aws-msk-iam-auth-1.1.6-all.jar kafka_2.12-3.4.1/libs

   # Authentication Kafka credentials
    nano kafka_2.12-3.4.1/client.properties 
 
	security.protocol=SASL_SSL
	sasl.mechanism=AWS_MSK_IAM
	sasl.jaas.config=software.amazon.msk.auth.iam.IAMLoginModule required;
	sasl.client.callback.handler.class=software.amazon.msk.auth.iam.IAMClientCallbackHandler

   or
	
	printf 'security.protocol=SASL_SSL  \n
	sasl.mechanism=AWS_MSK_IAM              \n
	sasl.jaas.config=software.amazon.msk.auth.iam.IAMLoginModule required;    \n
	sasl.client.callback.handler.class=software.amazon.msk.auth.iam.IAMClientCallbackHandler' >> kafka_2.12-3.4.1/client.properties

    export AWS_ACCESS_KEY_ID=AKIAUF3KVCK7PFGQR23Y
    export AWS_SECRET_ACCESS_KEY=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

    # Create topic
    ./kafka_2.12-3.4.1/bin/kafka-topics.sh --create --bootstrap-server <bootstrap-servers> --replication-factor 2 --partitions 1 --topic <topic-name> --command-config ./kafka_2.12-3.4.1/client.properties


``````