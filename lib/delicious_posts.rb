require 'rubygems'
require 'mirrored'

config = YAML::load(IO.read('config.yml'))['delicious']
login = config['login']
password = config['password']

date = Date.today.to_s

output_directory = ['/', 'Users', 'jonathanblanchet', 'dev', 'jblanche.fr', 'source', '_posts']
last_id = 1

Dir.glob(File.join(output_directory + ['*dailynews*'] )) do |file| 
  file_name = file.split('/').last
  file_id = file_name.scan(/\d+/).last.to_i 
  last_id = file_id+1 if file_id > last_id
end

local_filename = "#{date}-dailynews_#{last_id}.textile"
connexion = Mirrored::Base.establish_connection(:delicious, login, password)

posts = Mirrored::Post.find(:get, :dt => date)

header =
%(---
title: DailyNews_##{last_id}
layout: default
categories: ['delicious']
---

)

unless posts.empty?
  File.open(File.join(output_directory << local_filename), 'w') do |f| 
    f.write(header)
    
    posts.each do |post|
      post_line = %("#{post.description}":#{post.href} - #{post.extended}\n)
      f.write(post_line) 
    end
  end
end