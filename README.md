This provides a container for running cms-builder inside.

1. *Unless/until it gets rolled into the main cms-builder, you'll need [this
   fork][1]*. Download it somewhere, uncomment the `docker-compose.yml` volumes
   line
   ```
   # - 'path/to/cms-builder/on/host:/opt/cms-builder
   ```
   and set the first path to
   the relative or absolute location of the custom cms-builder.
1. Ensure the site project has the following snippet in its
   `.platform-project.local.settings.php` file.
   ```php
   // Configuration when running drush commands from inside a docker container.
   if (getenv('CMS_BUILDER_DOCKER')) {
     $cmd = "docker inspect --format='{{.NetworkSettings.Networks.bridge.IPAddress}}' {{ container_name }}";
     $ip = trim(shell_exec($cmd));
   
     // Update the host and port if running inside a container.
     $databases['default']['default'] = array(
       'host' => $ip,
       'port' => '3306',
     ) + $databases['default']['default'];
   }
   ```
1. Create a directory called `test` in this project root that is owned by 33:33
   (sorry, I realise that's not uber-portable). It can be improved I suspect (:
1. Supply environment variables by command line or in [.env][2].
   - SSH_KEY_FILE: the path to a private key with access to the git repo; this
     should be a deployment key, not a personal one! chown to 33:33 and chmod to
     600.
   - PROJECT_ROOT: The absolute path to the project root. It gets directly
     mapped into the container running cms-builder (lovely, I know). Files will
     be checked out directly into this folder.
   - REPO_URL: The URL for the project repository. Must be accessible within the
     container.
   - REPO_BRANCH: (optional) The repo branch to checkout.
   - CMS_BUILDER_SITE: (optional) The site argument to specify to `cms-builder
     build`.
   - CMS_BUILDER_USER: (optional) The user that will be running cms-builder;
     defaults to 33 (`www-data` on Debian and derivatives).
1. In theory you can just run `docker-compose up` and the tests will run. It's
   untested. Alternatively if you need an interactive terminal you can run
   `docker-compose run -u www-data php run-tests` or just do things manually
   by running `docker-compose run -u www-data php /bin/bash`.

```bash
# Quickstart (uses sudo)
git clone XXX
cd cms-builder-docker
mkdir test
sudo chown 33:33 test
cat << ENV > .env
SSH_KEY_FILE={{path to private key}}
CMS_BUILDER_PROJECT_ROOT={{path to project root}}
CMS_BUILDER_SITE={{site to build}}
REPO_URL={{repo url}
REPO_BRANCH={{branch}}
ENV
docker-compose run -u www-data php run-tests
```

[1]: https://github.com/andriokha/cms-builder
[2]: https://docs.docker.com/compose/env-file/
