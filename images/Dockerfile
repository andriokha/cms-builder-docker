FROM php:7.0.18-cli
# TODO: Use an ARG for image version when that's possible (should be the first
#   release after 10 April 2017). See https://github.com/moby/moby/pull/31352

ARG cms_builder_hash
ARG composer_hash
ARG user
ARG docker_version
ARG docker_compose_version
#ARG xdebug_version
ARG phantomjs_version
ARG selenium_version
ARG selenium_version_abbrev
ARG geckodriver_version
ARG chromedriver_version
ARG platform_version

# Install extra PHP requirements.
RUN apt-get update && \
  apt-get install -y \
    libfreetype6-dev \
    libjpeg62-turbo-dev \
    libmcrypt-dev \
    libpng12-dev \
    libxml2-dev && \
  docker-php-ext-install mcrypt pdo_mysql mysqli mbstring opcache soap bcmath zip && \
  docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ && \
  docker-php-ext-install gd && \
  # Create a home directory for the user that's not inside a volume.
  mkdir -p /home/$user/.drush && \
  cp /etc/skel/.bashrc /home/$user && \
  echo 'PATH="$PATH:$HOME/.composer/vendor/bin"' >> /home/$user/.bashrc && \
  usermod -d /home/$user $user && \
  chown -R $user:$user /home/$user && \
  # Install Composer
  curl https://raw.githubusercontent.com/composer/getcomposer.org/$composer_hash/web/installer | php -- --install-dir=/usr/local/bin --filename=composer && \
  chsh -s /bin/bash $user && \
  # Install Prestissimo and Drush
  su -l $user -c "composer global require hirak/prestissimo" && \
  # Install with Composer to avoid issues with `drush qd`.
  # See https://drupal.stackexchange.com/a/197508
  # See https://github.com/drush-ops/drush/issues/2090
  su -l $user -c "composer global require drush/drush" && \
  chsh -s /usr/sbin/nologin $user && \
  # I think the client is needed to run drush si. (Seems strange, should
  # investigate.
  apt-get -y install mariadb-client git && \
  #
  # cms-builder
  # TODO: This should download a specific version.
  curl -LSs https://github.com/tes/cms-builder/raw/{$cms_builder_hash}/cms-builder.phar -o cms-builder && \
  chmod +x cms-builder && \
  mv cms-builder /usr/local/bin && \
  #
  # Selenium
  mkdir -p /opt/selenium && \
  cd /opt/selenium && \
  curl -LOSs http://selenium-release.storage.googleapis.com/$selenium_version_abbrev/selenium-server-standalone-$selenium_version.jar && \
  apt-get install -y libfontconfig bzip2 && \
  curl -LSs https://bitbucket.org/ariya/phantomjs/downloads/phantomjs-${phantomjs_version}-linux-x86_64.tar.bz2 \
    | tar -xjf - -C /opt && \
    echo '2' && \
  # TODO: Check phantomjs checksum.
  ln -s /opt/phantomjs-$phantomjs_version-linux-x86_64/bin/phantomjs /usr/local/bin/ && \
  #
  # Gecko driver
  curl -LSs https://github.com/mozilla/geckodriver/releases/download/v${geckodriver_version}/geckodriver-v${geckodriver_version}-linux64.tar.gz \
    | tar -xzf - -C /usr/local/bin && \
  #
  # Chrome driver
  curl -LOSs http://chromedriver.storage.googleapis.com/$chromedriver_version/chromedriver_linux64.zip && \
  apt-get install unzip && \
  unzip chromedriver_linux64.zip -d /usr/local/bin && \
  rm chromedriver_linux64.zip && \
  #
  mkdir /home/$user/.ssh && \
  chmod 700 /home/$user/.ssh && \
  chown $user:$user /home/$user/.ssh && \
  # Install platformsh-cli
  curl -LSs https://github.com/platformsh/platformsh-cli/releases/download/v${platform_version}/platform.phar > /usr/local/bin/platform && \
  chmod +x /usr/local/bin/platform && \
  # Install docker
  # From https://docs.docker.com/engine/installation/linux/debian/#install-using-the-repository
  apt-get install -y \
     apt-transport-https \
     ca-certificates \
     curl \
     gnupg2 \
     software-properties-common && \
     # 2
     curl -fsSL https://download.docker.com/linux/debian/gpg | apt-key add - && \
     add-apt-repository \
        "deb [arch=amd64] https://download.docker.com/linux/debian \
        jessie \
        stable" && \
     apt-get update && \
     apt-get install -y docker-ce=$docker_version && \
  usermod -a -G ${DOCKER_USER:-docker} $user && \
  # Install docker-compose
  curl -LSs https://github.com/docker/compose/releases/download/$docker_compose_version/docker-compose-`uname -s`-`uname -m` > /usr/local/bin/docker-compose && \
  chmod +x /usr/local/bin/docker-compose && \
  apt-get remove --purge -y $BUILD_PACKAGES $(apt-mark showauto) && rm -rf /var/lib/apt/lists/

## Setup xdebug
#RUN pecl install xdebug-$xdebug_version && \
#  docker-php-ext-enable xdebug

CMD ["php", "-a"]
