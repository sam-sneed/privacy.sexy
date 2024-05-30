#!/usr/bin/env bash
# https://privacy.sexy — v0.13.4 — Thu, 30 May 2024 18:37:58 GMT
if [ "$EUID" -ne 0 ]; then
  script_path=$([[ "$0" = /* ]] && echo "$0" || echo "$PWD/${0#./}")
  sudo "$script_path" || (
    echo 'Administrator privileges are required.'
    exit 1
  )
  exit 0
fi
export HOME="/home/${SUDO_USER:-${USER}}" # Keep `~` and `$HOME` for user not `/root`.


# ----------------------------------------------------------
# -------Disable participation in Popularity Contest--------
# ----------------------------------------------------------
echo '--- Disable participation in Popularity Contest'
config_file='/etc/popularity-contest.conf'
if [ -f "$config_file" ]; then
  sudo sed -i '/PARTICIPATE/c\PARTICIPATE=no' "$config_file"
else
  echo "Skipping because configuration file at ($config_file) is not found. Is popcon installed?"
fi
# ----------------------------------------------------------


# ----------------------------------------------------------
# -------Remove Popularity Contest (`popcon`) package-------
# ----------------------------------------------------------
echo '--- Remove Popularity Contest (`popcon`) package'
if ! command -v 'apt-get' &> /dev/null; then
  echo 'Skipping because "apt-get" is not found.'
else
  apt_package_name='popularity-contest'
if status="$(dpkg-query -W --showformat='${db:Status-Status}' "$apt_package_name" 2>&1)" \
    && [ "$status" = installed ]; then
  echo "\"$apt_package_name\" is installed and will be uninstalled."
  sudo apt-get purge -y "$apt_package_name"
else
  echo "Skipping, no action needed, \"$apt_package_name\" is not installed."
fi
fi
# ----------------------------------------------------------


# ----------------------------------------------------------
# -Remove daily cron entry for Popularity Contest (popcon)--
# ----------------------------------------------------------
echo '--- Remove daily cron entry for Popularity Contest (popcon)'
job_name='popularity-contest'
cronjob_path="/etc/cron.daily/$job_name"
if [[ -f "$cronjob_path" ]]; then
  if [[ -x "$cronjob_path" ]]; then
    sudo chmod -x "$cronjob_path"
    echo "Successfully disabled cronjob \"$job_name\"."
  else
    echo "Skipping, cronjob \"$job_name\" is already disabled."
  fi
else
  echo "Skipping, \"$job_name\" cronjob is not found."
fi
# ----------------------------------------------------------


# ----------------------------------------------------------
# ----------------Remove `reportbug` package----------------
# ----------------------------------------------------------
echo '--- Remove `reportbug` package'
if ! command -v 'apt-get' &> /dev/null; then
  echo 'Skipping because "apt-get" is not found.'
else
  apt_package_name='reportbug'
if status="$(dpkg-query -W --showformat='${db:Status-Status}' "$apt_package_name" 2>&1)" \
    && [ "$status" = installed ]; then
  echo "\"$apt_package_name\" is installed and will be uninstalled."
  sudo apt-get purge -y "$apt_package_name"
else
  echo "Skipping, no action needed, \"$apt_package_name\" is not installed."
fi
fi
# ----------------------------------------------------------


# ----------------------------------------------------------
# ----------Remove Python modules for `reportbug`-----------
# ----------------------------------------------------------
echo '--- Remove Python modules for `reportbug`'
if ! command -v 'apt-get' &> /dev/null; then
  echo 'Skipping because "apt-get" is not found.'
else
  apt_package_name='python3-reportbug'
if status="$(dpkg-query -W --showformat='${db:Status-Status}' "$apt_package_name" 2>&1)" \
    && [ "$status" = installed ]; then
  echo "\"$apt_package_name\" is installed and will be uninstalled."
  sudo apt-get purge -y "$apt_package_name"
else
  echo "Skipping, no action needed, \"$apt_package_name\" is not installed."
fi
fi
# ----------------------------------------------------------


# ----------------------------------------------------------
# ----Remove UI for reportbug (`reportbug-gtk` package)-----
# ----------------------------------------------------------
echo '--- Remove UI for reportbug (`reportbug-gtk` package)'
if ! command -v 'apt-get' &> /dev/null; then
  echo 'Skipping because "apt-get" is not found.'
else
  apt_package_name='reportbug-gtk'
if status="$(dpkg-query -W --showformat='${db:Status-Status}' "$apt_package_name" 2>&1)" \
    && [ "$status" = installed ]; then
  echo "\"$apt_package_name\" is installed and will be uninstalled."
  sudo apt-get purge -y "$apt_package_name"
else
  echo "Skipping, no action needed, \"$apt_package_name\" is not installed."
fi
fi
# ----------------------------------------------------------


# ----------------------------------------------------------
# ----------------Remove `pkgstats` package-----------------
# ----------------------------------------------------------
echo '--- Remove `pkgstats` package'
if ! command -v 'pacman' &> /dev/null; then
  echo 'Skipping because "pacman" is not found.'
else
  pkg_package_name='pkgstats'
if pacman -Qs "$pkg_package_name" > /dev/null ; then
  echo "\"$pkg_package_name\" is installed and will be uninstalled."
  sudo pacman -Rcns "$pkg_package_name" --noconfirm
else
  echo "The package $pkg_package_name is not installed"
fi
fi
# ----------------------------------------------------------


# ----------------------------------------------------------
# -----------Disable weekly `pkgstats` submission-----------
# ----------------------------------------------------------
echo '--- Disable weekly `pkgstats` submission'
if ! command -v 'systemctl' &> /dev/null; then
  echo 'Skipping because "systemctl" is not found.'
else
  service='pkgstats.timer'
if systemctl list-units --full -all | grep --fixed-strings --quiet "$service"; then # service exists
  if systemctl is-enabled --quiet "$service"; then
    if systemctl is-active --quiet "$service"; then
      echo "Service $service is running now, stopping it."
      if ! sudo systemctl stop "$service"; then
        >&2 echo "Could not stop $service."
      else
        echo 'Successfully stopped'
      fi
    fi
    if sudo systemctl disable "$service"; then
      echo "Successfully disabled $service."
    else
      >&2 echo "Failed to disable $service."
    fi
  else
    echo "Skipping, $service is already disabled."
  fi
else
  echo "Skipping, $service does not exist."
fi
fi
# ----------------------------------------------------------


# ----------------------------------------------------------
# --------------Disable Zorin OS census pings---------------
# ----------------------------------------------------------
echo '--- Disable Zorin OS census pings'
if ! command -v 'apt-get' &> /dev/null; then
  echo 'Skipping because "apt-get" is not found.'
else
  apt_package_name='zorin-os-census'
if status="$(dpkg-query -W --showformat='${db:Status-Status}' "$apt_package_name" 2>&1)" \
    && [ "$status" = installed ]; then
  echo "\"$apt_package_name\" is installed and will be uninstalled."
  sudo apt-get purge -y "$apt_package_name"
else
  echo "Skipping, no action needed, \"$apt_package_name\" is not installed."
fi
fi
# ----------------------------------------------------------


# ----------------------------------------------------------
# -------------Remove Zorin OS census unique ID-------------
# ----------------------------------------------------------
echo '--- Remove Zorin OS census unique ID'
sudo rm -fv '/var/lib/zorin-os-census/uuid'
# ----------------------------------------------------------


# ----------------------------------------------------------
# ---Disable participation in metrics reporting in Ubuntu---
# ----------------------------------------------------------
echo '--- Disable participation in metrics reporting in Ubuntu'
if ! command -v 'ubuntu-report' &> /dev/null; then
  echo 'Skipping because "ubuntu-report" is not found.'
else
  if ubuntu-report -f send no; then
  echo 'Successfully opted out.'
else
  >&2 echo 'Failed to opt out.'
fi
fi
# ----------------------------------------------------------


# ----------------------------------------------------------
# -------Remove Ubuntu Report tool (`ubuntu-report`)--------
# ----------------------------------------------------------
echo '--- Remove Ubuntu Report tool (`ubuntu-report`)'
if ! command -v 'apt-get' &> /dev/null; then
  echo 'Skipping because "apt-get" is not found.'
else
  apt_package_name='ubuntu-report'
if status="$(dpkg-query -W --showformat='${db:Status-Status}' "$apt_package_name" 2>&1)" \
    && [ "$status" = installed ]; then
  echo "\"$apt_package_name\" is installed and will be uninstalled."
  sudo apt-get purge -y "$apt_package_name"
else
  echo "Skipping, no action needed, \"$apt_package_name\" is not installed."
fi
fi
# ----------------------------------------------------------


# ----------------------------------------------------------
# -----------------Remove `apport` package------------------
# ----------------------------------------------------------
echo '--- Remove `apport` package'
if ! command -v 'apt-get' &> /dev/null; then
  echo 'Skipping because "apt-get" is not found.'
else
  apt_package_name='apport'
if status="$(dpkg-query -W --showformat='${db:Status-Status}' "$apt_package_name" 2>&1)" \
    && [ "$status" = installed ]; then
  echo "\"$apt_package_name\" is installed and will be uninstalled."
  sudo apt-get purge -y "$apt_package_name"
else
  echo "Skipping, no action needed, \"$apt_package_name\" is not installed."
fi
fi
# ----------------------------------------------------------


# ----------------------------------------------------------
# ------------------Disable Apport service------------------
# ----------------------------------------------------------
echo '--- Disable Apport service'
if ! command -v 'systemctl' &> /dev/null; then
  echo 'Skipping because "systemctl" is not found.'
else
  service='apport'
if systemctl list-units --full -all | grep --fixed-strings --quiet "$service"; then # service exists
  if systemctl is-enabled --quiet "$service"; then
    if systemctl is-active --quiet "$service"; then
      echo "Service $service is running now, stopping it."
      if ! sudo systemctl stop "$service"; then
        >&2 echo "Could not stop $service."
      else
        echo 'Successfully stopped'
      fi
    fi
    if sudo systemctl disable "$service"; then
      echo "Successfully disabled $service."
    else
      >&2 echo "Failed to disable $service."
    fi
  else
    echo "Skipping, $service is already disabled."
  fi
else
  echo "Skipping, $service does not exist."
fi
fi
# ----------------------------------------------------------


# ----------------------------------------------------------
# --Disable participation in Apport error messaging system--
# ----------------------------------------------------------
echo '--- Disable participation in Apport error messaging system'
if [ -f /etc/default/apport ]; then
  sudo sed -i 's/enabled=1/enabled=0/g' /etc/default/apport
  echo 'Successfully disabled apport.'
else
  echo 'Skipping, apport is not configured to be enabled.'
fi
# ----------------------------------------------------------


# ----------------------------------------------------------
# ----------------Remove `whoopsie` package-----------------
# ----------------------------------------------------------
echo '--- Remove `whoopsie` package'
if ! command -v 'apt-get' &> /dev/null; then
  echo 'Skipping because "apt-get" is not found.'
else
  apt_package_name='whoopsie'
if status="$(dpkg-query -W --showformat='${db:Status-Status}' "$apt_package_name" 2>&1)" \
    && [ "$status" = installed ]; then
  echo "\"$apt_package_name\" is installed and will be uninstalled."
  sudo apt-get purge -y "$apt_package_name"
else
  echo "Skipping, no action needed, \"$apt_package_name\" is not installed."
fi
fi
# ----------------------------------------------------------


# ----------------------------------------------------------
# -----------------Disable Whoopsie service-----------------
# ----------------------------------------------------------
echo '--- Disable Whoopsie service'
if ! command -v 'systemctl' &> /dev/null; then
  echo 'Skipping because "systemctl" is not found.'
else
  service='whoopsie'
if systemctl list-units --full -all | grep --fixed-strings --quiet "$service"; then # service exists
  if systemctl is-enabled --quiet "$service"; then
    if systemctl is-active --quiet "$service"; then
      echo "Service $service is running now, stopping it."
      if ! sudo systemctl stop "$service"; then
        >&2 echo "Could not stop $service."
      else
        echo 'Successfully stopped'
      fi
    fi
    if sudo systemctl disable "$service"; then
      echo "Successfully disabled $service."
    else
      >&2 echo "Failed to disable $service."
    fi
  else
    echo "Skipping, $service is already disabled."
  fi
else
  echo "Skipping, $service does not exist."
fi
fi
# ----------------------------------------------------------


# ----------------------------------------------------------
# -------------Disable crash report submissions-------------
# ----------------------------------------------------------
echo '--- Disable crash report submissions'
if [ -f /etc/default/whoopsie ] ; then
  sudo sed -i 's/report_crashes=true/report_crashes=false/' /etc/default/whoopsie
fi
# ----------------------------------------------------------


# Disable online search result collection (collects queries)
echo '--- Disable online search result collection (collects queries)'
if ! command -v 'gsettings' &> /dev/null; then
  echo 'Skipping because "gsettings" is not found.'
else
  gsettings set com.canonical.Unity.Lenses remote-content-search none
fi
# ----------------------------------------------------------


# ----------------------------------------------------------
# --------------Kill Zeitgeist daemon process---------------
# ----------------------------------------------------------
echo '--- Kill Zeitgeist daemon process'
if ! command -v 'zeitgeist-daemon' &> /dev/null; then
  echo 'Skipping because "zeitgeist-daemon" is not found.'
else
  zeitgeist-daemon --quit
fi
# ----------------------------------------------------------


# ----------------------------------------------------------
# --------------Remove Zeitgeist startup entry--------------
# ----------------------------------------------------------
echo '--- Remove Zeitgeist startup entry'
file='/etc/xdg/autostart/zeitgeist-datahub.desktop'
backup_file="${file}.old"
if [ -f "$file" ]; then
  echo "File exists: $file."
  sudo mv "$file" "$backup_file"
  echo "Moved to: $backup_file."
else
  echo "Skipping, no changes needed."
fi
# ----------------------------------------------------------


# ----------------------------------------------------------
# -----------Disable access to Zeitgeist database-----------
# ----------------------------------------------------------
echo '--- Disable access to Zeitgeist database'
file="$HOME/.local/share/zeitgeist/activity.sqlite"
if [ -f "$file" ]; then
  chmod -rw "$file"
  echo "Successfully disabled read/write access to $file."
else
  echo "Skipping, no action needed, file does not exist at $file."
fi
# ----------------------------------------------------------


# ----------------------------------------------------------
# -Remove Zeitgeist package (can break integrated software)-
# ----------------------------------------------------------
echo '--- Remove Zeitgeist package (can break integrated software)'
if ! command -v 'apt-get' &> /dev/null; then
  echo 'Skipping because "apt-get" is not found.'
else
  apt_package_name='zeitgeist-core'
if status="$(dpkg-query -W --showformat='${db:Status-Status}' "$apt_package_name" 2>&1)" \
    && [ "$status" = installed ]; then
  echo "\"$apt_package_name\" is installed and will be uninstalled."
  sudo apt-get purge -y "$apt_package_name"
else
  echo "Skipping, no action needed, \"$apt_package_name\" is not installed."
fi
fi
if ! command -v 'pacman' &> /dev/null; then
  echo 'Skipping because "pacman" is not found.'
else
  pkg_package_name='zeitgeist'
if pacman -Qs "$pkg_package_name" > /dev/null ; then
  echo "\"$pkg_package_name\" is installed and will be uninstalled."
  sudo pacman -Rcns "$pkg_package_name" --noconfirm
else
  echo "The package $pkg_package_name is not installed"
fi
fi
if ! command -v 'dnf' &> /dev/null; then
  echo 'Skipping because "dnf" is not found.'
else
  rpm_package_name='zeitgeist'
sudo dnf autoremove -y --skip-broken "$rpm_package_name"
fi
# ----------------------------------------------------------


# ----------------------------------------------------------
# --------------------Clear bash history--------------------
# ----------------------------------------------------------
echo '--- Clear bash history'
rm -fv ~/.bash_history
sudo rm -fv /root/.bash_history
# ----------------------------------------------------------


# ----------------------------------------------------------
# --------------------Clear Zsh history---------------------
# ----------------------------------------------------------
echo '--- Clear Zsh history'
rm -fv ~/.zsh_history
sudo rm -fv /root/.zsh_history
# ----------------------------------------------------------


# ----------------------------------------------------------
# --------------------Clear tcsh history--------------------
# ----------------------------------------------------------
echo '--- Clear tcsh history'
rm -fv ~/.history
sudo rm -fv /root/.history
# ----------------------------------------------------------


# ----------------------------------------------------------
# --------------------Clear fish history--------------------
# ----------------------------------------------------------
echo '--- Clear fish history'
rm -fv ~/.local/share/fish/fish_history
sudo rm -fv /root/.local/share/fish/fish_history
rm -fv ~/.config/fish/fish_history
sudo rm -fv /root/.config/fish/fish_history
# ----------------------------------------------------------


# ----------------------------------------------------------
# --------------Clear KornShell (ksh) history---------------
# ----------------------------------------------------------
echo '--- Clear KornShell (ksh) history'
rm -fv ~/.sh_history
sudo rm -fv /root/.sh_history
# ----------------------------------------------------------


# ----------------------------------------------------------
# --------------------Clear ash history---------------------
# ----------------------------------------------------------
echo '--- Clear ash history'
rm -fv ~/.ash_history
sudo rm -fv /root/.ash_history
# ----------------------------------------------------------


# ----------------------------------------------------------
# -------------------Clear crosh history--------------------
# ----------------------------------------------------------
echo '--- Clear crosh history'
rm -fv ~/.crosh_history
sudo rm -fv /root/.crosh_history
# ----------------------------------------------------------


# ----------------------------------------------------------
# --------------------Clear screenshots---------------------
# ----------------------------------------------------------
echo '--- Clear screenshots'
# Clear default directory for GNOME screenshots
rm -rfv ~/Pictures/Screenshots/*
if [ -d ~/Pictures ]; then
  # Clear Ubuntu screenshots
  find ~/Pictures -name 'Screenshot from *.png' | while read -r file_path; do
    rm -fv "$file_path" # E.g. Screenshot from 2022-08-20 02-46-41.png
  done
  # Clear KDE (Spectatle) screenshots
  find ~/Pictures -name 'Screenshot_*' | while read -r file_path; do
    rm -fv "$file_path" # E.g. Screenshot_20220927_205646.png
  done
fi
# Clear ksnip screenshots
find ~ -name 'ksnip_*' | while read -r file_path; do
  rm -fv "$file_path" # E.g. ksnip_20220927-195151.png
done
# ----------------------------------------------------------


# ----------------------------------------------------------
# ------------Clear GTK recently used files list------------
# ----------------------------------------------------------
echo '--- Clear GTK recently used files list'
# From global installations
rm -fv /.recently-used.xbel
rm -fv ~/.local/share/recently-used.xbel*
# From snap packages
rm -fv ~/snap/*/*/.local/share/recently-used.xbel
# From Flatpak packages
rm -fv ~/.var/app/*/data/recently-used.xbel
# ----------------------------------------------------------


# ----------------------------------------------------------
# --------Clear KDE-tracked recently used items list--------
# ----------------------------------------------------------
echo '--- Clear KDE-tracked recently used items list'
# From global installations
rm -rfv ~/.local/share/RecentDocuments/*.desktop
rm -rfv ~/.kde/share/apps/RecentDocuments/*.desktop
rm -rfv ~/.kde4/share/apps/RecentDocuments/*.desktop
# From snap packages
rm -fv ~/snap/*/*/.local/share/*.desktop
# From Flatpak packages
rm -rfv ~/.var/app/*/data/*.desktop
# ----------------------------------------------------------


# ----------------------------------------------------------
# -----------------------Empty trash------------------------
# ----------------------------------------------------------
echo '--- Empty trash'
# Empty global trash
rm -rfv ~/.local/share/Trash/*
sudo rm -rfv /root/.local/share/Trash/*
# Empty Snap trash
rm -rfv ~/snap/*/*/.local/share/Trash/*
# Empty Flatpak trash (apps may not choose to use Portal API)
rm -rfv ~/.var/app/*/data/Trash/*
# ----------------------------------------------------------


# ----------------------------------------------------------
# ------------Clear privacy.sexy script history-------------
# ----------------------------------------------------------
echo '--- Clear privacy.sexy script history'
# Clear directory contents: "$HOME/.config/privacy.sexy/runs"
glob_pattern="$HOME/.config/privacy.sexy/runs/*"
rm -rfv $glob_pattern
# ----------------------------------------------------------


# ----------------------------------------------------------
# -------------Clear privacy.sexy activity logs-------------
# ----------------------------------------------------------
echo '--- Clear privacy.sexy activity logs'
# Clear directory contents: "$HOME/.config/privacy.sexy/logs"
glob_pattern="$HOME/.config/privacy.sexy/logs/*"
rm -rfv $glob_pattern
# ----------------------------------------------------------


# ----------------------------------------------------------
# -------------Clear LibreOffice usage history--------------
# ----------------------------------------------------------
echo '--- Clear LibreOffice usage history'
# Global installation
rm -f ~/.config/libreoffice/4/user/registrymodifications.xcu
# Snap package
rm -fv ~/snap/libreoffice/*/.config/libreoffice/4/user/registrymodifications.xcu
# Flatpak installation
rm -fv ~/.var/app/org.libreoffice.LibreOffice/config/libreoffice/4/user/registrymodifications.xcu
# ----------------------------------------------------------


# ----------------------------------------------------------
# --Disable automatic Visual Studio Code extension updates--
# ----------------------------------------------------------
echo '--- Disable automatic Visual Studio Code extension updates'
if ! command -v 'python3' &> /dev/null; then
  echo 'Skipping because "python3" is not found.'
else
  python3 <<EOF
from pathlib import Path
import os, json, sys
property_name = 'extensions.autoUpdate'
target = json.loads('false')
home_dir = f'/home/{os.getenv("SUDO_USER", os.getenv("USER"))}'
settings_files = [
  # Global installation (also Snap that installs with "--classic" flag)
  f'{home_dir}/.config/Code/User/settings.json',
  # Flatpak installation
  f'{home_dir}/.var/app/com.visualstudio.code/config/Code/User/settings.json'
]
for settings_file in settings_files:
  file=Path(settings_file)
  if not file.is_file():
    print(f'Skipping, file does not exist at "{settings_file}".')
    continue
  print(f'Reading file at "{settings_file}".')
  file_content = file.read_text()
  if not file_content.strip():
    print('Settings file is empty. Treating it as default empty JSON object.')
    file_content = '{}'
  json_object = None
  try:
    json_object = json.loads(file_content)
  except json.JSONDecodeError:
    print(f'Error, invalid JSON format in the settings file: "{settings_file}".', file=sys.stderr)
    continue
  if property_name not in json_object:
    print(f'Settings "{property_name}" is not configured.')
  else:
    existing_value = json_object[property_name]
    if existing_value == target:
      print(f'Skipping, "{property_name}" is already configured as {json.dumps(target)}.')
      continue
    print(f'Setting "{property_name}" has unexpected value {json.dumps(existing_value)} that will be changed.')
  json_object[property_name] = target
  new_content = json.dumps(json_object, indent=2)
  file.write_text(new_content)
  print(f'Successfully configured "{property_name}" to {json.dumps(target)}.')
EOF
fi
# ----------------------------------------------------------


# Disable Visual Studio Code automatic extension update checks
echo '--- Disable Visual Studio Code automatic extension update checks'
if ! command -v 'python3' &> /dev/null; then
  echo 'Skipping because "python3" is not found.'
else
  python3 <<EOF
from pathlib import Path
import os, json, sys
property_name = 'extensions.autoCheckUpdates'
target = json.loads('false')
home_dir = f'/home/{os.getenv("SUDO_USER", os.getenv("USER"))}'
settings_files = [
  # Global installation (also Snap that installs with "--classic" flag)
  f'{home_dir}/.config/Code/User/settings.json',
  # Flatpak installation
  f'{home_dir}/.var/app/com.visualstudio.code/config/Code/User/settings.json'
]
for settings_file in settings_files:
  file=Path(settings_file)
  if not file.is_file():
    print(f'Skipping, file does not exist at "{settings_file}".')
    continue
  print(f'Reading file at "{settings_file}".')
  file_content = file.read_text()
  if not file_content.strip():
    print('Settings file is empty. Treating it as default empty JSON object.')
    file_content = '{}'
  json_object = None
  try:
    json_object = json.loads(file_content)
  except json.JSONDecodeError:
    print(f'Error, invalid JSON format in the settings file: "{settings_file}".', file=sys.stderr)
    continue
  if property_name not in json_object:
    print(f'Settings "{property_name}" is not configured.')
  else:
    existing_value = json_object[property_name]
    if existing_value == target:
      print(f'Skipping, "{property_name}" is already configured as {json.dumps(target)}.')
      continue
    print(f'Setting "{property_name}" has unexpected value {json.dumps(existing_value)} that will be changed.')
  json_object[property_name] = target
  new_content = json.dumps(json_object, indent=2)
  file.write_text(new_content)
  print(f'Successfully configured "{property_name}" to {json.dumps(target)}.')
EOF
fi
# ----------------------------------------------------------


# Disable automatic fetching of Microsoft recommendations in Visual Studio Code
echo '--- Disable automatic fetching of Microsoft recommendations in Visual Studio Code'
if ! command -v 'python3' &> /dev/null; then
  echo 'Skipping because "python3" is not found.'
else
  python3 <<EOF
from pathlib import Path
import os, json, sys
property_name = 'extensions.showRecommendationsOnlyOnDemand'
target = json.loads('true')
home_dir = f'/home/{os.getenv("SUDO_USER", os.getenv("USER"))}'
settings_files = [
  # Global installation (also Snap that installs with "--classic" flag)
  f'{home_dir}/.config/Code/User/settings.json',
  # Flatpak installation
  f'{home_dir}/.var/app/com.visualstudio.code/config/Code/User/settings.json'
]
for settings_file in settings_files:
  file=Path(settings_file)
  if not file.is_file():
    print(f'Skipping, file does not exist at "{settings_file}".')
    continue
  print(f'Reading file at "{settings_file}".')
  file_content = file.read_text()
  if not file_content.strip():
    print('Settings file is empty. Treating it as default empty JSON object.')
    file_content = '{}'
  json_object = None
  try:
    json_object = json.loads(file_content)
  except json.JSONDecodeError:
    print(f'Error, invalid JSON format in the settings file: "{settings_file}".', file=sys.stderr)
    continue
  if property_name not in json_object:
    print(f'Settings "{property_name}" is not configured.')
  else:
    existing_value = json_object[property_name]
    if existing_value == target:
      print(f'Skipping, "{property_name}" is already configured as {json.dumps(target)}.')
      continue
    print(f'Setting "{property_name}" has unexpected value {json.dumps(existing_value)} that will be changed.')
  json_object[property_name] = target
  new_content = json.dumps(json_object, indent=2)
  file.write_text(new_content)
  print(f'Successfully configured "{property_name}" to {json.dumps(target)}.')
EOF
fi
# ----------------------------------------------------------


# ----------------------------------------------------------
# Disable synchronization of Visual Studio Code keybindings-
# ----------------------------------------------------------
echo '--- Disable synchronization of Visual Studio Code keybindings'
if ! command -v 'python3' &> /dev/null; then
  echo 'Skipping because "python3" is not found.'
else
  python3 <<EOF
from pathlib import Path
import os, json, sys
property_name = 'settingsSync.keybindingsPerPlatform'
target = json.loads('false')
home_dir = f'/home/{os.getenv("SUDO_USER", os.getenv("USER"))}'
settings_files = [
  # Global installation (also Snap that installs with "--classic" flag)
  f'{home_dir}/.config/Code/User/settings.json',
  # Flatpak installation
  f'{home_dir}/.var/app/com.visualstudio.code/config/Code/User/settings.json'
]
for settings_file in settings_files:
  file=Path(settings_file)
  if not file.is_file():
    print(f'Skipping, file does not exist at "{settings_file}".')
    continue
  print(f'Reading file at "{settings_file}".')
  file_content = file.read_text()
  if not file_content.strip():
    print('Settings file is empty. Treating it as default empty JSON object.')
    file_content = '{}'
  json_object = None
  try:
    json_object = json.loads(file_content)
  except json.JSONDecodeError:
    print(f'Error, invalid JSON format in the settings file: "{settings_file}".', file=sys.stderr)
    continue
  if property_name not in json_object:
    print(f'Settings "{property_name}" is not configured.')
  else:
    existing_value = json_object[property_name]
    if existing_value == target:
      print(f'Skipping, "{property_name}" is already configured as {json.dumps(target)}.')
      continue
    print(f'Setting "{property_name}" has unexpected value {json.dumps(existing_value)} that will be changed.')
  json_object[property_name] = target
  new_content = json.dumps(json_object, indent=2)
  file.write_text(new_content)
  print(f'Successfully configured "{property_name}" to {json.dumps(target)}.')
EOF
fi
# ----------------------------------------------------------


# ----------------------------------------------------------
# -Disable synchronization of Visual Studio Code extensions-
# ----------------------------------------------------------
echo '--- Disable synchronization of Visual Studio Code extensions'
if ! command -v 'python3' &> /dev/null; then
  echo 'Skipping because "python3" is not found.'
else
  python3 <<EOF
from pathlib import Path
import os, json, sys
property_name = 'settingsSync.ignoredExtensions'
target = json.loads('["*"]')
home_dir = f'/home/{os.getenv("SUDO_USER", os.getenv("USER"))}'
settings_files = [
  # Global installation (also Snap that installs with "--classic" flag)
  f'{home_dir}/.config/Code/User/settings.json',
  # Flatpak installation
  f'{home_dir}/.var/app/com.visualstudio.code/config/Code/User/settings.json'
]
for settings_file in settings_files:
  file=Path(settings_file)
  if not file.is_file():
    print(f'Skipping, file does not exist at "{settings_file}".')
    continue
  print(f'Reading file at "{settings_file}".')
  file_content = file.read_text()
  if not file_content.strip():
    print('Settings file is empty. Treating it as default empty JSON object.')
    file_content = '{}'
  json_object = None
  try:
    json_object = json.loads(file_content)
  except json.JSONDecodeError:
    print(f'Error, invalid JSON format in the settings file: "{settings_file}".', file=sys.stderr)
    continue
  if property_name not in json_object:
    print(f'Settings "{property_name}" is not configured.')
  else:
    existing_value = json_object[property_name]
    if existing_value == target:
      print(f'Skipping, "{property_name}" is already configured as {json.dumps(target)}.')
      continue
    print(f'Setting "{property_name}" has unexpected value {json.dumps(existing_value)} that will be changed.')
  json_object[property_name] = target
  new_content = json.dumps(json_object, indent=2)
  file.write_text(new_content)
  print(f'Successfully configured "{property_name}" to {json.dumps(target)}.')
EOF
fi
# ----------------------------------------------------------


# ----------------------------------------------------------
# --Disable synchronization of Visual Studio Code settings--
# ----------------------------------------------------------
echo '--- Disable synchronization of Visual Studio Code settings'
if ! command -v 'python3' &> /dev/null; then
  echo 'Skipping because "python3" is not found.'
else
  python3 <<EOF
from pathlib import Path
import os, json, sys
property_name = 'settingsSync.ignoredSettings'
target = json.loads('["*"]')
home_dir = f'/home/{os.getenv("SUDO_USER", os.getenv("USER"))}'
settings_files = [
  # Global installation (also Snap that installs with "--classic" flag)
  f'{home_dir}/.config/Code/User/settings.json',
  # Flatpak installation
  f'{home_dir}/.var/app/com.visualstudio.code/config/Code/User/settings.json'
]
for settings_file in settings_files:
  file=Path(settings_file)
  if not file.is_file():
    print(f'Skipping, file does not exist at "{settings_file}".')
    continue
  print(f'Reading file at "{settings_file}".')
  file_content = file.read_text()
  if not file_content.strip():
    print('Settings file is empty. Treating it as default empty JSON object.')
    file_content = '{}'
  json_object = None
  try:
    json_object = json.loads(file_content)
  except json.JSONDecodeError:
    print(f'Error, invalid JSON format in the settings file: "{settings_file}".', file=sys.stderr)
    continue
  if property_name not in json_object:
    print(f'Settings "{property_name}" is not configured.')
  else:
    existing_value = json_object[property_name]
    if existing_value == target:
      print(f'Skipping, "{property_name}" is already configured as {json.dumps(target)}.')
      continue
    print(f'Setting "{property_name}" has unexpected value {json.dumps(existing_value)} that will be changed.')
  json_object[property_name] = target
  new_content = json.dumps(json_object, indent=2)
  file.write_text(new_content)
  print(f'Successfully configured "{property_name}" to {json.dumps(target)}.')
EOF
fi
# ----------------------------------------------------------


# ----------------------------------------------------------
# -----------Disable Visual Studio Code telemetry-----------
# ----------------------------------------------------------
echo '--- Disable Visual Studio Code telemetry'
if ! command -v 'python3' &> /dev/null; then
  echo 'Skipping because "python3" is not found.'
else
  python3 <<EOF
from pathlib import Path
import os, json, sys
property_name = 'telemetry.telemetryLevel'
target = json.loads('"off"')
home_dir = f'/home/{os.getenv("SUDO_USER", os.getenv("USER"))}'
settings_files = [
  # Global installation (also Snap that installs with "--classic" flag)
  f'{home_dir}/.config/Code/User/settings.json',
  # Flatpak installation
  f'{home_dir}/.var/app/com.visualstudio.code/config/Code/User/settings.json'
]
for settings_file in settings_files:
  file=Path(settings_file)
  if not file.is_file():
    print(f'Skipping, file does not exist at "{settings_file}".')
    continue
  print(f'Reading file at "{settings_file}".')
  file_content = file.read_text()
  if not file_content.strip():
    print('Settings file is empty. Treating it as default empty JSON object.')
    file_content = '{}'
  json_object = None
  try:
    json_object = json.loads(file_content)
  except json.JSONDecodeError:
    print(f'Error, invalid JSON format in the settings file: "{settings_file}".', file=sys.stderr)
    continue
  if property_name not in json_object:
    print(f'Settings "{property_name}" is not configured.')
  else:
    existing_value = json_object[property_name]
    if existing_value == target:
      print(f'Skipping, "{property_name}" is already configured as {json.dumps(target)}.')
      continue
    print(f'Setting "{property_name}" has unexpected value {json.dumps(existing_value)} that will be changed.')
  json_object[property_name] = target
  new_content = json.dumps(json_object, indent=2)
  file.write_text(new_content)
  print(f'Successfully configured "{property_name}" to {json.dumps(target)}.')
EOF
fi
if ! command -v 'python3' &> /dev/null; then
  echo 'Skipping because "python3" is not found.'
else
  python3 <<EOF
from pathlib import Path
import os, json, sys
property_name = 'telemetry.enableTelemetry'
target = json.loads('false')
home_dir = f'/home/{os.getenv("SUDO_USER", os.getenv("USER"))}'
settings_files = [
  # Global installation (also Snap that installs with "--classic" flag)
  f'{home_dir}/.config/Code/User/settings.json',
  # Flatpak installation
  f'{home_dir}/.var/app/com.visualstudio.code/config/Code/User/settings.json'
]
for settings_file in settings_files:
  file=Path(settings_file)
  if not file.is_file():
    print(f'Skipping, file does not exist at "{settings_file}".')
    continue
  print(f'Reading file at "{settings_file}".')
  file_content = file.read_text()
  if not file_content.strip():
    print('Settings file is empty. Treating it as default empty JSON object.')
    file_content = '{}'
  json_object = None
  try:
    json_object = json.loads(file_content)
  except json.JSONDecodeError:
    print(f'Error, invalid JSON format in the settings file: "{settings_file}".', file=sys.stderr)
    continue
  if property_name not in json_object:
    print(f'Settings "{property_name}" is not configured.')
  else:
    existing_value = json_object[property_name]
    if existing_value == target:
      print(f'Skipping, "{property_name}" is already configured as {json.dumps(target)}.')
      continue
    print(f'Setting "{property_name}" has unexpected value {json.dumps(existing_value)} that will be changed.')
  json_object[property_name] = target
  new_content = json.dumps(json_object, indent=2)
  file.write_text(new_content)
  print(f'Successfully configured "{property_name}" to {json.dumps(target)}.')
EOF
fi
if ! command -v 'python3' &> /dev/null; then
  echo 'Skipping because "python3" is not found.'
else
  python3 <<EOF
from pathlib import Path
import os, json, sys
property_name = 'telemetry.enableCrashReporter'
target = json.loads('false')
home_dir = f'/home/{os.getenv("SUDO_USER", os.getenv("USER"))}'
settings_files = [
  # Global installation (also Snap that installs with "--classic" flag)
  f'{home_dir}/.config/Code/User/settings.json',
  # Flatpak installation
  f'{home_dir}/.var/app/com.visualstudio.code/config/Code/User/settings.json'
]
for settings_file in settings_files:
  file=Path(settings_file)
  if not file.is_file():
    print(f'Skipping, file does not exist at "{settings_file}".')
    continue
  print(f'Reading file at "{settings_file}".')
  file_content = file.read_text()
  if not file_content.strip():
    print('Settings file is empty. Treating it as default empty JSON object.')
    file_content = '{}'
  json_object = None
  try:
    json_object = json.loads(file_content)
  except json.JSONDecodeError:
    print(f'Error, invalid JSON format in the settings file: "{settings_file}".', file=sys.stderr)
    continue
  if property_name not in json_object:
    print(f'Settings "{property_name}" is not configured.')
  else:
    existing_value = json_object[property_name]
    if existing_value == target:
      print(f'Skipping, "{property_name}" is already configured as {json.dumps(target)}.')
      continue
    print(f'Setting "{property_name}" has unexpected value {json.dumps(existing_value)} that will be changed.')
  json_object[property_name] = target
  new_content = json.dumps(json_object, indent=2)
  file.write_text(new_content)
  print(f'Successfully configured "{property_name}" to {json.dumps(target)}.')
EOF
fi
# ----------------------------------------------------------


# Disable online experiments by Microsoft in Visual Studio Code
echo '--- Disable online experiments by Microsoft in Visual Studio Code'
if ! command -v 'python3' &> /dev/null; then
  echo 'Skipping because "python3" is not found.'
else
  python3 <<EOF
from pathlib import Path
import os, json, sys
property_name = 'workbench.enableExperiments'
target = json.loads('false')
home_dir = f'/home/{os.getenv("SUDO_USER", os.getenv("USER"))}'
settings_files = [
  # Global installation (also Snap that installs with "--classic" flag)
  f'{home_dir}/.config/Code/User/settings.json',
  # Flatpak installation
  f'{home_dir}/.var/app/com.visualstudio.code/config/Code/User/settings.json'
]
for settings_file in settings_files:
  file=Path(settings_file)
  if not file.is_file():
    print(f'Skipping, file does not exist at "{settings_file}".')
    continue
  print(f'Reading file at "{settings_file}".')
  file_content = file.read_text()
  if not file_content.strip():
    print('Settings file is empty. Treating it as default empty JSON object.')
    file_content = '{}'
  json_object = None
  try:
    json_object = json.loads(file_content)
  except json.JSONDecodeError:
    print(f'Error, invalid JSON format in the settings file: "{settings_file}".', file=sys.stderr)
    continue
  if property_name not in json_object:
    print(f'Settings "{property_name}" is not configured.')
  else:
    existing_value = json_object[property_name]
    if existing_value == target:
      print(f'Skipping, "{property_name}" is already configured as {json.dumps(target)}.')
      continue
    print(f'Setting "{property_name}" has unexpected value {json.dumps(existing_value)} that will be changed.')
  json_object[property_name] = target
  new_content = json.dumps(json_object, indent=2)
  file.write_text(new_content)
  print(f'Successfully configured "{property_name}" to {json.dumps(target)}.')
EOF
fi
# ----------------------------------------------------------


# Disable Visual Studio Code automatic updates in favor of manual updates
echo '--- Disable Visual Studio Code automatic updates in favor of manual updates'
if ! command -v 'python3' &> /dev/null; then
  echo 'Skipping because "python3" is not found.'
else
  python3 <<EOF
from pathlib import Path
import os, json, sys
property_name = 'update.mode'
target = json.loads('"none"')
home_dir = f'/home/{os.getenv("SUDO_USER", os.getenv("USER"))}'
settings_files = [
  # Global installation (also Snap that installs with "--classic" flag)
  f'{home_dir}/.config/Code/User/settings.json',
  # Flatpak installation
  f'{home_dir}/.var/app/com.visualstudio.code/config/Code/User/settings.json'
]
for settings_file in settings_files:
  file=Path(settings_file)
  if not file.is_file():
    print(f'Skipping, file does not exist at "{settings_file}".')
    continue
  print(f'Reading file at "{settings_file}".')
  file_content = file.read_text()
  if not file_content.strip():
    print('Settings file is empty. Treating it as default empty JSON object.')
    file_content = '{}'
  json_object = None
  try:
    json_object = json.loads(file_content)
  except json.JSONDecodeError:
    print(f'Error, invalid JSON format in the settings file: "{settings_file}".', file=sys.stderr)
    continue
  if property_name not in json_object:
    print(f'Settings "{property_name}" is not configured.')
  else:
    existing_value = json_object[property_name]
    if existing_value == target:
      print(f'Skipping, "{property_name}" is already configured as {json.dumps(target)}.')
      continue
    print(f'Setting "{property_name}" has unexpected value {json.dumps(existing_value)} that will be changed.')
  json_object[property_name] = target
  new_content = json.dumps(json_object, indent=2)
  file.write_text(new_content)
  print(f'Successfully configured "{property_name}" to {json.dumps(target)}.')
EOF
fi
if ! command -v 'python3' &> /dev/null; then
  echo 'Skipping because "python3" is not found.'
else
  python3 <<EOF
from pathlib import Path
import os, json, sys
property_name = 'update.channel'
target = json.loads('"none"')
home_dir = f'/home/{os.getenv("SUDO_USER", os.getenv("USER"))}'
settings_files = [
  # Global installation (also Snap that installs with "--classic" flag)
  f'{home_dir}/.config/Code/User/settings.json',
  # Flatpak installation
  f'{home_dir}/.var/app/com.visualstudio.code/config/Code/User/settings.json'
]
for settings_file in settings_files:
  file=Path(settings_file)
  if not file.is_file():
    print(f'Skipping, file does not exist at "{settings_file}".')
    continue
  print(f'Reading file at "{settings_file}".')
  file_content = file.read_text()
  if not file_content.strip():
    print('Settings file is empty. Treating it as default empty JSON object.')
    file_content = '{}'
  json_object = None
  try:
    json_object = json.loads(file_content)
  except json.JSONDecodeError:
    print(f'Error, invalid JSON format in the settings file: "{settings_file}".', file=sys.stderr)
    continue
  if property_name not in json_object:
    print(f'Settings "{property_name}" is not configured.')
  else:
    existing_value = json_object[property_name]
    if existing_value == target:
      print(f'Skipping, "{property_name}" is already configured as {json.dumps(target)}.')
      continue
    print(f'Setting "{property_name}" has unexpected value {json.dumps(existing_value)} that will be changed.')
  json_object[property_name] = target
  new_content = json.dumps(json_object, indent=2)
  file.write_text(new_content)
  print(f'Successfully configured "{property_name}" to {json.dumps(target)}.')
EOF
fi
# ----------------------------------------------------------


# Disable fetching release notes from Microsoft servers after an update
echo '--- Disable fetching release notes from Microsoft servers after an update'
if ! command -v 'python3' &> /dev/null; then
  echo 'Skipping because "python3" is not found.'
else
  python3 <<EOF
from pathlib import Path
import os, json, sys
property_name = 'update.showReleaseNotes'
target = json.loads('false')
home_dir = f'/home/{os.getenv("SUDO_USER", os.getenv("USER"))}'
settings_files = [
  # Global installation (also Snap that installs with "--classic" flag)
  f'{home_dir}/.config/Code/User/settings.json',
  # Flatpak installation
  f'{home_dir}/.var/app/com.visualstudio.code/config/Code/User/settings.json'
]
for settings_file in settings_files:
  file=Path(settings_file)
  if not file.is_file():
    print(f'Skipping, file does not exist at "{settings_file}".')
    continue
  print(f'Reading file at "{settings_file}".')
  file_content = file.read_text()
  if not file_content.strip():
    print('Settings file is empty. Treating it as default empty JSON object.')
    file_content = '{}'
  json_object = None
  try:
    json_object = json.loads(file_content)
  except json.JSONDecodeError:
    print(f'Error, invalid JSON format in the settings file: "{settings_file}".', file=sys.stderr)
    continue
  if property_name not in json_object:
    print(f'Settings "{property_name}" is not configured.')
  else:
    existing_value = json_object[property_name]
    if existing_value == target:
      print(f'Skipping, "{property_name}" is already configured as {json.dumps(target)}.')
      continue
    print(f'Setting "{property_name}" has unexpected value {json.dumps(existing_value)} that will be changed.')
  json_object[property_name] = target
  new_content = json.dumps(json_object, indent=2)
  file.write_text(new_content)
  print(f'Successfully configured "{property_name}" to {json.dumps(target)}.')
EOF
fi
# ----------------------------------------------------------


# Disable automatic fetching of remote repositories in Visual Studio Code
echo '--- Disable automatic fetching of remote repositories in Visual Studio Code'
if ! command -v 'python3' &> /dev/null; then
  echo 'Skipping because "python3" is not found.'
else
  python3 <<EOF
from pathlib import Path
import os, json, sys
property_name = 'git.autofetch'
target = json.loads('false')
home_dir = f'/home/{os.getenv("SUDO_USER", os.getenv("USER"))}'
settings_files = [
  # Global installation (also Snap that installs with "--classic" flag)
  f'{home_dir}/.config/Code/User/settings.json',
  # Flatpak installation
  f'{home_dir}/.var/app/com.visualstudio.code/config/Code/User/settings.json'
]
for settings_file in settings_files:
  file=Path(settings_file)
  if not file.is_file():
    print(f'Skipping, file does not exist at "{settings_file}".')
    continue
  print(f'Reading file at "{settings_file}".')
  file_content = file.read_text()
  if not file_content.strip():
    print('Settings file is empty. Treating it as default empty JSON object.')
    file_content = '{}'
  json_object = None
  try:
    json_object = json.loads(file_content)
  except json.JSONDecodeError:
    print(f'Error, invalid JSON format in the settings file: "{settings_file}".', file=sys.stderr)
    continue
  if property_name not in json_object:
    print(f'Settings "{property_name}" is not configured.')
  else:
    existing_value = json_object[property_name]
    if existing_value == target:
      print(f'Skipping, "{property_name}" is already configured as {json.dumps(target)}.')
      continue
    print(f'Setting "{property_name}" has unexpected value {json.dumps(existing_value)} that will be changed.')
  json_object[property_name] = target
  new_content = json.dumps(json_object, indent=2)
  file.write_text(new_content)
  print(f'Successfully configured "{property_name}" to {json.dumps(target)}.')
EOF
fi
# ----------------------------------------------------------


# Disable fetching package information from NPM and Bower in Visual Studio Code
echo '--- Disable fetching package information from NPM and Bower in Visual Studio Code'
if ! command -v 'python3' &> /dev/null; then
  echo 'Skipping because "python3" is not found.'
else
  python3 <<EOF
from pathlib import Path
import os, json, sys
property_name = 'npm.fetchOnlinePackageInfo'
target = json.loads('false')
home_dir = f'/home/{os.getenv("SUDO_USER", os.getenv("USER"))}'
settings_files = [
  # Global installation (also Snap that installs with "--classic" flag)
  f'{home_dir}/.config/Code/User/settings.json',
  # Flatpak installation
  f'{home_dir}/.var/app/com.visualstudio.code/config/Code/User/settings.json'
]
for settings_file in settings_files:
  file=Path(settings_file)
  if not file.is_file():
    print(f'Skipping, file does not exist at "{settings_file}".')
    continue
  print(f'Reading file at "{settings_file}".')
  file_content = file.read_text()
  if not file_content.strip():
    print('Settings file is empty. Treating it as default empty JSON object.')
    file_content = '{}'
  json_object = None
  try:
    json_object = json.loads(file_content)
  except json.JSONDecodeError:
    print(f'Error, invalid JSON format in the settings file: "{settings_file}".', file=sys.stderr)
    continue
  if property_name not in json_object:
    print(f'Settings "{property_name}" is not configured.')
  else:
    existing_value = json_object[property_name]
    if existing_value == target:
      print(f'Skipping, "{property_name}" is already configured as {json.dumps(target)}.')
      continue
    print(f'Setting "{property_name}" has unexpected value {json.dumps(existing_value)} that will be changed.')
  json_object[property_name] = target
  new_content = json.dumps(json_object, indent=2)
  file.write_text(new_content)
  print(f'Successfully configured "{property_name}" to {json.dumps(target)}.')
EOF
fi
# ----------------------------------------------------------


# Disable sending search queries to Microsoft in Visual Studio Code
echo '--- Disable sending search queries to Microsoft in Visual Studio Code'
if ! command -v 'python3' &> /dev/null; then
  echo 'Skipping because "python3" is not found.'
else
  python3 <<EOF
from pathlib import Path
import os, json, sys
property_name = 'workbench.settings.enableNaturalLanguageSearch'
target = json.loads('false')
home_dir = f'/home/{os.getenv("SUDO_USER", os.getenv("USER"))}'
settings_files = [
  # Global installation (also Snap that installs with "--classic" flag)
  f'{home_dir}/.config/Code/User/settings.json',
  # Flatpak installation
  f'{home_dir}/.var/app/com.visualstudio.code/config/Code/User/settings.json'
]
for settings_file in settings_files:
  file=Path(settings_file)
  if not file.is_file():
    print(f'Skipping, file does not exist at "{settings_file}".')
    continue
  print(f'Reading file at "{settings_file}".')
  file_content = file.read_text()
  if not file_content.strip():
    print('Settings file is empty. Treating it as default empty JSON object.')
    file_content = '{}'
  json_object = None
  try:
    json_object = json.loads(file_content)
  except json.JSONDecodeError:
    print(f'Error, invalid JSON format in the settings file: "{settings_file}".', file=sys.stderr)
    continue
  if property_name not in json_object:
    print(f'Settings "{property_name}" is not configured.')
  else:
    existing_value = json_object[property_name]
    if existing_value == target:
      print(f'Skipping, "{property_name}" is already configured as {json.dumps(target)}.')
      continue
    print(f'Setting "{property_name}" has unexpected value {json.dumps(existing_value)} that will be changed.')
  json_object[property_name] = target
  new_content = json.dumps(json_object, indent=2)
  file.write_text(new_content)
  print(f'Successfully configured "{property_name}" to {json.dumps(target)}.')
EOF
fi
# ----------------------------------------------------------


# Disable Visual Studio Code automatic type acquisition in TypeScript
echo '--- Disable Visual Studio Code automatic type acquisition in TypeScript'
if ! command -v 'python3' &> /dev/null; then
  echo 'Skipping because "python3" is not found.'
else
  python3 <<EOF
from pathlib import Path
import os, json, sys
property_name = 'typescript.disableAutomaticTypeAcquisition'
target = json.loads('false')
home_dir = f'/home/{os.getenv("SUDO_USER", os.getenv("USER"))}'
settings_files = [
  # Global installation (also Snap that installs with "--classic" flag)
  f'{home_dir}/.config/Code/User/settings.json',
  # Flatpak installation
  f'{home_dir}/.var/app/com.visualstudio.code/config/Code/User/settings.json'
]
for settings_file in settings_files:
  file=Path(settings_file)
  if not file.is_file():
    print(f'Skipping, file does not exist at "{settings_file}".')
    continue
  print(f'Reading file at "{settings_file}".')
  file_content = file.read_text()
  if not file_content.strip():
    print('Settings file is empty. Treating it as default empty JSON object.')
    file_content = '{}'
  json_object = None
  try:
    json_object = json.loads(file_content)
  except json.JSONDecodeError:
    print(f'Error, invalid JSON format in the settings file: "{settings_file}".', file=sys.stderr)
    continue
  if property_name not in json_object:
    print(f'Settings "{property_name}" is not configured.')
  else:
    existing_value = json_object[property_name]
    if existing_value == target:
      print(f'Skipping, "{property_name}" is already configured as {json.dumps(target)}.')
      continue
    print(f'Setting "{property_name}" has unexpected value {json.dumps(existing_value)} that will be changed.')
  json_object[property_name] = target
  new_content = json.dumps(json_object, indent=2)
  file.write_text(new_content)
  print(f'Successfully configured "{property_name}" to {json.dumps(target)}.')
EOF
fi
# ----------------------------------------------------------


# ----------------------------------------------------------
# ---------Disable Visual Studio Code Edit Sessions---------
# ----------------------------------------------------------
echo '--- Disable Visual Studio Code Edit Sessions'
if ! command -v 'python3' &> /dev/null; then
  echo 'Skipping because "python3" is not found.'
else
  python3 <<EOF
from pathlib import Path
import os, json, sys
property_name = 'workbench.experimental.editSessions.enabled'
target = json.loads('false')
home_dir = f'/home/{os.getenv("SUDO_USER", os.getenv("USER"))}'
settings_files = [
  # Global installation (also Snap that installs with "--classic" flag)
  f'{home_dir}/.config/Code/User/settings.json',
  # Flatpak installation
  f'{home_dir}/.var/app/com.visualstudio.code/config/Code/User/settings.json'
]
for settings_file in settings_files:
  file=Path(settings_file)
  if not file.is_file():
    print(f'Skipping, file does not exist at "{settings_file}".')
    continue
  print(f'Reading file at "{settings_file}".')
  file_content = file.read_text()
  if not file_content.strip():
    print('Settings file is empty. Treating it as default empty JSON object.')
    file_content = '{}'
  json_object = None
  try:
    json_object = json.loads(file_content)
  except json.JSONDecodeError:
    print(f'Error, invalid JSON format in the settings file: "{settings_file}".', file=sys.stderr)
    continue
  if property_name not in json_object:
    print(f'Settings "{property_name}" is not configured.')
  else:
    existing_value = json_object[property_name]
    if existing_value == target:
      print(f'Skipping, "{property_name}" is already configured as {json.dumps(target)}.')
      continue
    print(f'Setting "{property_name}" has unexpected value {json.dumps(existing_value)} that will be changed.')
  json_object[property_name] = target
  new_content = json.dumps(json_object, indent=2)
  file.write_text(new_content)
  print(f'Successfully configured "{property_name}" to {json.dumps(target)}.')
EOF
fi
if ! command -v 'python3' &> /dev/null; then
  echo 'Skipping because "python3" is not found.'
else
  python3 <<EOF
from pathlib import Path
import os, json, sys
property_name = 'workbench.experimental.editSessions.autoStore'
target = json.loads('false')
home_dir = f'/home/{os.getenv("SUDO_USER", os.getenv("USER"))}'
settings_files = [
  # Global installation (also Snap that installs with "--classic" flag)
  f'{home_dir}/.config/Code/User/settings.json',
  # Flatpak installation
  f'{home_dir}/.var/app/com.visualstudio.code/config/Code/User/settings.json'
]
for settings_file in settings_files:
  file=Path(settings_file)
  if not file.is_file():
    print(f'Skipping, file does not exist at "{settings_file}".')
    continue
  print(f'Reading file at "{settings_file}".')
  file_content = file.read_text()
  if not file_content.strip():
    print('Settings file is empty. Treating it as default empty JSON object.')
    file_content = '{}'
  json_object = None
  try:
    json_object = json.loads(file_content)
  except json.JSONDecodeError:
    print(f'Error, invalid JSON format in the settings file: "{settings_file}".', file=sys.stderr)
    continue
  if property_name not in json_object:
    print(f'Settings "{property_name}" is not configured.')
  else:
    existing_value = json_object[property_name]
    if existing_value == target:
      print(f'Skipping, "{property_name}" is already configured as {json.dumps(target)}.')
      continue
    print(f'Setting "{property_name}" has unexpected value {json.dumps(existing_value)} that will be changed.')
  json_object[property_name] = target
  new_content = json.dumps(json_object, indent=2)
  file.write_text(new_content)
  print(f'Successfully configured "{property_name}" to {json.dumps(target)}.')
EOF
fi
if ! command -v 'python3' &> /dev/null; then
  echo 'Skipping because "python3" is not found.'
else
  python3 <<EOF
from pathlib import Path
import os, json, sys
property_name = 'workbench.editSessions.autoResume'
target = json.loads('false')
home_dir = f'/home/{os.getenv("SUDO_USER", os.getenv("USER"))}'
settings_files = [
  # Global installation (also Snap that installs with "--classic" flag)
  f'{home_dir}/.config/Code/User/settings.json',
  # Flatpak installation
  f'{home_dir}/.var/app/com.visualstudio.code/config/Code/User/settings.json'
]
for settings_file in settings_files:
  file=Path(settings_file)
  if not file.is_file():
    print(f'Skipping, file does not exist at "{settings_file}".')
    continue
  print(f'Reading file at "{settings_file}".')
  file_content = file.read_text()
  if not file_content.strip():
    print('Settings file is empty. Treating it as default empty JSON object.')
    file_content = '{}'
  json_object = None
  try:
    json_object = json.loads(file_content)
  except json.JSONDecodeError:
    print(f'Error, invalid JSON format in the settings file: "{settings_file}".', file=sys.stderr)
    continue
  if property_name not in json_object:
    print(f'Settings "{property_name}" is not configured.')
  else:
    existing_value = json_object[property_name]
    if existing_value == target:
      print(f'Skipping, "{property_name}" is already configured as {json.dumps(target)}.')
      continue
    print(f'Setting "{property_name}" has unexpected value {json.dumps(existing_value)} that will be changed.')
  json_object[property_name] = target
  new_content = json.dumps(json_object, indent=2)
  file.write_text(new_content)
  print(f'Successfully configured "{property_name}" to {json.dumps(target)}.')
EOF
fi
if ! command -v 'python3' &> /dev/null; then
  echo 'Skipping because "python3" is not found.'
else
  python3 <<EOF
from pathlib import Path
import os, json, sys
property_name = 'workbench.editSessions.continueOn'
target = json.loads('false')
home_dir = f'/home/{os.getenv("SUDO_USER", os.getenv("USER"))}'
settings_files = [
  # Global installation (also Snap that installs with "--classic" flag)
  f'{home_dir}/.config/Code/User/settings.json',
  # Flatpak installation
  f'{home_dir}/.var/app/com.visualstudio.code/config/Code/User/settings.json'
]
for settings_file in settings_files:
  file=Path(settings_file)
  if not file.is_file():
    print(f'Skipping, file does not exist at "{settings_file}".')
    continue
  print(f'Reading file at "{settings_file}".')
  file_content = file.read_text()
  if not file_content.strip():
    print('Settings file is empty. Treating it as default empty JSON object.')
    file_content = '{}'
  json_object = None
  try:
    json_object = json.loads(file_content)
  except json.JSONDecodeError:
    print(f'Error, invalid JSON format in the settings file: "{settings_file}".', file=sys.stderr)
    continue
  if property_name not in json_object:
    print(f'Settings "{property_name}" is not configured.')
  else:
    existing_value = json_object[property_name]
    if existing_value == target:
      print(f'Skipping, "{property_name}" is already configured as {json.dumps(target)}.')
      continue
    print(f'Setting "{property_name}" has unexpected value {json.dumps(existing_value)} that will be changed.')
  json_object[property_name] = target
  new_content = json.dumps(json_object, indent=2)
  file.write_text(new_content)
  print(f'Successfully configured "{property_name}" to {json.dumps(target)}.')
EOF
fi
# ----------------------------------------------------------


# ----------------------------------------------------------
# ------------------Disable .NET telemetry------------------
# ----------------------------------------------------------
echo '--- Disable .NET telemetry'
variable='DOTNET_CLI_TELEMETRY_OPTOUT'
value='1'
declaration_file='/etc/environment'
if ! [ -f "$declaration_file" ]; then
  echo "\"$declaration_file\" does not exist."
  sudo touch "$declaration_file"
  echo "Created $declaration_file."
fi
assignment_start="$variable="
assignment="$variable=$value"
if ! grep --quiet "^$assignment_start" "${declaration_file}"; then
  echo "Variable \"$variable\" was not configured before."
  echo -n $'\n'"$assignment" | sudo tee -a "$declaration_file" > /dev/null
  echo "Successfully configured ($assignment)."
else
  if grep --quiet "^$assignment$" "${declaration_file}"; then
    echo "Skipping. Variable \"$variable\" is already set to value \"$value\"."
  else
    if ! sudo sed --in-place "/^$assignment_start/d" "$declaration_file"; then
      >&2 echo "Failed to delete assignment starting with \"$assignment_start\"."
    else
      echo "Successfully deleted unexpected assignment of \"$variable\"."
      if ! echo -n $'\n'"$assignment" | sudo tee -a "$declaration_file" > /dev/null; then
        >&2 echo "Failed to add assignment \"$assignment\"."
      else
        echo "Successfully reconfigured ($assignment)."
      fi
    fi
  fi
fi
# ----------------------------------------------------------


# ----------------------------------------------------------
# ------------Disable PowerShell Core telemetry-------------
# ----------------------------------------------------------
echo '--- Disable PowerShell Core telemetry'
variable='POWERSHELL_TELEMETRY_OPTOUT'
value='1'
declaration_file='/etc/environment'
if ! [ -f "$declaration_file" ]; then
  echo "\"$declaration_file\" does not exist."
  sudo touch "$declaration_file"
  echo "Created $declaration_file."
fi
assignment_start="$variable="
assignment="$variable=$value"
if ! grep --quiet "^$assignment_start" "${declaration_file}"; then
  echo "Variable \"$variable\" was not configured before."
  echo -n $'\n'"$assignment" | sudo tee -a "$declaration_file" > /dev/null
  echo "Successfully configured ($assignment)."
else
  if grep --quiet "^$assignment$" "${declaration_file}"; then
    echo "Skipping. Variable \"$variable\" is already set to value \"$value\"."
  else
    if ! sudo sed --in-place "/^$assignment_start/d" "$declaration_file"; then
      >&2 echo "Failed to delete assignment starting with \"$assignment_start\"."
    else
      echo "Successfully deleted unexpected assignment of \"$variable\"."
      if ! echo -n $'\n'"$assignment" | sudo tee -a "$declaration_file" > /dev/null; then
        >&2 echo "Failed to add assignment \"$assignment\"."
      else
        echo "Successfully reconfigured ($assignment)."
      fi
    fi
  fi
fi
# ----------------------------------------------------------


# ----------------------------------------------------------
# --Disable Python history for future interactive commands--
# ----------------------------------------------------------
echo '--- Disable Python history for future interactive commands'
history_file="$HOME/.python_history"
if [ ! -f "$history_file" ]; then
  touch "$history_file"
  echo "Created $history_file."
fi
sudo chattr +i "$(realpath $history_file)" # realpath in case of symlink
# ----------------------------------------------------------


echo 'Your privacy and security is now hardened 🎉💪'
echo 'Press any key to exit.'
read -n 1 -s