Pod::Spec.new do |s|
  s.name  = 'Polyglot'
  s.version = '0.5.0'
  s.platform  = :ios, '8.0'
  s.requires_arc = true

  s.summary = 'Simple Swift API for Microsoft Translator'
  s.description  = <<-DESC
  Swift wrapper around the Microsoft Translator API. It currently supports translations to and from 45 languages.
  DESC

  s.homepage  = 'https://github.com/ayanonagon/Polyglot'
  s.license = { :type => 'MIT' }

  s.author  = {
    'Ayaka Nonaka' => 'ayaka@nonaka.me'
  }

  s.social_media_url = 'http://twitter.com/ayanonagon'

  s.source  = {
    :git => 'https://github.com/ayanonagon/Polyglot.git',
    :tag => s.version
  }
  s.source_files = 'Polyglot/*.{swift}'
end
