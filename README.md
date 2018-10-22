
# kubectl-plugins
A collection of plugins for kubectl integration (for Kubectl versions >= 1.12.0)

###### Note
- These plugins are for kubectl versions at or above 1.12.0 only. Check your version via ```kubectl version```
- For versions below 1.12.0, use the 1.11.0 branch.
- To upgrade your kubectl version via homebrew: ```brew upgrade kubectl```, or via gcloud: ```gcloud components update```
- Some plugins require jq ( brew/apt/yum install jq )
- All coding was written to maintain compatibility across both BSD and GNU.

## Install on Linux/Mac
```bash
git clone https://github.com/jordanwilson230/kubectl-plugins.git
cd kubectl-plugins
./install-kubectl-plugins.sh
source ~/.bash_profile
```
#### To Uninstall
```
rm -rf ~/.kube/plugins/jordanwilson230
ex '+g/function kubectl()/d' -cwq ~/.bash_profile
ex '+g/jordanwilson230/d' -cwq ~/.bash_profile
```


### kubectl ssh
![kapssh](https://user-images.githubusercontent.com/22456127/46683069-4152c100-cbbd-11e8-9db5-9fb319bb320b.gif)
- Like kubectl exec, but offers a --user flag to exec as root (or any other user)
- 'ssh' is a misnomer (it works by mounting a docker socket as a volume), but it's easier to work with as a command.
- Kudos to mikelorant for thinking of the docker socket! :)

Option | Required | Description | Example
------------- | ------------- | ------------- | -------------
[-p] | y | Pod name. The `-p` flag can be omitted if no other flags are passed (i.e., `kubectl ssh kafka-0`)| *`kubectl -p kafka-0`*
[-u] | n | User to exec as. Defaults to root | *`kubectl ssh -u kafka -p kafka-0`*
[-c] | n | Specify container within pod | *`kubectl ssh -c burrow-metrics -p kafka-0`*
[ -- ]| n | Command to execute. Defaults to /bin/sh | *`kubectl ssh kafka -- ls /etc/burrow`*
[-h] | n | Show usage | *`kubectl ssh -h`*


### kubectl switch
![switch](https://user-images.githubusercontent.com/22456127/47271118-50cdf480-d543-11e8-8e27-84d8909548b6.gif)
- View current namespace: *`kubectl switch`*
- Switch namespace: *`kubectl switch preprod`*
- Switch cluster: *`kubectl switch cluster staging`*
- List and select from all available clusters: *`kubeclt switch cluster -l`*

Option | Required | Description | Example
------------- | ------------- | ------------- | -------------
[-l] | n | List available clusters and prompts for selection. Can only be used when ```cluster``` is passed. | *`kubectl switch cluster -l`*
[-h] | n | Show usage | *`kubectl switch -h`*


### kubectl prompt
![prompt](https://user-images.githubusercontent.com/22456127/47271066-91793e00-d542-11e8-9a97-71f2457aef51.gif)
- Displays a warning prompt when issuing commands in a flagged cluster or namespace
- Commands that trigger the prompt include ```create, scale, delete, apply, etc.,```
- Flag a namespace: ```kubectl prompt add -n production```
- Flag a cluster: ```kubectl prompt add -c my-cluster```
- List flagged environments: ```kubectl prompt list```
- Clear flagged environments: ```kubectl prompt remove```
- View description: ```kubectl prompt```


### kubectl ip
![kap_ip](https://user-images.githubusercontent.com/22456127/46684546-1c604d00-cbc1-11e8-8b8f-9e2684e42121.gif)
- Outputs the node name, node IP, and Pod IP for a given resource. Search is performed against common labels (defaults to app, name, component)

Example: `kubectl ip cassandra`



### kubectl uptime
![kap_uptime](https://user-images.githubusercontent.com/22456127/46684550-22eec480-cbc1-11e8-8770-9a61c28179f4.gif)
- Displays total uptime for pods/statefulsets in the current namespace.

Example: `kubectl uptime`
