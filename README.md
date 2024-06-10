# Raspberry Pi Kiosk Mode Setup

Questo repository contiene uno script per configurare un Raspberry Pi in modalità kiosk, utilizzando Chromium per visualizzare una pagina web specificata in un file JSON.

## Requisiti

- Raspberry Pi con Ubuntu installato
- Connessione a Internet

## Installazione

1. Clona questo repository nella tua directory locale:

    ```sh
    git clone https://github.com/ceck90/client-piastre-web.git /home/user/Scrivania
    cd /home/user/Scrivania
    ```

2. Rendi eseguibile lo script di installazione:

    ```sh
    chmod +x install_kiosk.sh
    ```

3. Esegui lo script di installazione:

    ```sh
    ./install_kiosk.sh
    ```

## Script di Installazione

Lo script `install_kiosk.sh` esegue le seguenti operazioni:

- Controlla e installa Chromium se non è già presente.
- Controlla e installa `jq` se non è già presente.
- Crea i file necessari (`start_kiosk.sh` e `config.json`) nella directory `/home/pi`.
- Crea e abilita un servizio systemd per avviare Chromium in modalità kiosk all'avvio del sistema.

## Menu di Installazione

Lo script di installazione include un menu per guidare l'utente attraverso il processo di installazione. Le opzioni disponibili sono:

1. Installa Chromium
2. Installa jq
3. Crea file di configurazione
4. Abilita e avvia il servizio
5. Esegui tutte le operazioni
6. Esci

## File di Configurazione

### `config.json`

Questo file contiene l'URL da caricare in modalità kiosk:

```json
{
    "url": "http://192.168.1.21"
}
