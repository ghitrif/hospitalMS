FROM php:7.4-apache

# Arguments defined in docker-compose.yml
ARG user
ARG uid

# Install system dependencies
RUN apt-get update && apt-get install -y \
    git \
    && docker-php-ext-install pdo_mysql

RUN  apt-get install -y \
    curl \
    libpng-dev \
    libonig-dev \
    libxml2-dev \
    zip \
    unzip
RUN a2enmod rewrite


# Set working directory
WORKDIR /var/www/html
# Get latest Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Install Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Install PHP dependencies
RUN composer install --no-scripts --no-autoloader

# Copy the rest of the application
COPY . /var/www/html

# Optimize Composer autoloader
RUN composer dump-autoload --no-scripts --optimize

# # Optimize Composer autoloader
# RUN composer dump-autoload --no-scripts --optimize
# Install PHP dependencies
RUN composer install --no-scripts --no-autoloader

RUN chown -R www-data:www-data /var/www/html/storage /var/www/html/bootstrap/cache

# Expose port 80
EXPOSE 80

# Start Apache
CMD ["apache2-foreground"]

