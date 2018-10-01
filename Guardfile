interactor :off
scope plugin: :rack

guard 'rack', port: 3000 do
  watch 'Gemfile.lock'
  watch 'config.ru'
  watch 'data/schema.rb'
  watch %r{^(?:lib|app)/(.+)\.rb$}
  
  ignore /node_modules/
end

guard :rspec, all_on_start: false, cmd: 'rspec --tag ~slow' do
  watch(%r{^spec\/.+_spec\.rb$})
  watch(%r{^(?:lib|app)\/(.+)\.rb$}) { |m| "spec/#{m[1]}_spec.rb" }
  watch('spec/spec_helper.rb')       { "spec" }
  watch('lib/db.rb')                 { "spec" }
  watch('lib/boot.rb')               { "spec" }
  watch(%r{spec\/support\/.+})       { "spec" }
end