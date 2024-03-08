#!/bin/bash

RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

# Fonction pour afficher un message d'erreur et quitter le script avec un code d'erreur
print_error_and_exit() {
    echo -e"${RED} Erreur: $1" >&2
    exit 1
}

# Fonction update
update() {
    echo -e "${BLUE} Mise à jour du système en cours... ${NC}"
    sudo apt-get update || print_error_and_exit "Echec de l'update système"
    sudo apt-get upgrade -y || print_error_and_exit "Echec de l'upgrade système"
    echo -e "${GREEN} Fin mise à jour du système."
}

# Fonction pour installer curl
install_curl() {
    echo -e "${BLUE} Installation de curl en cours... ${NC}"
    sudo apt install -y curl || print_error_and_exit "Échec de l'installation de curl"
    echo -e "${GREEN} Installation de curl terminée."
}

# Fonction pour installer Docker
install_docker() {
    echo -e "${BLUE} Installation de Docker en cours... ${NC}"
    curl -fsSL "https://get.docker.com/" -o get-docker.sh || print_error_and_exit "Échec de téléchargement de Docker"
    sudo sh get-docker.sh || print_error_and_exit "Échec de l'installation de Docker"
    sudo usermod -aG docker "$(id -u -n)" || print_error_and_exit "Échec de l'ajout de l'utilisateur au groupe docker"
    newgrp docker || print_error_and_exit "Échec du chargement des nouveaux groupes"
    echo -e "${GREEN} Installation de Docker terminée."
}

# Fonction pour installer pip et les modules Python
install_portainer() {
    echo -e "${BLUE} Installation de portainer en cours... ${NC}"
    docker pull portainer/portainer-ce:latest || print_error_and_exit "Echec du téléchargement de l'image docker portainer!"
    docker run -d -p 9000:9000 -p 9443:9443 --name=portainer --restart=always -v /var/run/docker.sock:/var/run/docker.sock -v portainer_data:/data portainer/portainer-ce:latest || print_error_and_exit "Echec du démarrage du conteneur"
    echo -e "${GREEN} Installation de portainer terminée."
}

# Fonction pour install Pi-hole
install_pihole() {
    echo -e "${BLUE} Installation et configuration de pi-hole en cours... ${NC}"
    curl https://raw.githubusercontent.com/sKillseries/pi-hole-dockercompose/main/docker-compose.yml  -o docker-compose.yml || print_error_and_exit "Echec du téléchargement du dockerfile pihole"
    sed -i "s/WEBPASSWORD: 'YourPassword'/WEBPASSWORD: '$password'/" ./docker-compose.yml
    docker compose up  -d || print_error_and_exit "Echec du démarrage du conteneur"
    echo -e "${GREEN} Installation et configuration terminée."
}

# Menu d'options
echo "Choisissez une option :"
echo "1. Installer docker"
echo "2. Installer portainer"
echo "3. Installer pi-hole"
echo "4. Quitter"

read -p "Votre choix : " choice

case $choice in
    1)
        update
        install_curl
        install_docker ;;
    2)
        install_python_packages ;;
    3)
        read -p "Mot de passe désiré pour Pi-Hole: " password
        install_pihole ;;
    4)
        echo "Sortie du script." ;;
    *)
        print_error_and_exit "Option invalide." ;;
esac

echo -e "${YELLOW} Veuillez redémarrer votre système d'exploitation. Sauf si étape installation pi-hole"

exit 0
