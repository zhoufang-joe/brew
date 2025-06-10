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
    
    # Build the binary in the current directory first (for the install script)
    system "go", "build", "-ldflags", "-s -w", "-o", "FileEncryptor"
    
    # Install binary and scripts to Homebrew's bin directory
    bin.install "FileEncryptor"
    
    # Copy both install and uninstall scripts to bin directory for future use
    if OS.mac?
      bin.install "install_macos.sh" if File.exist?("install_macos.sh")
      bin.install "uninstall_macos.sh" if File.exist?("uninstall_macos.sh")
      bin.install "FileEncryptor.workflow" if File.exist?("FileEncryptor.workflow")
    end
  end

  def post_install
    if OS.mac? && File.exist?("#{bin}/install_macos.sh")
      system "chmod", "+x", "#{bin}/install_macos.sh"
      # Set environment variables that the install script might need
      ENV["FILEENCRYPTOR_BIN_PATH"] = "#{bin}/FileEncryptor"
      # Run the install script from the homebrew bin directory
      Dir.chdir(bin) do
        system "./install_macos.sh"
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
      Option 1 - Use the repository's uninstall script:
        #{bin}/uninstall_macos.sh
      
      Option 2 - Manual cleanup:
        rm -rf ~/Library/Services/FileEncryptor.workflow
        rm -f ~/bin/FileEncryptor
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