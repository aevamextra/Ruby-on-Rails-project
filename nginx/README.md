# Traditional Nginx Deployment

This project uses the traditional Linux flow:

1. Nginx listens on port `80`.
2. Nginx serves static files from `public/`.
3. Nginx proxies dynamic Rails requests to Puma on `127.0.0.1:3000`.
4. `systemd` keeps Puma running in production.

No Docker is required for this setup.

## 1. Server Packages

Install the server packages:

```bash
sudo apt update
sudo apt install nginx mysql-server git curl build-essential
```

Install Ruby using your preferred Ruby manager, then install Bundler:

```bash
gem install bundler
```

## 2. App Directory

Create a deploy user and app directory:

```bash
sudo adduser deploy
sudo mkdir -p /var/www/todo-app/current
sudo chown -R deploy:deploy /var/www/todo-app
```

Copy or clone this project into:

```text
/var/www/todo-app/current
```

## 3. Environment

Create the production environment file:

```bash
sudo cp nginx/todo-app.env.example /etc/todo-app.env
sudo nano /etc/todo-app.env
sudo chown root:root /etc/todo-app.env
sudo chmod 600 /etc/todo-app.env
```

Generate `SECRET_KEY_BASE` locally or on the server:

```bash
bin/rails secret
```

The systemd service reads `/etc/todo-app.env` when Puma starts.

## 4. Install Gems And Prepare Rails

Run these commands as the deploy user from `/var/www/todo-app/current`:

```bash
bundle install --deployment --without development test
RAILS_ENV=production bin/rails db:create db:migrate
RAILS_ENV=production bin/rails assets:precompile
```

This app uses Rails Solid Cache, Solid Queue, and Solid Cable in production. That means production has four database connections configured in `config/database.yml`: `primary`, `cache`, `queue`, and `cable`.

Create those MySQL databases before booting Puma:

```bash
RAILS_ENV=production bin/rails db:create
RAILS_ENV=production bin/rails db:migrate
RAILS_ENV=production bin/rails db:schema:load:cache
RAILS_ENV=production bin/rails db:schema:load:queue
RAILS_ENV=production bin/rails db:schema:load:cable
```

## 5. Puma systemd Service

Copy the service file:

```bash
sudo cp nginx/todo-app-puma.service /etc/systemd/system/todo-app-puma.service
```

Edit these values in `/etc/systemd/system/todo-app-puma.service` if your server differs:

```text
User=deploy
Group=deploy
WorkingDirectory=/var/www/todo-app/current
Environment=PORT=3000
EnvironmentFile=-/etc/todo-app.env
```

Enable and start Puma:

```bash
sudo systemctl daemon-reload
sudo systemctl enable todo-app-puma
sudo systemctl start todo-app-puma
sudo systemctl status todo-app-puma
```

## 6. Nginx Site

Copy the Nginx config:

```bash
sudo cp nginx/todo-app.conf /etc/nginx/sites-available/todo-app
```

Edit `/etc/nginx/sites-available/todo-app`:

```text
server_name your-domain.com www.your-domain.com;
root /var/www/todo-app/current/public;
```

Enable the site:

```bash
sudo ln -s /etc/nginx/sites-available/todo-app /etc/nginx/sites-enabled/todo-app
sudo nginx -t
sudo systemctl reload nginx
```

If the default Nginx welcome site is still enabled and conflicts with this app, disable that default site on the server:

```bash
sudo unlink /etc/nginx/sites-enabled/default
sudo nginx -t
sudo systemctl reload nginx
```

## 7. Verify

Check Puma directly:

```bash
curl http://127.0.0.1:3000/up
```

Check through Nginx:

```bash
curl http://your-domain.com/up
```

Useful logs:

```bash
sudo journalctl -u todo-app-puma -f
sudo tail -f /var/log/nginx/todo-app.error.log
sudo tail -f /var/log/nginx/todo-app.access.log
```

## 8. Optional HTTPS

After DNS points to the server, install Certbot and enable HTTPS:

```bash
sudo apt install certbot python3-certbot-nginx
sudo certbot --nginx -d your-domain.com -d www.your-domain.com
```
