# README

This README would normally document whatever steps are necessary to get the
application up and running.

Things you may want to cover:
* Clone the project
  git clone https://github.com/dnyaneshwar-burgute/Payora.git

  bundle install

  npm install (use node version 22.19.0)

* Ruby version
  3.3.11

* Rails version
  8.1.4
  
* Database creation

  rails db:setup
  
* Setup Platform Admin

  rails db:migrate
  
  rails c

  user = User.find_by(email_address: 'admin@example.com')
  user.password = 'abcd@1234' # set
  user.confirm_password = 'abcd@1234' # set
  user.save

* Setup for the Registered Organization For localhost
  
  ## For mac on localhost

  brew install nginx

  nginx config : vi /opt/homebrew/etc/nginx/nginx.conf

  ## for local machine organizaion host should end with .fli.com e.g. demo.fli.com

   server {
    listen 80;
    server_name *.fli.com; 
    location / {
        proxy_pass http://127.0.0.1:3000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
  }
  brew services restart nginx
  ## in hosts file add

  sudo vi /etc/hosts
  127.0.0.1 demo.fli.com

  in vite allow domain *.fli.com so that assets will be available for demo.fli.com
  const allowedOrigins = [
    /^https?:\/\/(?:(?:[^:]+\.)?localhost|127\.0\.0\.1|\[::1\])(?::\d+)?$/,
    /^https?:\/\/(?:[^:]+\.)?fli\.com(?::\d+)?$/,
  ]
  export default defineConfig({
    plugins: [
      RubyPlugin(),
      react(),
    ],
    server: {
      cors: {
        origin: allowedOrigins,
      },
    },
  })
  For Plaform Admin URL will be 
  http://localhost:3000

  For Organization Url will be
  http://demo.fli.com
