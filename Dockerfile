# Use the official PHP image with Apache
FROM php:8-apache
 
# Set the working directory
WORKDIR /var/www/html
 
# Install required packages
RUN apt-get update && \
    apt-get install -y \
    libonig-dev \
    libpng-dev \
    libjpeg62-turbo-dev \
    libfreetype6-dev \
    zip \
    vim \
    unzip \
    git \
    curl \
    npm \
    iputils-ping
 
# Install PHP extensions
RUN docker-php-ext-install pdo_mysql mbstring exif pcntl bcmath gd
 
# Enable Apache mod_rewrite
RUN a2enmod rewrite
 
# Copy existing application directory contents
COPY . /var/www/html

COPY /docker/apache/default.conf /etc/apache2/sites-available/000-default.conf
 
RUN chown -R www-data:www-data /var/www/html/storage
RUN chmod -R 775 /var/www/html/storage
 
# Install Composer (if needed)
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer
 
# Generate application key
RUN php artisan key:generate
 
# Install PHP dependencies
RUN composer install --no-interaction --optimize-autoloader
 
# Set environment variables
ENV APP_ENV=production
ENV APP_KEY=base64:eBlugB467OvhsrawcaDihaeefssCFMficBw9e5b0N44=
ENV DB_CONNECTION=mysql
ENV DB_HOST=mysql
ENV DB_PORT=3306
ENV DB_DATABASE=mood_db
ENV DB_USERNAME=root
ENV DB_PASSWORD=root

# Optimize Laravel
RUN php artisan optimize
 
# Clear cache
RUN php artisan cache:clear
 
# Install NPM dependencies
RUN npm install
 
# Compile assets
RUN npm run dev
 
# Expose port 80 and start Apache server
EXPOSE 80
CMD ["apache2-foreground"]