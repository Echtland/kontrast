require "extensions/views"

activate :views
activate :directory_indexes

set :relative_links, true
set :css_dir, 'assets/stylesheets'
set :js_dir, 'assets/javascripts'
set :images_dir, 'assets/images'
set :fonts_dir, 'assets/fonts'
set :layout, 'layouts/application'

sprockets.append_path File.join root, 'bower_components'
sprockets.import_asset 'jquery'
sprockets.import_asset 'vide'
sprockets.import_asset 'font-awesome'
['eot', 'svg', 'ttf', 'woff', 'woff2'].each do |ext|
  file = ['fontawesome-webfont', ext].join('.')
  sprockets.import_asset "font-awesome/fonts/#{file}"  do |logical_path|
    Pathname.new('assets/fonts') + file
  end
end

configure :development do
 activate :livereload
end

configure :build do
  # Relative assets needed to deploy to Github Pages
  activate :relative_assets
end

activate :deploy do |deploy|
  deploy.build_before = true
  deploy.method = :git
end

helpers do
  def nav_link(link_text, page_url, options = {})
    options[:class] ||= ""
    if current_page.url.length > 1
      current_url = current_page.url.chop
    else
      current_url = current_page.url
    end
    options[:class] << " active" if page_url == current_url
    link_to(link_text, page_url, options)
  end
end
