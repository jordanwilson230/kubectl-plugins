
# kubectl-plugins
A collection of plugins for kubectl integration (for Kubectl versions >= 1.12.0)

###### Note
- These plugins are for kubectl versions at or above 1.12.0 only. Check your version via ```kubectl version```
- For versions below 1.12.0, use the 1.11.0 branch.
- To upgrade your kubectl version via homebrew: ```brew upgrade kubectl```, or via gcloud: ```gcloud components update```
- The kubectl-ip plugin requires jq ( brew/apt/yum install jq )
- All coding was written to maintain compatibility across both BSD and GNU.

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


### kubectl exec-as
![exec](https://user-images.githubusercontent.com/22456127/54227565-97ae8d80-44d6-11e9-907c-8297a8b54010.gif)
- Like kubectl exec, but offers a --user flag to exec as root (or any other user)
- Works by mounting a docker socket as a volume.
- You must be in the same namespace as the target pod (passing ```-n namespace``` is not currently allowed).
- Kudos to mikelorant for thinking of the docker socket! :)

Option | Required | Description | Example
------------- | ------------- | ------------- | -------------
-h | N | Show usage | *`kubectl exec-as -h`*
-p | Y | Pod name. The `-p` flag can be omitted if no other flags are passed (i.e., `kubectl exec-as kafka-0`)| *`kubectl -p kafka-0`*
-u | N | User to exec as. Defaults to root | *`kubectl exec-as -u kafka -p kafka-0`*
-c | N | Specify container within pod | *`kubectl exec-as -c burrow-metrics -p kafka-0`*
-- | N | Pass an optional command. Defaults to /bin/sh | *`kubectl exec-as kafka -- ls /etc/burrow`*


### kubectl switch
![switch](https://user-images.githubusercontent.com/22456127/47271118-50cdf480-d543-11e8-8e27-84d8909548b6.gif)
- View current namespace: *`kubectl switch`*
- Switch namespace: *`kubectl switch preprod`*
- Switch cluster: *`kubectl switch cluster staging`*
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
=======
  Just run the install-plugins script and source your ~/.bash_profile!
  To remove, delete the ~/.kube/plugins folder and comment the entry (a one line kubectl function) in your bash_profile.
  
 ### kubectl ssh
 ![ssh](https://user-images.githubusercontent.com/22456127/37712530-90db197e-2cea-11e8-8e3a-ae871ce481aa.gif)
  - Like kubectl exec, but offers a --user flag to exec as root (or any other user)
  - 'ssh' is a misnomer (it works by mounting a docker socket as a volume), but it's easier to work with as a command.
  - Kudos to mikelorant for thinking of the docker socket! :)
  - Usage: kubectl ssh -u root zookeeper-1


### kubectl deploy [options]
![deploy](https://user-images.githubusercontent.com/22456127/36905632-d3f22eca-1e01-11e8-8d65-33dd556c8544.gif)

   [-f, --file] (Ex: -f 20-actions.yml) File to deploy. At this time, only accepts a single file. Required.
  
   [-i, --image] (Optional. Ex: -i kafka:v1.0.0 **or** -i kafka) Docker image/tag to use. Overwrites what's set in the manifest. If only the image name is passed, it displays a list of images to choose from. Optional.
  
   [-d, --dry] (Ex: -d true) Runs the command in dry-run mode. Optional.
  
   [-n, --namespace] (Ex: -n preprod) Namespace/Environment to deploy to (defaults to current ns). Optional
   
   Example: kubectl deploy -f 40-actions.yml -i actions -n staging


 ### kubectl switch [options]
![ssh](https://user-images.githubusercontent.com/22456127/37712867-84b950f6-2ceb-11e8-8959-289a6ff7a81e.gif)
  - View current namespace: kubectl switch
  - Switch namespace: kubectl switch preprod
  - Switch cluster: kubectl switch cluster staging (cluster switching requires the user add their project name in the switch.sh file).

### kubectl verify
  - Non-interactive plugin that prompts users before executing a create/apply/deploy/delete command in a production namespace.
  - If you do not want this, change your ~/.bash_profile and remove the first "case in" of the function mentioning it.


 ### kubectl get-node-ip
![get-node-ip](https://user-images.githubusercontent.com/22456127/36905626-d2652a9e-1e01-11e8-87a8-9942fd5b2307.gif)
  - Outputs the node location and IP for a given application e.g., kubectl get-nodes rabbitmq
  
  - Usage: kubectl get-node-ip (app or statefulset name...not the pod name)


 ### kubectl uptime
  - Displays total uptime for pods/statefulsets in the user namespace.
