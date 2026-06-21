# Todo App

Ruby on Rails todo/project management app.

## Traditional Production Flow

This project includes a non-Docker Nginx deployment setup in [`nginx/`](nginx/README.md).

Production request flow:

```text
Browser -> Nginx :80/:443 -> Puma :3000 -> Rails
```

Included files:

- [`nginx/todo-app.conf`](nginx/todo-app.conf): Nginx site config for reverse proxying to Puma and serving static assets.
- [`nginx/todo-app-puma.service`](nginx/todo-app-puma.service): systemd service template to keep Puma running.
- [`nginx/todo-app.env.example`](nginx/todo-app.env.example): production environment variable template for systemd.
- [`nginx/README.md`](nginx/README.md): full install, deploy, enable, and verification steps.

Quick server flow:

```bash
sudo apt update
sudo apt install nginx mysql-server git curl build-essential
bundle install --deployment --without development test
RAILS_ENV=production bin/rails db:create db:migrate
RAILS_ENV=production bin/rails assets:precompile
sudo cp nginx/todo-app-puma.service /etc/systemd/system/todo-app-puma.service
sudo systemctl daemon-reload
sudo systemctl enable --now todo-app-puma
sudo cp nginx/todo-app.conf /etc/nginx/sites-available/todo-app
sudo ln -s /etc/nginx/sites-available/todo-app /etc/nginx/sites-enabled/todo-app
sudo nginx -t
sudo systemctl reload nginx
```

Before running the production flow, update the domain, app path, deploy user, database credentials, and Rails secrets as described in [`nginx/README.md`](nginx/README.md).

## Development

```bash
bin/setup
bin/dev
```
