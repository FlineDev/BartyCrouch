class BartyCrouch < Formula
  desc "Localization/I18n: Incrementally update/translate your Strings files from .swift, .h, .m(m), .storyboard or .xib files."
  homepage "https://github.com/Flinesoft/BartyCrouch"
  url "https://github.com/Flinesoft/BartyCrouch.git", :tag => "4.0.0-alpha.1", :revision => "4c27662f0800bea9263748fe4e62c163ea9de7f6"
  head "https://github.com/Flinesoft/BartyCrouch.git"

  depends_on :xcode => ["10.0", :build]

  def install
    system "make", "install", "prefix=#{prefix}"
  end

  test do
    system "#{bin}/bartycrouch"
  end
end
