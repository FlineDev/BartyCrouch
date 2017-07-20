Pod::Spec.new do |s|
  s.name           = 'BartyCrouch'
  s.version        = `3.8.0`
  s.summary        = 'Localization/I18n: Incrementally update your Strings files from .swift, .h, .m(m), .storyboard or .xib files and/or use machine-translation.'
  s.homepage       = 'https://github.com/Flinesoft/BartyCrouch'
  s.license        = { :type => 'MIT', :file => 'LICENSE.md' }
  s.author         = { 'Dschee' => 'github@dschee.com' }
  s.source         = { :http => "#{s.homepage}/releases/download/#{s.version}/portable_bartycrouch.zip" }
  s.preserve_paths = '*'
end
