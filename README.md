# kubectl-plugins
[![CI Status](https://github.com/jordanwilson230/kubectl-plugins/workflows/CI/badge.svg)](https://github.com/jordanwilson230/kubectl-plugins/actions)

A collection of plugins for kubectl integration (for Kubectl versions >= 1.12.0)

*A portion of these plugins are available on [krew](https://github.com/kubernetes-sigs/krew) as well.*

###### Note
- These plugins are for kubectl versions at or above 1.12.0 only. Check your version via ```kubectl version```
- For versions below 1.12.0, use the 1.11.0 branch.
- To upgrade your kubectl version via homebrew: ```brew upgrade kubectl```, or via gcloud: ```gcloud components update```
- The kubectl-ip plugin requires jq ( brew/apt/yum install jq )
- All coding was written to maintain compatibility across both BSD and GNU.
- Requires Bash.

## Install on Linux/Mac
```bash
git clone https://github.com/jordanwilson230/kubectl-plugins.git
cd kubectl-plugins
./install-plugins.sh
source ~/.bash_profile
```
#### To Uninstall
```
rm -rf ~/.kube/plugins/jordanwilson230
ex '+g/jordanwilson230/d' -cwq ~/.bash_profile
```
Remove the ```image``` plugin:
```
ex '+g/IMG_REGISTRY=/d' -cwq ~/.bash_profile
```
Remove the ```prompt``` plugin:
```
ex '+g/function kubectl()/d' -cwq ~/.bash_profile
ex '+g/KUBECTL_\(.*\)_PROMPT/d' -cwq ~/.bash_profile
```


### kubectl ssh
![kapssh](https://user-images.githubusercontent.com/22456127/46683069-4152c100-cbbd-11e8-9db5-9fb319bb320b.gif)
- Like kubectl exec, but offers a --user flag to exec as root (or any other user)
- 'ssh' is a misnomer (it works by mounting a docker socket as a volume), but it's easier to work with as a command.
- You must be in the same namespace as the target pod or you can use ```-n namespace``` option to specify the namespace
- Kudos to mikelorant for thinking of the docker socket! :)

Usage: ```kubectl ssh [OPTIONS] <pod name> [-- <commands...>]```

Option | Required | Description | Example
------------- | ------------- | ------------- | -------------
-h | N | Show usage | *`kubectl ssh -h`*
-d | N | Enable debug mode. Print a trace of each commands |  *`kubectl ssh -d kafka-0`*
-n | N | The namespace scope for this CLI request | *`kubectl ssh -n infra kafka-0`*
-u | N | User to exec as. Defaults to root | *`kubectl ssh -u kafka kafka-0`*
-c | N | Specify container within pod | *`kubectl ssh -c burrow-metrics kafka-0`*
-- | N | Pass an optional command. Defaults to /bin/sh | *`kubectl ssh kafka -- ls /etc/burrow`*


### kubectl switch
![switch](https://user-images.githubusercontent.com/22456127/47271118-50cdf480-d543-11e8-8e27-84d8909548b6.gif)
- View current namespace: *`kubectl switch`*
- Switch namespace: *`kubectl switch preprod`*
- Switch cluster: *`kubectl switch cluster staging`* (accepts fuzzy on the cluster name)
- List and select from all available clusters: *`kubeclt switch cluster -l`*

Option | Required | Description | Example
------------- | ------------- | ------------- | -------------
-l | N | List available clusters and prompts for selection. Can only be used when ```cluster``` is passed. | *`kubNctl switch cluster -l`*
-h | N | Show usage | *`kubectl switch -h`*


### kubectl prompt
![prompt](https://user-images.githubusercontent.com/22456127/47271066-91793e00-d542-11e8-9a97-71f2457aef51.gif)
- Displays a warning prompt when issuing commands in a flagged cluster or namespace
- Commands that trigger the prompt include ```create, scale, delete, apply, etc.,```
- Flag a namespace: ```kubectl prompt add -n production```
- Flag a cluster: ```kubectl prompt add -c my-cluster```
- List flagged environments: ```kubectl prompt list```
- Clear flagged environments: ```kubectl prompt remove```
- View description: ```kubectl prompt```


### kubectl image
![image](https://user-images.githubusercontent.com/22456127/53746358-02285380-3e6f-11e9-901f-abc1a824b6c7.gif)
- Search for Docker images
- If you have a Google Container Registry, run ```kubectl image -c``` to set it as the default for future searches.
- If _not_ configured with ```-c```, searches will use Docker Hub by default.
- Adding ```-p``` will search Docker Hub, regardless of any default.
- Sorts Docker Hub images by number of stars.
- Sorts GCR images by upload date.

Example:
```kubectl image kafka```

### kubectl ip
![kap_ip](https://user-images.githubusercontent.com/22456127/46684546-1c604d00-cbc1-11e8-8b8f-9e2684e42121.gif)
- Outputs the node name, node IP, and Pod IP for a given resource. Search is performed against common labels (defaults to app, name, component)

Example: `kubectl ip cassandra`



### kubectl uptime
![kap_uptime](https://user-images.githubusercontent.com/22456127/46684550-22eec480-cbc1-11e8-8770-9a61c28179f4.gif)
- Displays total uptime for pods/statefulsets in the current namespace.

Example: `kubectl uptime`
