Gem::Specification.new do |s|
  s.name        = "tiny_rfid"
  s.version     = "0.0.1"
  s.summary     = "Driver for RFID pad"
  s.description = "A simple API for running an RFID pad"
  s.authors     = ["Andy Clink"]
  s.email       = "andy@aravaiparunning.com"
  s.files       = ['lib/tiny_rfid.rb']
  s.files      += Dir["lib/tiny_rfid/**/*.rb"]
  s.add_dependency 'colorize', '~>0.8'
  s.add_dependency 'rubyserial', '~>0.6'
  s.homepage    = "http://github.com/aravaiparunning/tiny_rfid"
  s.license     = "GPL-3.0"
end