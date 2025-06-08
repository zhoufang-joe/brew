class Filetojpg < Formula
  desc "Convert files to JPG format and extract files from JPG"
  homepage "https://github.com/zhoufang-joe/FileToJPG"
  url "https://github.com/zhoufang-joe/FileToJPG/archive/refs/heads/master.tar.gz"
  version "2.0.0"
  sha256 :no_check
  license "MIT"

  depends_on "go" => :build

  def install
    # Ensure dependencies are up to date
    system "go", "mod", "tidy"
    
    # Build the two main executables
    system "go", "build", "-o", bin/"FileToJPG", "file_to_jpg/main.go"
    system "go", "build", "-o", bin/"JPGToFile", "jpg_to_file/main.go"

    # Install documentation
    doc.install "README.md"
    doc.install "LICENSE"
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