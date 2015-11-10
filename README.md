# geekineers/lamp-laravel
---

Docker image with LAMP and Laravel installed. OSX compatible version of: [geekineers/lamp-laravel](https://)

Mount your Laravel project host directory to `/var/www/app`:

```
docker run -d --name=my-dev-container -v <project directory on host machine>:/var/www/app -P -t -i geekineers/lamp-laravel:dev
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
