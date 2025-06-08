class Fileencryptor < Formula
  desc "Cross-platform utility to encrypt and decrypt files securely with macOS Finder integration"
  homepage "https://github.com/zhoufang-joe/FileEncryptor"
  # Use a local dummy tarball since we can't access the private repo directly
  url "file://#{File.expand_path("dummy.tar.gz", File.dirname(__FILE__))}"
  version "2.0.0"
  sha256 "fdeeb3ffcd325db47bde582a9769ef71f51f3a1c718642f0f36075ea3cdcc778"
  license "MIT"

  depends_on "go" => :build

  def install
    # Since this is a private repo, we need to clone it manually using SSH
    # Clear all content including hidden files and clone the real repository
    Dir.glob("*", File::FNM_DOTMATCH).each do |file|
      next if file == "." || file == ".."
      rm_rf file
    end
    
    system "git", "clone", "git@github.com:zhoufang-joe/FileEncryptor.git", "."
    # Use default branch - no need to checkout specific branch
    
    # Ensure dependencies are up to date
    system "go", "mod", "tidy"
    
    # Build the binary
    system "go", "build", *std_go_args(ldflags: "-s -w"), "-o", bin/"fileencryptor"
    
    # Install macOS-specific files and automatically set up Finder integration
    if OS.mac?
      # Install the Finder workflow to user's Services directory
      services_dir = "#{Dir.home}/Library/Services"
      workflow_path = "#{services_dir}/FileEncryptor.workflow"
      
      # Create Services directory if it doesn't exist
      system "mkdir", "-p", services_dir
      
      # Copy workflow to Services directory
      system "cp", "-R", "FileEncryptor.workflow", workflow_path
      
      puts "FileEncryptor Finder service installed automatically!"
      puts "You may need to restart Finder or log out and back in for the service to appear."
      puts "The service will appear in the right-click context menu under 'Quick Actions' or 'Services'."
    end
  end

  def uninstall
    # Remove macOS Finder integration
    if OS.mac?
      services_dir = "#{Dir.home}/Library/Services"
      workflow_path = "#{services_dir}/FileEncryptor.workflow"
      
      if File.exist?(workflow_path)
        system "rm", "-rf", workflow_path
        puts "FileEncryptor Finder service removed automatically!"
        puts "You may need to restart Finder for the changes to take effect."
      end
    end
  end

  def caveats
    if OS.mac?
      <<~EOS
        FileEncryptor Finder integration has been automatically installed!
        You may need to restart Finder or log out and back in for the service to appear.
        The service will appear in the right-click context menu under 'Quick Actions' or 'Services'.

        To use FileEncryptor, you need to install 1Password CLI:
          brew install --cask 1password-cli

        Then sign in to 1Password CLI:
          op signin

        If you need to use a custom 1Password CLI location, set the OP_PATH environment variable.
      EOS
    else
      <<~EOS
        To use FileEncryptor, you need to install 1Password CLI:
          brew install --cask 1password-cli

        Then sign in to 1Password CLI:
          op signin

        If you need to use a custom 1Password CLI location, set the OP_PATH environment variable.
      EOS
    end
  end

  test do
    # Test that the binary was installed and can show usage
    output = shell_output("#{bin}/fileencryptor 2>&1", 1)
    assert_match "usage: FileEncryptor", output
  end
end 