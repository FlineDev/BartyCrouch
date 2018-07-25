Pod::Spec.new do |s|

  s.name         = "HandySwift"
  s.version      = "2.6.0"
  s.summary      = "Handy Swift features that didn't make it into the Swift standard library"

  s.description  = <<-DESC
    The goal of this library is to provide handy features that didn't make it to the Swift standard library (yet)
    due to many different reasons. Those could be that the Swift community wants to keep the standard library clean
    and manageable or simply hasn't finished discussion on a specific feature yet.
                   DESC

  s.homepage     = "https://github.com/Flinesoft/HandySwift"
  s.license      = { :type => "MIT", :file => "LICENSE.md" }

  s.author             = { "Cihat Gündüz" => "cocoapods@cihatguenduez.de" }
  s.social_media_url   = "https://twitter.com/Dschee"

  s.ios.deployment_target = "8.0"
  s.osx.deployment_target = "10.10"
  s.tvos.deployment_target = "9.0"

  s.source       = { :git => "https://github.com/Flinesoft/HandySwift.git", :tag => "#{s.version}" }
  s.source_files = "Sources", "Sources/**/*.swift"
  s.framework    = "Foundation"

end
