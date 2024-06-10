#!/bin/bash

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
    # Percorsi dei file
    SCRIPT_PATH="/home/pi/start_kiosk.sh"
    JSON_PATH="/home/pi/config.json"
    SERVICE_PATH="/etc/systemd/system/kiosk.service"

    # Contenuto del file start_kiosk.sh
    read -r -d '' SCRIPT_CONTENT << EOM
#!/bin/bash

# Percorso del file JSON
json_file_path="/home/pi/config.json"

# Legge l'URL dal file JSON usando jq
url=\$(jq -r '.url' "\$json_file_path")

# Comando per avviare Chromium in modalità kiosk
chromium-browser --kiosk "\$url"
EOM

    # Contenuto del file config.json
    read -r -d '' JSON_CONTENT << EOM
{
    "url": "http://www.example.com"
}
EOM

    # Contenuto del servizio systemd
    read -r -d '' SERVICE_CONTENT << EOM
[Unit]
Description=Kiosk Mode

[Service]
ExecStart=/bin/bash /home/pi/start_kiosk.sh
Restart=always
User=pi
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
    sudo systemctl enable kiosk.service
    sudo systemctl start kiosk.service
    echo "Servizio kiosk.service abilitato e avviato."
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
            create_files
            ;;
        4)
            enable_and_start_service
            ;;
        5)
            install_chromium
            install_jq
            create_files
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
