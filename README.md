
# kubectl-plugins
A collection of plugins for kubectl integration

###### Note
- You can run these plugins without having to use kubectl's "plugin" command at runtime. Just, *"`kubectl ssh`"*, or *"`kubectl deploy`"*, for example.
- Some plugins require jq ( brew/apt/yum install jq )
- All coding was written to maintain compatibility across both BSD and GNU.
- The *deploy* plugin contains some in-house customizations. You'll want to adjust accordingly if using it as a template for your own work.

## Install on Linux/Mac
```bash
./install-kubectl-plugins
source ~/.bash_profile
```
*To remove, delete the ~/.kube/plugins folder and comment the entry (a one line kubectl function) in your bash_profile.*



 ### kubectl ssh
![ssh](https://user-images.githubusercontent.com/22456127/37712530-90db197e-2cea-11e8-8e3a-ae871ce481aa.gif)
- Like kubectl exec, but offers a --user flag to exec as root (or any other user)
- 'ssh' is a misnomer (it works by mounting a docker socket as a volume), but it's easier to work with as a command.
- Kudos to mikelorant for thinking of the docker socket! :)

*Example:* `bash kubectl ssh -u root rabbitmq-2`


### kubectl deploy
![deploy](https://user-images.githubusercontent.com/22456127/36905632-d3f22eca-1e01-11e8-8d65-33dd556c8544.gif)

Option | Required | Description | Example
------------- | ------------- | ------------- | -------------
[-f, --file] | y | File to deploy. | *`-f manifest.yml`*
[-i, --image] | n | Docker image to use. Overwrites what's set in the manifest. If an image is passed without a tag, it executes a search against the configured registry and prompts the user with list of images to choose from. | *`-i cassandra:3.7`* or *`-i cassandra`*
[-d, --dry] | n | Runs the command in dry-run mode. | *`-d true`*
[-n, --namespace] | n | Namespace/Environment to deploy to (defaults to current ns). | *`-n staging`*

*Combined Example:* `kubectl deploy -f cassandra.yml -i cassandra:3.7-r1 -n staging -d true`


 ### kubectl switch
![ssh](https://user-images.githubusercontent.com/22456127/37712867-84b950f6-2ceb-11e8-8959-289a6ff7a81e.gif)
- View current namespace: *`kubectl switch`*
- Switch namespace: *`kubectl switch preprod`*
- Switch cluster: *`kubectl switch cluster staging`*
  - Switching clusters requires the user add their project name in the switch.sh file.


### kubectl verify
- Non-interactive plugin that prompts users before executing a create/apply/deploy/delete command in a production namespace.
  - If you do not want this, change your ~/.bash_profile and remove the first "case in" of the function mentioning it.



### kubectl get-node-ip
![get-node-ip](https://user-images.githubusercontent.com/22456127/36905626-d2652a9e-1e01-11e8-87a8-9942fd5b2307.gif)
- Outputs the node location and IP for a given deployment/statefulset

Example: `kubectl get-node-ip cassandra`

### kubectl uptime
- Displays total uptime for pods/statefulsets in the user namespace.

Example: `kubectl uptime`
