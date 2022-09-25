Pod::Spec.new do |s|

  s.name         = "BartyCrouch"
  s.version      = "4.12.0"
  s.summary      = "Localization/I18n: Incrementally update/translate your Strings files from .swift, .h, .m(m), .storyboard or .xib files."

  s.description  = <<-DESC
    BartyCrouch incrementally updates your Strings files from your Code and from Interface Builder files. "Incrementally" means that
    BartyCrouch will by default keep both your already translated values and even your altered comments. Additionally you can also use
    BartyCrouch for machine translating from one language to 60+ other languages. Using BartyCrouch is as easy as running a few
    simple commands from the command line what can even be automated using a build script within your project.
                   DESC

  s.homepage     = "https://github.com/Flinesoft/BartyCrouch"
  s.license      = { :type => "MIT", :file => "LICENSE" }

  s.author             = { "Cihat Gündüz" => "cocoapods@cihatguenduez.de" }
  s.social_media_url   = "https://twitter.com/Jeehut"

  s.source         = { :http => "#{s.homepage}/releases/download/#{s.version}/portable_bartycrouch.zip" }
  s.preserve_paths = "*"

end
