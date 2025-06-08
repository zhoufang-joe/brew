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
    
    # Build the binary and install to Homebrew's bin directory
    system "go", "build", "-ldflags", "-s -w", "-o", bin/"FileEncryptor"
    
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
    message = <<~EOS
      ✅ FileEncryptor has been installed successfully!
      
      📍 Binary location: #{bin}/FileEncryptor

      🚀 QUICK SETUP (copy and paste one of these):
      
      Option 1 - Add to PATH (recommended):
        echo 'export PATH="#{bin}:$PATH"' >> ~/.zshrc && source ~/.zshrc
      
      Option 2 - Create symlink:
        mkdir -p ~/bin && ln -sf #{bin}/FileEncryptor ~/bin/FileEncryptor

      📋 REQUIREMENTS:
      Install 1Password CLI and sign in:
        brew install --cask 1password-cli && op signin
      
      Set OP_PATH if using custom 1Password CLI location.
    EOS

    if OS.mac?
      message += <<~EOS

      🍎 MACOS FINDER INTEGRATION:
      ✅ Automatically installed! Right-click any file to see FileEncryptor options.
      (Restart Finder if needed: killall Finder)
      
      🗑️  UNINSTALL CLEANUP:
      To remove Finder integration when uninstalling:
        rm -rf ~/Library/Services/FileEncryptor.workflow
      EOS
    end

    message
  end

  test do
    # Test that the binary was installed and can show usage
    output = shell_output("#{bin}/FileEncryptor 2>&1", 1)
    assert_match "usage: FileEncryptor", output
  end
end 