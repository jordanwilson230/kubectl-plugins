#!/bin/bash



chmod +x ./kubectl-*
rm -rf ~/.kube/plugins/jordanwilson230
mkdir -p ~/.kube/plugins/jordanwilson230
cp -r ./kubectl-* ~/.kube/plugins/jordanwilson230/
grep 'PATH=$PATH:~/.kube/plugins/jordanwilson230' ~/.bash_profile 1>/dev/null
[ $? -ne 0 ] && echo 'export PATH=$PATH:~/.kube/plugins/jordanwilson230' >> ~/.bash_profile

# Removes old installer function if exists
sed -i '' 's|function kubectl\(.*\)||g' ~/.bash_profile

echo -e "\nDone.\nPlease open a new terminal or run: source ~/.bash_profile\n"
