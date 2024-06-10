#!/bin/bash

# ASCII Art "MUSIC FEST ON" e firma "by ceck90"
echo "  __  __ _    _  _____ _____ _____   ______ ______  _____ _______    ____  _   _ "
echo " |  \/  | |  | |/ ____|_   _/ ____| |  ____|  ____|/ ____|__   __|  / __ \| \ | |"
echo " | \  / | |  | | (___   | || |      | |__  | |__  | (___    | |    | |  | |  \| |"
echo " | |\/| | |  | |\___ \  | || |      |  __| |  __|  \___ \   | |    | |  | | .   |"
echo " | |  | | |__| |____) |_| || |____  | |    | |____ ____) |  | |    | |__| | |\  |"
echo " |_|  |_|\____/|_____/|_____\_____| |_|    |______|_____/   |_|     \____/|_| \_|"
echo "                                                                                 "
echo "                            MONITOR PER PIASTRE CUCINA                           "
echo "                       INSTALLAZIONE ED AVVIO AUTOMATICO UI                      "
echo "                                                                                 "
echo "                                                                 by ceck90       "
echo "                                                              CECCATO ROBERTO    "
echo ""

# File name
DEFAULT_PATH="/home/$USER/Scrivania/MusicFestOn"
SCRIPT_NAME="start_piastre_web.sh"
SERVICE_NAME="piastre_web.service"
CFG_FILE_NAME="piastre_cfg.json"

# Percorsi dei file
SCRIPT_PATH="$DEFAULT_PATH/$SCRIPT_NAME"
JSON_PATH="$DEFAULT_PATH/$CFG_FILE_NAME"
SERVICE_PATH="/etc/systemd/system/$SERVICE_NAME"

# URL di default
DEFAULT_URL="http://192.168.1.21"


install_dependencies() {
# Funzione per installare Chromium se non è già installato
    echo ""
    if ! command -v chromium-browser &> /dev/null
    then
        echo "Chromium non è installato. Installazione in corso..."
        sudo apt-get update
        sudo apt-get install -y chromium-browser
    else
        echo "Chromium è già installato."
    fi

# Funzione per installare jq se non è già installato
    echo ""
    if ! command -v jq &> /dev/null
    then
        echo "jq non è installato. Installazione in corso..."
        sudo apt-get update
        sudo apt-get install -y jq
    else
        echo "jq è già installato."
    fi

# Funzione per installare git se non è già installato
    echo ""
    if ! command -v git &> /dev/null
    then
        echo "Git non è installato. Installazione in corso..."
        sudo apt-get update
        sudo apt-get install -y git
    else
        echo "Git è già installato."
    fi

# Funzione per installare htop se non è già installato
    echo ""
    if ! command -v htop &> /dev/null
    then
        echo "htop non è installato. Installazione in corso..."
        sudo apt-get update
        sudo apt-get install -y htop
    else
        echo "htop è già installato."
    fi

# Funzione per installare net-tools se non è già installato
    echo ""
    if ! dpkg -s net-tools &> /dev/null
    then
        echo "net-tools non è installato. Installazione in corso..."
        sudo apt-get update
        sudo apt-get install -y net-tools
    else
        echo "net-tools è già installato."
    fi
}

# Funzione per disattivare la disattivazione automatica
disable_ubuntu_suspend() {
    echo ""
    echo "Rimozione del timeout dello schermo in corso..."
    gsettings set org.gnome.desktop.session idle-delay 0
    echo "Timeout dello schermo rimosso."

    echo "Disattivazione della disattivazione automatica in corso..."
    gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-ac-timeout 0
    gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-battery-timeout 0
    echo "Disattivazione automatica disabilitata."

    echo "Disabilitazione dello screen saver in corso..."
    gsettings set org.gnome.desktop.screensaver idle-activation-enabled false
    echo "Screen saver disabilitato."
}

# Funzione per abilitare l'accesso root tramite SSH e a tutti gli IP
configure_ssh() {
    echo ""
    echo "Abilitazione dell'accesso root tramite SSH..."
    sudo sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config
    echo "Accesso root tramite SSH abilitato."

    echo "Consentire l'accesso SSH da qualsiasi IP..."
    sudo sed -i 's/#ListenAddress 0.0.0.0/ListenAddress 0.0.0.0/' /etc/ssh/sshd_config
    sudo sed -i 's/#ListenAddress ::/ListenAddress ::/' /etc/ssh/sshd_config
    echo "Accesso SSH da qualsiasi IP consentito."

    sudo systemctl restart sshd
}

# Funzione per creare i file necessari
create_files() {

    if [ -d $DEFAULT_PATH ]; 
    then
        echo "Directory $DEFAULT_PATH exists."
    else
        mkdir -p $DEFAULT_PATH
        echo "Directory $DEFAULT_PATH created successfully."
    fi

    
    # Controlla se è stato passato un argomento per l'URL
    if [ -n "$1" ]; then
        URL="$1"
    else
        URL="$DEFAULT_URL"
    fi

    # Contenuto del file start_kiosk.sh
    read -r -d '' SCRIPT_CONTENT << EOM
#!/bin/bash

# Percorso del file JSON
json_file_path="$JSON_PATH"

# Legge l'URL dal file JSON usando jq
url=\$(jq -r '.url' "\$json_file_path")

# Comando per avviare Chromium in modalità kiosk
chromium-browser --kiosk "\$url"
EOM

# Contenuto del file config.json
read -r -d '' JSON_CONTENT << EOM
{
    "url": "$URL"
}
EOM

# Contenuto del servizio systemd
read -r -d '' SERVICE_CONTENT << EOM
[Unit]
Description=Music FestOn Piastre WEB Kiosk Mode

[Service]
ExecStartPre=pkill -9 chrome
ExecStart=/bin/bash $SCRIPT_PATH
ExecStop=pkill -9 chrome
Restart=always
User=$USER
Environment=DISPLAY=:0

[Install]
WantedBy=graphical.target
EOM

    # Creare il file script
    echo "$SCRIPT_CONTENT" > $SCRIPT_PATH
    chmod +x $SCRIPT_PATH
    echo "Script $SCRIPT_NAME creato in $SCRIPT_PATH."

    # Creare il file config
    echo "$JSON_CONTENT" > $JSON_PATH
    echo "File $CFG_FILE_NAME creato in $JSON_PATH."

    # Creare il servizio systemd
    echo "$SERVICE_CONTENT" | sudo tee $SERVICE_PATH > /dev/null
    sudo systemctl daemon-reload > /dev/null
    echo "Servizio $SERVICE_NAME creato in $SERVICE_PATH."
}

# Funzione per abilitare e avviare il servizio
enable_and_start_service() {
    echo ""
    sudo systemctl enable $SERVICE_NAME
    sudo systemctl start $SERVICE_NAME
    echo "Servizio $SERVICE_NAME abilitato ed avviato."
}

# Funzione per mostrare il menu
show_menu() {
    echo ""
    echo "Seleziona un'opzione:"
    echo "1) Installa pacchetti necessari"
    echo "2) Crea file di configurazione"
    echo "3) Abilita e avvia il servizio"
    echo "4) Disattiva screensaver e powersave di Ubuntu"
    echo "5) Abilita accesso SSH remoto"
    echo "9) Esegui tutte le operazioni"
    echo "0) Esci"
}

# Inizio del menu
while true; do
    show_menu
    read -p "Scelta: " choice
    case $choice in
        1)
            install_dependencies
            ;;
        2)
            read -p "Inserisci l'URL (premi invio per usare il default $DEFAULT_URL): " custom_url
            create_files "${custom_url:-$DEFAULT_URL}"
            ;;
        3)
            enable_and_start_service
            ;;
        4)
            disable_ubuntu_suspend
            ;;
        5)
            configure_ssh
            ;;            
        6)
            ;;
        7)
            ;;
        8)
            ;;
        9)
            install_dependencies
            disable_ubuntu_suspend
            configure_ssh
            read -p "Inserisci l'URL (premi invio per usare il default $DEFAULT_URL): " custom_url
            create_files "${custom_url:-$DEFAULT_URL}"
            enable_and_start_service
            ;;
        0)
            echo "Uscita."
            exit 0
            ;;
        *)
            echo "Scelta non valida. Riprova."
            ;;
    esac
done
