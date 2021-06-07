# Managing Java Heap size in Kubernetes

A guide on how to handle `Java Heap` (`jdk8`) size in `Kubernetes`.

## Problem statement

I have come across the topic for this article while managing `Java` microservices in a `Kubernetes` environment in a project where, due to limited access to external software, we were limited to an older `jdk` version. We found that, when using a `jdk` version below `8u191` to containerise `Java` microservices, the `JVM` does not pick up the limit quotas attributed to that container.

Consequently, before going any further, a disclaimer is required: if you are using a `jdk` version `8u191` or above, this article will probably not be relevant to you, but I find these sort of non-perfect world scenarios quite useful and please stick around for the recommendations section even if that is not your case. 

### Setup and how to replicate

If you want to verify the scenarios described below in your machine, you'll need the following:

* minikube installed 
* This git 
    * manifests in k8s/manifests/scenario-*.yml.
    * Cheat sheet bash script -  it will automatically replicate all the results presented below.

You'll need a way to evaluate the maximum `Java` heap size, which can be done using the following command:
```
java -XX:+PrintFlagsFinal -version | grep -Ei 'MaxHeapSize|MaxRAMFraction|version'
```

As I baseline, running the above command in my local machine yields `8589934592 Bytes`, which is `8 Gigabytes`, `25%` of the memory in my machine (`32GB`). 

![](./screenshots/scenario-0.jpg)

`25%` is the default `RAM` fraction for the `Java` maximum heap space. This fraction can be changed, which will be further discussed in sections below.

### Scenario 1: Running a `jdk` version below `8u191` inside unrestricted pod

In the first scenario (all Kubernetes manifest files are in the repository listed in the previous sections under `k8s`), we are running `jdk 8u191` and not imposing any limits.

![](./screenshots/scenario-1.jpg)

As we may be expecting, the result for the maximum `Java` heap space is `4198498304 Bytes` (`~4GB`), which is `25%` of the total memory allocated to my docker engine (which in turn is running a `Kubernetes` cluster using `minikube`, which in turn is running this pod)

### Scenario 2: Running a `jdk` version below `8u191` on a pod with a `1GB` memory limit

When deploying to enterprise `Kubernetes` clusters, good practice dictates we should attribute quotas to our pods/deployments/... (sometimes this is even strongly enforced). To do that, we use a `resources` block in our `Kubernetes` manifest file:

```yaml
      resources:
        limits:
          memory: "1Gi"
        requests:
          memory: "600Mi"
```

![](./screenshots/scenario-2.jpg)

In the second scenario, we are also running `jdk 8u191` and, unfortunately, the `JVM` does not pick up the quotas attributed to the pod, which is what motivated this article.

## Solution

### Scenario 3: Running `jdk` version `8u191` on a pod with a `1GB` memory limit

The first step is to actually show that this is not an issue if you are running `jdk` version `8u191` or above (again, please stick around for the recommendations section).

If we use a similar setup (resources block in the manifest file for a pod) but this time running `jdk` version `8u191`.

![](./screenshots/scenario-3.jpg)

We can see that the `JVM` is able to detect the limits correctly, attributing a `Java` maximum heap size of `25%` of the memory available to the pod.

### Scenario 4: Running a `jdk` version below `8u191` inside unrestricted pod with `JVM` command line option

If we go back to the pod setup in the first scenario, unrestricted with a jdk version X

![](./screenshots/scenario-4.jpg)

### Alternative solution - experimental parameter

From reference [1], it is also mentioned that from `JDK 8u131+`, there’s an  experimental `VM` option that allows the `JVM` ergonomics to read the memory values from `CGgroups`, which is an alternative solution you can explore. I am not going into detail regarding this solution here.

## Recommendations

Hybrid solution
RECOMMENDATION:

BOTH - UPDATE MEMORY AND CHANGE THE RATIO: HOW MUCH YOU CHANGE CAN ONLY COME FROM EXPERIENCE


## References

[1] [Java inside docker: What you must know to not FAIL](https://developers.redhat.com/blog/2017/03/14/java-inside-docker/)




RAM FRACTION 1/4 IS TOO LITTLE - WE DON'T NEED SO MUCH SYSTEM RESOURCES RUNNING JAVA IN CONTAINERS

https://stackoverflow.com/questions/49854237/is-xxmaxramfraction-1-safe-for-production-in-a-containered-environment THIS POST TALKS ABOUT STARTING WITH A 1/2 FRACTION IS SAFE(ISH)


