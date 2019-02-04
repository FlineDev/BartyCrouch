class Bartycrouch < Formula
  desc "Localization/I18n: Incrementally update/translate your Strings files from .swift, .h, .m(m), .storyboard or .xib files."
  homepage "https://github.com/Flinesoft/BartyCrouch"
  url "https://github.com/Flinesoft/BartyCrouch.git", :tag => "4.0.0", :revision => "3afdce4b875b6e8a573eaa30a225e709b7ee7b0a"
  head "https://github.com/Flinesoft/BartyCrouch.git"

  depends_on :xcode => ["10.0", :build]

  def install
    system "make", "install", "prefix=#{prefix}"
  end

  test do
    system "#{bin}/bartycrouch"
  end
end
