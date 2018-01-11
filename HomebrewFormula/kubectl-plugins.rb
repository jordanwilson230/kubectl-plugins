class KubectlPlugins < Formula
  desc "BitBrew Managed Plugins for kubectl"
  homepage 'https://github.com/BitBrew'
  url "https://github.com/BitBrew/homebrew-kubectl-plugins.git"

  depends_on "jq"

  bottle:unneeded

  def install
    libexec.install Dir["*"]
    bin.write_exec_script (libexec/"install-kubectl-plugins")
  end


  def caveats; <<~EOS

    ### IMPORTANT!!! To finish the install, run: "install-kubectl-plugins" ###

    EOS
  end

#def postflight
#  postflight do
    # Append to .bash_profile
#    system_command '/usr/local/Cellar/kubectl-plugins/kubectl/libexec/install-kubectl-plugins'
#    system_command '/usr/local/bin/install-kubectl-plugins'
#  end
#end
end
