require 'rubygems'
require 'mirrored'

config = YAML::load(IO.read('config.yml'))['delicious']
login = config['login']
password = config['password']

#date = '2010-01-26'#Date.today.to_s

output_directory = ['/', 'Users', 'jonathanB', 'projects', 'git', 'jblanche.fr', 'source', '_posts']
last_id = 1
last_day = '1970-01-01'
regexp = Regexp.compile(/(\d{4}-\d{2}-\d{2})/) #2001-01-01

Dir.glob(File.join(output_directory + ['*dailynews*'] )) do |file| 
  file_name = file.split('/').last
  file_id = file_name.scan(/\d+/).last.to_i
  last_id = file_id+1 if file_id >= last_id
  
  file_day = file_name.scan(regexp).first.to_s
  last_day = file_day if file_day > last_day
end

local_filename = "#{Date.today.to_s}-dailynews_#{last_id}.textile"
connexion = Mirrored::Base.establish_connection(:delicious, login, password)

posts = []

last_date = Date.parse(last_day) + 1

last_date.step(Date.today, 1) do |date|
  posts << Mirrored::Post.find(:get, :dt => date.to_s)
end

posts.flatten!


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