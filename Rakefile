namespace :deploy do
  def deploy(env)
    puts "Deploying to #{env}"
    system "TARGET=#{env} bundle exec middleman deploy"
  end

  desc 'Deploy to staging'
  task :staging do
    deploy :staging
  end

  desc 'Deploy to production'
  task :production do
    deploy :production
  end
end
