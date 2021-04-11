#!/bin/bash

minikube start
sleep 10
kubectl apply -R -f ./k8s/manifests/
# You may need a longer sleep here, depends on your internet connection, pods need to running before executing the commands below this
sleep 30
kubectl exec -it scenario-1 -- java -XX:+PrintFlagsFinal -version | grep -Ei 'MaxHeapSize|MaxRAMFraction|version'
kubectl exec -it scenario-2 -- java -XX:+PrintFlagsFinal -version | grep -Ei 'MaxHeapSize|MaxRAMFraction|version'
kubectl exec -it scenario-3 -- java -XX:+PrintFlagsFinal -version | grep -Ei 'MaxHeapSize|MaxRAMFraction|version'
kubectl exec -it scenario-1 -- java -Xmx256M -XX:+PrintFlagsFinal -version | grep -Ei 'MaxHeapSize|MaxRAMFraction|version'
minikube delete