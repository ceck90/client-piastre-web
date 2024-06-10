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

# Funzione per installare Chromium se non è già installato
install_chromium() {
    if ! command -v chromium-browser &> /dev/null
    then
        echo "Chromium non è installato. Installazione in corso..."
        sudo apt-get update
        sudo apt-get install -y chromium-browser
    else
        echo "Chromium è già installato."
    fi
}

# Funzione per installare jq se non è già installato
install_jq() {
    if ! command -v jq &> /dev/null
    then
        echo "jq non è installato. Installazione in corso..."
        sudo apt-get update
        sudo apt-get install -y jq
    else
        echo "jq è già installato."
    fi
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
ExecStart=/bin/bash $SCRIPT_PATH
Restart=always
User=$USER
Environment=DISPLAY=:0

[Install]
WantedBy=graphical.target
EOM

    # Creare il file start_kiosk.sh
    echo "$SCRIPT_CONTENT" > $SCRIPT_PATH
    chmod +x $SCRIPT_PATH
    echo "Script start_kiosk.sh creato in $SCRIPT_PATH."

    # Creare il file config.json
    echo "$JSON_CONTENT" > $JSON_PATH
    echo "File config.json creato in $JSON_PATH."

    # Creare il servizio systemd
    echo "$SERVICE_CONTENT" | sudo tee $SERVICE_PATH > /dev/null
    echo "Servizio systemd creato in $SERVICE_PATH."
}

# Funzione per abilitare e avviare il servizio
enable_and_start_service() {
    sudo systemctl enable $SERVICE_NAME
    sudo systemctl start $SERVICE_NAME
    echo "Servizio $SERVICE_NAME abilitato e avviato."
}

# Funzione per mostrare il menu
show_menu() {
    echo "Seleziona un'opzione:"
    echo "1) Installa Chromium"
    echo "2) Installa jq"
    echo "3) Crea file di configurazione"
    echo "4) Abilita e avvia il servizio"
    echo "5) Esegui tutte le operazioni"
    echo "6) Esci"
}

# Inizio del menu
while true; do
    show_menu
    read -p "Scelta: " choice
    case $choice in
        1)
            install_chromium
            ;;
        2)
            install_jq
            ;;
        3)
            read -p "Inserisci l'URL (premi invio per usare il default $DEFAULT_URL): " custom_url
            create_files "${custom_url:-$DEFAULT_URL}"
            ;;
        4)
            enable_and_start_service
            ;;
        5)
            install_chromium
            install_jq
            read -p "Inserisci l'URL (premi invio per usare il default $DEFAULT_URL): " custom_url
            create_files "${custom_url:-$DEFAULT_URL}"
            enable_and_start_service
            ;;
        6)
            echo "Uscita."
            exit 0
            ;;
        *)
            echo "Scelta non valida. Riprova."
            ;;
    esac
done
