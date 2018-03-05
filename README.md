
**_Quick Note_**
- *The master branch has many customizations for our in-house needs here at BitBrew. Use the develop branch, unless you're from BitBrew :) *
- *You can run these plugins without having to use kubectl's "plugin" command at runtime. Just, "kubectl ssh, or kubectl deploy", for example.*
- *All coding was written to maintain compatibility across both BSD and GNU.*
- *Also, any/all PRs for this readme file will be instantly and automatically merged, ;P*

# kubectl-plugins

A collection of plugins for kubectl integration
 - Requires jq ( brew install jq )

## Install on Linux
  Just run the install-kubectl-plugins script and source your ~/.bash_profile!
  
## Install via homebrew: 
  **brew tap bitbrew/kubectl-plugins; brew install kubectl-plugins; install-kubectl-plugins**

### kubectl deploy [options]
![deploy](https://user-images.githubusercontent.com/22456127/36905632-d3f22eca-1e01-11e8-8d65-33dd556c8544.gif)

   [-f, --file] (Ex: -f 20-actions.yml) File to deploy. At this time, only accepts a single file. Required.
  
   [-i, --image] (Optional. Ex: -i kafka:v1.0.0 **or** -i kafka) Docker image/tag to use. Overwrites what's set in the manifest. If only the image name is passed, it displays a list of images to choose from. Optional.
  
   [-d, --dry] (Ex: -d true) Runs the command in dry-run mode. Optional.
  
   [-n, --namespace] (Ex: -n preprod) Namespace/Environment to deploy to (defaults to current ns). Optional
   
   Example: kubectl deploy -f 40-actions.yml -i actions -n staging


 ### kubectl uptime
  - Displays total uptime for pods/statefulsets in the user namespace.


 ### kubectl switch [options]
![switch](https://user-images.githubusercontent.com/22456127/36905617-cd540052-1e01-11e8-86a1-d0fc6cccf6a2.gif)

  - View current namespace: kubectl switch
  - Switch namespace: kubectl switch preprod
  - Switch cluster: kubectl switch cluster


 ### kubectl get-node-ip
![get-node-ip](https://user-images.githubusercontent.com/22456127/36905626-d2652a9e-1e01-11e8-87a8-9942fd5b2307.gif)
  - Outputs the node location and IP for a given application e.g., kubectl get-nodes ingestion
  
  - Usage: kubectl get-node-ip (app or statefulset name)


 ### kubectl ssh
 ![ssh](https://user-images.githubusercontent.com/22456127/36905621-d0c89ff4-1e01-11e8-969e-6ad5e8767b92.gif)
  - Like kubectl exec, but offers a --user flag to exec as root (or any other user) if you're running in GKE
  
  - Usage: kubectl ssh -p pod-name -u user
  
  -- *Requires that you have uploaded your ssh key to GCP or access will be denied! https://console.cloud.google.com/compute/metadata/sshKeys*
