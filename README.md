# k8s-cli

This is just an example client for Kubernetes.

## Service account
In order to make that work a Service Account needs to be set up. A HowTo can be found on the docker website: [Create a service account for a Kubernetes app
](https://docs.docker.com/ee/ucp/kubernetes/create-service-account/#where-to-go-next)

## Generate Token/ca.crt

In order for the app to work a token and a ca.crt needs to be generated. In the following example the ServiceAccount is called `default`:

```
$ export K8S_SECRET=$(kubectl get serviceaccounts default -o json |jq -r '.secrets[].name')
$ mkdir -p k8s
$ kubectl get secret ${K8S_SECRET} -ojson | jq -r '.data["ca.crt"]' | base64 -D > k8s/ca.crt
$ kubectl get secret ${K8S_SECRET} -ojson | jq -r '.data["token"]' | base64 -D > k8s/token
```

Since the DockerEE installation does not have a valid SSL cert, the `ca.crt` is not used, even though it should. >:)

## Deploy

First the image is build on the target system.

```
$ DOCKER_BUILDKIT=0 docker build -t qnib/$(basename $(pwd)) .
  Sending build context to Docker daemon  12.26MB
```

And deployed..


```
$ docker-app deploy --orchestrator=kubernetes -s k8s.host=ec2-xx-xx-xx-xx.eu-west-1.compute.amazonaws.com -s k8s.namespace=default
```

## Tear Down

```
$ kubectl delete stack k8s-cli
stack.compose.docker.com "k8s-cli" deleted
```

## TODO

The above fails with the error message:

```
$ kubectl logs pod/cli-6db88c97fc-rtxp6
There are 0 pods in the cluster
Creating deployment...
panic: the server could not find the requested resource

goroutine 1 [running]:
main.main()
 	/go/src/github.com/qnib/k8s-cli/main.go:77 +0xcf4
```

So the listing works fine, but the pod creation fails.. :/