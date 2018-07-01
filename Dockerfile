FROM wordpress:4.7-php5.6-apache

RUN mkdir -p /usr/src/php/ext

RUN { \
        echo 'opcache.memory_consumption=1024'; \
        echo 'opcache.interned_strings_buffer=8'; \
        echo 'opcache.max_accelerated_files=4000'; \
        echo 'opcache.revalidate_freq=2'; \
        echo 'opcache.fast_shutdown=1'; \
        echo 'opcache.enable_cli=1'; \
    } > /usr/local/etc/php/conf.d/opcache-recommended.ini

RUN set -ex; \
	\
	savedAptMark="$(apt-mark showmanual)"; \
	\
	apt-get update; \
	apt-get install -y --no-install-recommends \
		memcached \
		libmemcached-dev \
		libz-dev \
	; \
	\
        curl -o memcached.tgz -SL http://pecl.php.net/get/memcached-2.2.0.tgz && \
        tar -xf memcached.tgz -C /usr/src/php/ext/ && \
        echo extension=memcached.so >> /usr/local/etc/php/conf.d/memcached.ini && \
        rm memcached.tgz && \
        mv /usr/src/php/ext/memcached-2.2.0 /usr/src/php/ext/memcached \
        ; \
        \
        curl -o memcache.tgz -SL http://pecl.php.net/get/memcache-3.0.8.tgz && \
        tar -xf memcache.tgz -C /usr/src/php/ext/ && \
        rm memcache.tgz && \
        mv /usr/src/php/ext/memcache-3.0.8 /usr/src/php/ext/memcache \
        ; \
        \
	docker-php-ext-install memcached memcache; \
	\
# reset apt-mark's "manual" list so that "purge --auto-remove" will remove all build dependencies
	apt-mark auto '.*' > /dev/null; \
	apt-mark manual $savedAptMark; \
	ldd "$(php -r 'echo ini_get("extension_dir");')"/*.so \
		| awk '/=>/ { print $3 }' \
		| sort -u \
		| xargs -r dpkg-query -S \
		| cut -d: -f1 \
		| sort -u \
		| xargs -rt apt-mark manual; \
	\
	apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false; \
	rm -rf /var/lib/apt/lists/*

