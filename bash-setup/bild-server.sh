#!/bin/bash
set -xo pipefail

script_dir=$(cd -P $(dirname "$0") && pwd)
script_path="$script_dir/$0"
user=$(whoami)


check_dependencies(){
  for program in caddy chromium-browser; do
    if [[ $(command -v "$program") != "" ]]; then
      printf "Dependency for $program is satisfied.\n"
    else
      printf "Dependency $program is missing. Installing...\n"
      sudo apt install "$program" -y
    fi

  done
}

install_cronjob(){
  croncmd="bash $script_path screenshot > $script_dir/calendar_screenshot.log 2>&1"
  cronjob="*/5 * * * * $croncmd"
  ( crontab -l | grep -v -F "$croncmd" ; echo "$cronjob" ) | crontab -

}

configure_caddy(){
  sudo mkdir -p /var/www
  sudo chmod 774 /var/www
  sudo chown caddy:"$user" /var/www
  sudo sed -i "s%/usr/share/caddy%/var/www%g" /etc/caddy/Caddyfile
  sudo systemctl reload caddy
}

main(){
  if [[ "$1" == "screenshot" ]]; then
	  chromium-browser --headless --screenshot="$script_dir/test.png" "https://outlook.live.com/calendar/0/view/week" --window-size="800,600"
	  mv "$script_dir/test.png" /var/www/
    exit 0
  fi

  if [[ "$1" == "install" ]]; then
    check_dependencies
    install_cronjob
    configure_caddy
  fi
}

main "$@"
