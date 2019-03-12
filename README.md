# kubectl-plugins
A collection of plugins installable via [Krew](https://github.com/GoogleContainerTools/krew)

###### Note
- All coding was written to maintain compatibility across both BSD and GNU.

#### Installing with Krew
```
kubectl krew install exec-as
kubectl krew install fimages
kubectl krew install prompt
```

#### To Uninstall
```
kubectl krew remove exec-as
```
To remove the fimages plugin:
```
kubectl krew remove fimages
ex '+g/IMG_REGISTRY=/d' -cwq ~/.bash_profile
```
To remove the prompt plugin:
```
kubectl krew remove prompt
ex '+g/function kubectl()/d' -cwq ~/.bash_profile
ex '+g/KUBECTL_\(.*\)_PROMPT/d' -cwq ~/.bash_profile
```


## kubectl exec-as
![exec](https://user-images.githubusercontent.com/22456127/54227565-97ae8d80-44d6-11e9-907c-8297a8b54010.gif)
- Like kubectl exec, but offers a --user flag to exec as root (or any other user)
- Works by mounting a docker socket as a volume
- Kudos to mikelorant for thinking of the docker socket! :)

Option | Required | Description | Example
------------- | ------------- | ------------- | -------------
-h | N | Show usage | *`kubectl exec-as -h`*
-p | Y | Pod name. The `-p` flag can be omitted if no other flags are passed (i.e., `kubectl exec-as rabbitmq-0`)| *`kubectl exec-as -p rabbitmq-0`*
-u | N | User to exec as. Defaults to root | *`kubectl exec-as -u rabbitmq -p rabbitmq-0`*
-c | N | Specify container within pod | *`kubectl exec-as -c my-container -p rabbitmq-0`*
-- | N | Pass an optional command. Defaults to /bin/sh | *`kubectl exec-as rabbitmq-0 -- ls /etc/rabbitmq`*


## kubectl fimages
![fimages](https://user-images.githubusercontent.com/22456127/54236801-dc442400-44ea-11e9-9fc8-107ed3377999.gif)
- Find and sort Docker images
- If you have a Google Container Registry, run ```kubectl fimages -c``` to set it as the default for future searches.
- If _not_ configured with ```-c```, searches will use Docker Hub by default.
- Adding ```-p``` will search Docker Hub, regardless of any default.
- Sorts Docker Hub images by number of stars.
- Sorts GCR images by upload date.

Example:
```kubectl fimages kafka```


## kubectl prompt
![prompt](https://user-images.githubusercontent.com/22456127/47271066-91793e00-d542-11e8-9a97-71f2457aef51.gif)
- Displays a warning prompt when issuing commands in a flagged cluster or namespace
- Commands that trigger the prompt include ```create, scale, delete, apply, etc.,```

Start by flagging environments to prompt on:
- Flag a namespace:
```kubectl prompt add -n production```
- Flag a cluster:
```kubectl prompt add -c my-cluster```
- List flagged environments:
```kubectl prompt list```
- Clear flagged environments:
```kubectl prompt remove```
- View description:
```kubectl prompt```
