Pod::Spec.new do |s|
  s.name         = "LDMLightweightStore"
  s.version      = "0.0.1"
  s.summary      = "Lightweight key-value store which gives easy data access in memory, defaults and keychain domains"

  s.description  = <<-DESC
                   If you don't know how to store settings of your app, you can use this lightstore for this task.
                   Choose correct policy and store items without pain.
                   Also, you can switch policy very easy.
                   DESC
  s.homepage     = "https://github.com/lolgear/" + s.name

  s.license      = { :type => "MIT", :file => "LICENSE" }

  s.author       = { "Dmitry Lobanov" => "gaussblurinc@gmail.com" }

  s.platform     = :ios

  s.ios.deployment_target = "7.0"

  s.source       = {
    :git => "https://github.com/lolgear/" + s.name + ".git",
    :submodules => false,
    :tag => s.version.to_s
  }

  s.source_files  = "Pod/**/*.{h,m}"
  s.exclude_files = "Example"
  s.frameworks = "Foundation", "SystemConfiguration", "Security"

  s.requires_arc = true
  s.dependency 'UICKeyChainStore'
  s.dependency 'CocoaLumberjack'
end