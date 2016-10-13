# geekineers/osx-lamp-laravel-php7
---

Docker image with LAMP and Laravel installed. OSX compatible version of: [geekineers/lamp-laravel-php7](https://)

Mount your Laravel project host directory to `/var/www/app`:

```
docker run -d --name=my-dev-container -v <project directory on host machine>:/var/www/app -P -p <additional ports> -t -i geekineers/lamp-laravel:dev
```

Then you can attach to your newly made container:

```
docker exec -ti my-dev-container /bin/bash
```

and run `composer install` at app directory to initialize Laravel project:

```
cd /var/www/app
composer install
```

Access phpmyadmin via: http://localhost:<port>/phpmyadmin

If phpmyadmin have errors, look for the "Find out why." link and click on it, then click on the link: "Create a database named `phpmyadmin` and setup the phpMyAdmin configuration storage there."

Don't forget to adjust the diretory in `/etc/apache2/sites-available/app.local.conf` to point to you laravel project's `public` directory
