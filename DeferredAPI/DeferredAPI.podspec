

Pod::Spec.new do |s|

  s.name         = "DeferredAPI"
  s.version      = "0.0.1"
  s.summary      = "A DeferredAPI."

  s.description  = <<-DESC
                   Makes deferreds a little bit easier.
                   DESC

  s.homepage     = "https://github.com/affablebloke/deferred-objective-c/"

  s.license      = 'MIT'

  s.author       = { "Daniel Johnston" => "affablebloke@gmail.com" }

  s.source       = { :git => "https://github.com/affablebloke/deferred-objective-c.git", :tag => "v0.0.1" }

  s.source_files  = 'DeferredAPI/DeferredAPI', 'DeferredAPI/DeferredAPI/**/*.{h,m}'
  s.exclude_files = 'DeferredAPI/Excluded'
  s.requires_arc = true

end
