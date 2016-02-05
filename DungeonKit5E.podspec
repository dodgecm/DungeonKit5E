Pod::Spec.new do |s|
  s.name              = "DungeonKit5E"
  s.version           = "1.0.0"
  s.summary           = "DnD 5th Edition character sheet model."
  s.description       = "Character sheet model for DnD 5E that updates dependent values automatically."
  s.homepage          = "https://github.com/dodgecm/DungeonKit"
  s.license           = { :type => 'MIT', :file => 'LICENSE.txt' }
  s.author            = { "Chris Dodge" => "cmd8n@virginia.edu" }
#  s.source            = { :git => "https://github.com/dodgecm/DungeonKit.git", :tag => "v#{s.version}" }
  s.platform          = :ios, '8.0'
  s.requires_arc      = true
  s.frameworks        = [ "UIKit" ]
  s.source_files   = 'DungeonKit5E/**/*.{h,m}'
  s.dependency 'DungeonKit'
end
