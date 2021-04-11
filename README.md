# k8s-java-heap

# Problem statement

* Scenario 1 - Running jdk below X without any restrictions
```
docker run -it openjdk:8u181  bash
...
java -XX:+PrintFlagsFinal -version | grep -Ei 'MaxHeapSize|MaxRAMFraction'
```
* Scenario 2 - Running jdk below X with quotas
```
docker run --memory=1g -it openjdk:8u181  bash
...
java -XX:+PrintFlagsFinal -version | grep -Ei 'MaxHeapSize|MaxRAMFraction'
```

## Solution

* Scenario 3 - Running jdk above X with quotas
```
docker run --memory=1g -it openjdk:8u191-jdk-alpine /bin/ash
...
java -XX:+PrintFlagsFinal -version | grep -Ei 'MaxHeapSize|MaxRAMFraction'
```

* Scenario 4 - Running jdk below X limiting heap space in the java command itself
```
docker run -it openjdk:8u181  bash
...
java -Xmx256M -XX:+PrintFlagsFinal -version | grep -Ei 'MaxHeapSize|MaxRAMFraction'

```
