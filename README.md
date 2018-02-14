
**_Quick Note_**

*You can run these plugins without having to use kubectl's "plugin" command at runtime. Just, "kubectl ssh, or kubectl deploy", for example.*

*All coding was written to maintain compatibility across both BSD and GNU.*

*Some bits are tailored to fit our in-house needs here at BitBrew, but nothing major.*

*Also, any/all PRs for this readme file will be instantly and automatically merged, ;P*


# kubectl-plugins

A collection of plugins for kubectl integration
 - Requires jq ( brew install jq )

## Install on Linux
  Just run the install-kubectl-plugins script and source your ~/.bash_profile!
  
## Install via homebrew: 
  **brew tap bitbrew/kubectl-plugins**

  **brew install kubectl-plugins**

  **install-kubectl-plugins**


### kubectl deploy [options]
![screen shot 2018-02-13 at 10 52 28 pm](https://user-images.githubusercontent.com/22456127/36187142-2bf677a0-1111-11e8-9423-7420cbc50a5a.png)

   [-f, --file] (Ex: -f 20-actions.yml) File to deploy. At this time, only accepts a single file. Required.
  
   [-i, --image] (Optional. Ex: -i kafka:v1.0.0 **or** -i kafka) Docker image/tag to use. Overwrites what's set in the manifest. If only the image name is passed, it displays a list of images to choose from. Optional.
  
   [-d, --dry] (Ex: -d true) Runs the command in dry-run mode. Optional.
  
   [-n, --namespace] (Ex: -n preprod) Namespace/Environment to deploy to (defaults to current ns). Optional
   
   Example: kubectl deploy -f 40-actions.yml -i actions -n staging


 ### kubectl uptime
  - Displays total uptime for pods/statefulsets in the user namespace.


 ### kubectl switch [options]
![screen shot 2018-02-13 at 11 06 46 pm](https://user-images.githubusercontent.com/22456127/36187488-ab54a83a-1113-11e8-8391-4e1361afeaef.png)

  - View current namespace: kubectl switch
  - Switch namespace: kubectl switch preprod
  - Switch cluster: kubectl switch cluster


 ### kubectl get-node-ip
![nodeip-get](https://user-images.githubusercontent.com/22456127/36187929-97377a8c-1116-11e8-90be-65448752b895.png)

  - Outputs the node location and IP for a given application e.g., kubectl get-nodes ingestion
  
  - Usage: kubectl get-node-ip (app or statefulset name)


 ### kubectl ssh
  - Like kubectl exec, but offers a --user flag to exec as root (or any other user) if you're running in GKE
  
  - Usage: kubectl ssh -p pod-name -u user
  
  -- *Requires that you have uploaded your ssh key to GCP or access will be denied! https://console.cloud.google.com/compute/metadata/sshKeys*
