php:
  lookup:
    pkgs:
      - php-pear
      - libmysqlclient18
      - libmcrypt4
  versions:
    php53:
      config:
        manage:
          - main
        main:
          path: /etc/php53/apache2/php.ini
      extensions:
        ioncube_loader:
          source: salt://php/files/ioncube_loader/ioncube_loader_lin_5.3.so
    php54:
      config:
        manage:
          - main
        main:
          path: /etc/php54/apache2/php.ini
      extensions:
        ioncube_loader:
          source: salt://php/files/ioncube_loader/ioncube_loader_lin_5.4.so
    php55:
      config:
        manage:
          - main
        main:
          path: /etc/php55/apache2/php.ini
      extensions:
        ioncube_loader:
          source: salt://php/files/ioncube_loader/ioncube_loader_lin_5.5.so
  pear:
    - Mail
    - Mail_Mime
    - Net_SMTP
