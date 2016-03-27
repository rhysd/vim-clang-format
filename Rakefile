task :ci => [:dump, :test]

task :dump do
  sh 'vim --version'
  sh 'clang-format -version'
end

task :test do
  sh 'bundle install'
  sh 'bundle exec vim-flavor test'
end
