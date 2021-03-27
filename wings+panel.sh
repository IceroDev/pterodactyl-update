#!/bin/bash


PANEL_UPDATE="https://github.com/pterodactyl/panel/releases/latest/download/panel.tar.gz"
WINGS_UPDATE="https://github.com/pterodactyl/wings/releases/latest/download/wings_linux_amd64"

function main {
  # check if we can detect an already existing installation
  if [ -d "/var/www/pterodactyl/"  ]; then
    echo -e -n "* Do you want proceed to update your panel? (y/N): "
    read -r CONFIRM_PROCEED
    if [[ ! "$CONFIRM_PROCEED" =~ [Yy] ]]; then
      print_error "Updating abort!"
      exit 1
    fi
  fi
}

function update_panel() {
    if [ -d "/var/www/pterodactyl/" ]; then
      cd "/var/www/pterodactyl/"
      curl -L $PANEL_UPDATE | tar -xzv
      sleep 5
      chmod -R 755 storage/* bootstrap/cache
      composer install --no-dev --optimize-autoloader
      php artisan view:clear
      php artisan config:clear
      php artisan migrate --seed --force
      chown -R www-data:www-data *
      
      echo "Panel Updated"
    fi
}

function update_wings() {
    if [ -d "/usr/local/bin/" ]; then
      echo "Updating Wings........"
      sleep 5
      cd "/usr/local/bin/"
      curl -L -o /usr/local/bin/wings $WINGS_UPDATE
      chmod u+x /usr/local/bin/wings
      systemctl restart wings

      echo "Wings Updated"
    fi
}
main
update_panel
sleep 4
update_wings
