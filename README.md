## POC Sealed Secrets

### Overview
Proof of concept with the objective of showing an alternative to store sensitive data in the template **[Secrets Kubernetes](https://kubernetes.io/pt-br/docs/concepts/configuration/secret/)** an encrypted way, so that we can leave it recorded inside some git repository (github, gitlab etc).

### Problem
We can't expose sensitive data just encoded in our git repositories.

### Solution
Encrypt the sensitive data contained in the template secret Kubernetes using SealedSecret.  
"The SealedSecret can be decrypted only by the controller running in the target cluster and nobody else (not even the original author) is able to obtain the original Secret from the SealedSecret."

### Requirements
* [Docker](https://docs.docker.com/engine/install/)
* [Kind](https://kind.sigs.k8s.io/)
* [Kubectl](https://kubernetes.io/docs/reference/kubectl/kubectl/)
* [Helm](https://helm.sh/)
* [Kubeseal](https://github.com/bitnami-labs/sealed-secrets)  
* [Make](https://tldp.org/HOWTO/Software-Building-HOWTO-3.html)

### Testing
Create a cluster with registry:
```
$ make create-cluster-with-registry 
```
Check the status of the cluster and registry:
```
$ docker ps
```
Expected:
```
CONTAINER ID        IMAGE                  COMMAND                  CREATED             STATUS              PORTS                       NAMES
fca935967b37        kindest/node:v1.19.1   "/usr/local/bin/entr…"   11 hours ago        Up 6 hours          127.0.0.1:33087->6443/tcp   kind-control-plane
17ef425d81a6        registry:2             "/entrypoint.sh /etc…"   11 hours ago        Up 6 hours          127.0.0.1:5000->5000/tcp    kind-registry
```

Install the Custom Controller and CRD (Custom Resource Definition) for SealedSecret:
```
$ make install-controller-kubeseal
```
Check the status of the controller pod:
```
$ kubectl get pods -n kube-system | grep sealed-secrets-controller
```
Expected:
```
sealed-secrets-controller-5556b8c9bd-wt95s   1/1     Running   1          10h
```
Create SealedSecret YAML manifests with Kubeseal:  
* Use the template **/tools/basesecret.yaml** with example.
```
make create-secrets-kubeseal
```
Expected type:
```
apiVersion: bitnami.com/v1alpha1
kind: SealedSecret
metadata:
  creationTimestamp: null
  name: poc-sealed-secrets
  namespace: default
spec:
  encryptedData:
    application.yaml: AgAV97KIg5vkhdCa5fGvmvVrkGyIHXh25ULDdwiL6E7p3SoCb15m8VaiMhqO0bjnrC2bnQHjaR4qe6oCwOx8OnoIyxoQYTMrHCFnhf8XAmxdUTS3O1LgZm6sdSnZ7GkgKc017NvlKKmOwxDuk9bK+uu1kEhCickK61FkGXULeJMgVWl74y2NhH1CY142LoSX5WylVFjCKV6qJd3EKDP0V5SqOpDFkFKaSOI5xxXmF8CGtgj7sGmaFYf63y1oHBG6HWNEenz2wFlQPGpDPBwLsRZo7I1WjWj6R0GDnJTjVzibok6HMxpU+6oxtFE+Bfx36h+oy9ncPneYGjJLU0J7poqlVVVmNV93pNsr6FjA+LZqEXbuVIbvbx7DdDz3+IoqteYm6tSV4ylbUUaNsj5aR0hNrfGkJubzQA2PmgtT8I/JEaAvv3rj6Q0G+4xSLIzv+T5NlttNul2NL4x5HImFZXosIgtp6IJlMs47G31Xhvku65e4liKr0nYO4H/BXWig1EWdXs0JIk8pKwGvCLFQ+FtoHbSNJUFaGWImi9k2WMK49K6593eNHDKe/biUut+NLAe47O5/mKu5l1aPsGZTQZ6+tGzlFg68xE1YFJ2DfvVBsiGmNfGazTncW+eC/wpbhs66gd5HOohfn98K4jDyxg4DY2fBKsU0H+5WcjAP/nbe6JZGkbLWHK06vGRqX9XNN3w3glNkdTLHOxzif/gXXH3GIs7XhDE39iQ7V8oU5y7a7GDy
  template:
    data: null
    metadata:
      creationTimestamp: null
      name: poc-sealed-secrets
      namespace: default
    type: Opaque
```
Build poc and generate image:
```
$ make docker-build 
```
Push image a local registry:
```
$ make docker-push
```
Create deployment
```
$ make create-deployment
```
Check deployment:
```
$ kubectl get pods
```
Expected:
```
NAME                                  READY   STATUS    RESTARTS   AGE
poc-sealed-secrets-6b8784df75-xwxbn   1/1     Running   0          5h30m
```
Test decryption:
```
kubectl logs poc-sealed-secrets-6b8784df75-xwxbn
```
Expected:
```
 __  __ _                                  _   
|  \/  (_) ___ _ __ ___  _ __   __ _ _   _| |_ 
| |\/| | |/ __| '__/ _ \| '_ \ / _` | | | | __|
| |  | | | (__| | | (_) | | | | (_| | |_| | |_ 
|_|  |_|_|\___|_|  \___/|_| |_|\__,_|\__,_|\__|
  Micronaut (v2.5.13)

18:27:12.634 [main] INFO  i.m.context.env.DefaultEnvironment - Established active environments: [k8s, cloud]
18:27:13.303 [main] INFO  com.example.POCSealedSecrets - [com.example.POCSealedSecrets] - sensitive data: data encrypted
18:27:13.304 [main] INFO  io.micronaut.runtime.Micronaut - Startup completed in 747ms. Server Running: http://poc-sealed-secrets-6b8784df75-xwxbn:8080
```

### References
- [Sealed Secrets Github](https://github.com/bitnami-labs/sealed-secrets#installation)
