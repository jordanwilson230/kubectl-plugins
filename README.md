
# kubectl-plugins
A collection of plugins for kubectl integration

###### Note
- You can run these plugins without having to use kubectl's "plugin" command at runtime. Just, *`kubectl ssh`*, or *`kubectl deploy`*, for example.
- Some plugins require jq ( brew/apt/yum install jq )
- All coding was written to maintain compatibility across both BSD and GNU.
- The *deploy* plugin contains some in-house customizations. You'll want to adjust accordingly if using it as a template for your own work.

## Install on Linux/Mac
### Kubectl version >= 1.12.0
Switch to bramch https://github.com/jordanwilson230/kubectl-plugins/tree/support-v1.12.0
Run the install script.

### Kubectl version < 1.12.0
```bash
./install-kubectl-plugins
source ~/.bash_profile
```
*To remove, delete the ~/.kube/plugins folder and comment the entry (a one line kubectl function) in your bash_profile.*



 ### kubectl ssh
![ssh](https://user-images.githubusercontent.com/22456127/37712530-90db197e-2cea-11e8-8e3a-ae871ce481aa.gif)
- Like kubectl exec, but offers a --user flag to exec as root (or any other user)
- Defaults to *root* user if no `--user` is passed.
- 'ssh' is a misnomer (it works by mounting a docker socket as a volume), but it's easier to work with as a command.
- Kudos to mikelorant for thinking of the docker socket! :)

*Usage:* `kubectl ssh <pod name>`

Option | Required | Description | Example
------------- | ------------- | ------------- | -------------
[-u, --user] | No | Specify user | *`kubectl ssh -u rabbitmq rabbitmq-2`*


### kubectl deploy
![deploy](https://user-images.githubusercontent.com/22456127/36905632-d3f22eca-1e01-11e8-8d65-33dd556c8544.gif)
\* *This plugin takes your current context and edits your yaml manifest (in memory only) according to the rules and vars defined for the targeted namespace. You will want to define those in the deploy.sh file. This process is performed automatically, and is sent to kubectl after parsing.*

Option | Required | Description | Example
------------- | ------------- | ------------- | -------------
[-f, --file] | y | File to deploy. | *`-f manifest.yml`*
[-i, --image] | n | Docker image to use. Overwrites what's set in the manifest. If an image is passed without a tag, it executes a search against the configured registry and prompts the user with list of images to choose from. | *`-i cassandra:3.7`* or *`-i cassandra`*
[-d, --dry] | n | Runs the command in dry-run mode. | *`-d true`*
[-n, --namespace] | n | Namespace/Environment to deploy to (defaults to current ns). | *`-n staging`*

*Combined Example:* `kubectl deploy -f cassandra.yml -i cassandra:3.7-r1 -n staging -d true`


 ### kubectl switch
![switch](https://user-images.githubusercontent.com/22456127/43997826-a0ad479c-9db4-11e8-8a62-32a083df2cac.gif)

- View current namespace: *`kubectl switch`*
- Switch namespace: *`kubectl switch <namespace>`*
- Switch cluster: *`kubectl switch cluster <cluster>`*
  - Switching clusters requires the user add their project name in the switch.sh file.
  - Tweak the file to use other shortcuts as you wish.


### kubectl verify
- Non-interactive plugin that prompts users before executing a create/apply/deploy/delete command in a production namespace.
  - If you do not want this, edit your ~/.bash_profile and remove ```command ~/.kube/plugins/verify/verify.sh "${@}" &&``` from the function (the function is put in your .bash_profile when the install script runs).


### kubectl get-node-ip
![get-node-ip](https://user-images.githubusercontent.com/22456127/36905626-d2652a9e-1e01-11e8-87a8-9942fd5b2307.gif)
- Outputs the node location and IP for a given deployment/statefulset

Example: `kubectl get-node-ip cassandra`

### kubectl uptime
- Displays total uptime for pods/statefulsets in the user namespace.

Example: `kubectl uptime`
