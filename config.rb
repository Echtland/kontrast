require "extensions/views"

activate :views
activate :directory_indexes
activate :dotenv

set :relative_links, true
set :css_dir, 'assets/stylesheets'
set :js_dir, 'assets/javascripts'
set :images_dir, 'assets/images'
set :fonts_dir, 'assets/fonts'
set :layout, 'layouts/application'

set :url_root, 'http://www.restaurant-kontrast.de'

activate :search_engine_sitemap

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
  activate :relative_assets
  activate :minify_css
  activate :minify_javascript
end

activate :google_analytics do |ga|
  ga.tracking_id = 'UA-42827359-1'
end

activate :deploy do |deploy|
  deploy.build_before = true
  deploy.method = :git
end

case ENV['TARGET'].to_s.downcase
when 'production'
  activate :deploy do |deploy|
    deploy.build_before = true
    deploy.method   = :ftp
    deploy.host     = ENV['FTP_HOST']
    deploy.path     = '/html'
    deploy.user     = ENV['FTP_USER']
    deploy.password = ENV['FTP_PASS']
  end
else
  activate :deploy do |deploy|
    deploy.build_before = true
    deploy.method = :git
  end
end

helpers do
  def root_url(link_text, options = {})
    link_to link_text, '/index.html', options
  end

  def booking(options = {})
    address = 'reservierung@restaurant-kontrast.de'
    mailto = "mailto:#{address}"
    if options[:subject]
      options[:subject] = 'Reservierung: ' + options[:subject]
    else
      options[:subject] = 'Reservierung'
    end
    mailto = mailto + "?" + options.each_pair.map { |k,v| "#{k}=#{v}" }.join('&') if options.present?
    link_to 'Gleich reservieren', mailto, target: :blank
  end

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

  def site_title
    if current_page.data.title
      "#{current_page.data.title} | #{data.defaults.title}"
    else
      data.defaults.title
    end
  end

  def meta_tags
    tags = {}
    tags['description'] = current_page.data.description || data.defaults.meta.description
    tags['keywords'] = current_page.data.keywords || data.defaults.meta.keywords
    tags['og:title'] = current_page.data.title || data.defaults.title
    tags['og:locale'] = 'de_DE'
    tags['og:type'] = 'website'
    tags['og:description'] = tags['description']
    tags['og:url'] = current_page.url
    tags['og:site_name'] = data.defaults.title
    tags['og:image'] = image_path('facebook.jpg')
    tags['robots'] = 'index,follow'
    tags['googlebot'] = 'NOODP'

    out = tags.each_pair.map do |k,v|
      tag 'meta', name: k, content: v
    end
    out.join("\n")
  end
end
