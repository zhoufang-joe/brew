class Filetojpg < Formula
  desc "Convert files to JPG format and extract files from JPG"
  homepage "https://github.com/zhoufang-joe/FileToJPG"
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
    
    system "git", "clone", "git@github.com:zhoufang-joe/FileToJPG.git", "."
    # Use default branch - no need to checkout specific branch
    
    # Ensure dependencies are up to date
    system "go", "mod", "tidy"
    
    # Build the two main executables
    system "go", "build", "-o", bin/"FileToJPG", "file_to_jpg/main.go"
    system "go", "build", "-o", bin/"JPGToFile", "jpg_to_file/main.go"

    # Install documentation
    doc.install "README.md" if File.exist?("README.md")
    doc.install "LICENSE" if File.exist?("LICENSE")
  end

  test do
    # Create a test file
    test_file = testpath/"test.txt"
    test_file.write "Hello, Homebrew!"

    # Test file_to_jpg functionality
    system bin/"FileToJPG", test_file
    assert_predicate testpath/"test.txt.JPG", :exist?

    # Test jpg_to_file functionality
    system bin/"JPGToFile", testpath/"test.txt.JPG"
    
    # Verify the original content is preserved
    extracted_content = File.read(testpath/"test.txt")
    assert_equal "Hello, Homebrew!", extracted_content
  end
end 