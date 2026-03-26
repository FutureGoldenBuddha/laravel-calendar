#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────────────────────
# setup.sh — Run once after `docker-compose up -d` to initialise the Laravel app
# ─────────────────────────────────────────────────────────────────────────────
set -e

CONTAINER="teste_app"

echo ""
echo "🐳  Site — Docker setup"
echo "────────────────────────────────"

# 1. ( copies .env.example → .env inside the container)
echo "🔑  Generating application key..."
cp .env.example .env

# 2. Inject DB credentials into the container's .env
echo "🔧  Configuring database connection in .env..."
sed -i \
  -e 's|^APP_URL=.*|APP_URL=http://localhost:8008|' \
  -e 's|^# DB_HOST=.*|DB_HOST=db|' \
  -e 's|^DB_HOST=.*|DB_HOST=db|' \
  .env

# Install Socialite
echo "📦  Installing Laravel Socialite..."
composer require laravel/socialite --no-interaction

# Generate application key 
php artisan key:generate

# 4. Clear any cached config so Laravel re-reads the patched .env
echo "🧹  Clearing config cache..."
php artisan config:clear
php artisan cache:clear

# 3. Wait for MySQL to be ready (step 1+2 already done above)
#echo "⏳  Waiting for MySQL to be ready..."
#until php -r "new PDO('mysql:host=db;dbname=inhaler_guide', 'inhaler_user', 'secret');" 2>/dev/null; do
#  sleep 2
#done
#echo "✅  MySQL is ready."

# 4. Run migrations
#echo "📦  Running migrations..."
#php artisan migrate --force

# 5. Seed the database
# echo "🌱  Seeding inhalers..."
# php artisan db:seed --class=InhalerSeeder --force

# 6. Cache config & routes
echo "⚡  Caching config and routes..."
php artisan config:cache
php artisan route:cache

# 8. Create storage symlink
echo "🔗  Creating storage symlink..."
php artisan storage:link

# 7. Fix storage permissions
echo "🔒  Setting storage permissions..."
chown -R www-data:www-data /var/www/storage /var/www/bootstrap/cache

echo ""
echo "🎉  Done! Visit http://localhost:8008"
echo "    phpMyAdmin:  http://localhost:8088"
echo ""
