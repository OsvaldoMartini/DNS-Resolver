

# Bind9
[Ubuntu/Bind9](https://hub.docker.com/r/ubuntu/bind9)
[Bind9/ Youtube](https://youtu.be/syzwLwE3Xq4?list=PL1tIv2QQSZeh1dcbhJlrc4nWaGw-O0-ed)

## Kubernetes Bind9

```bash
    kubectl apply -f bind9-deployment.yml
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