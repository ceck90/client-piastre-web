# Music FestOn - Mellaredo di Pianiga
#### by ceck90 
https://github.com/ceck90
### Raspberry Pi Kiosk Mode Setup per UI piastre cucina

Questo repository contiene uno script per configurare un Raspberry Pi in modalità kiosk, utilizzando Chromium per visualizzare una pagina web specificata in un file JSON.

## Requisiti

- Raspberry Pi 3/4 con Ubuntu 22 o superiori installato
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
- Crea i file necessari (`start_piastre_web.sh` e `piastre_cfg.json`) nella directory `/home/user/Scrivania/MusicFestOn`.
- Crea e abilita un servizio systemd per avviare Chromium in modalità kiosk all'avvio del sistema.

### Attenzione, nel caso che l'utente sia diverso da 'user', verrà autmaticamente usato l'utente corrente nel sistema

## Menu di Installazione

Lo script di installazione include un menu per guidare l'utente attraverso il processo di installazione. Le opzioni disponibili sono:

1. Installa pacchetti necessari e tool di debug
2. Crea file di configurazione
3. Abilita e avvia il servizio
4. Disattiva screensaver e poersave di Ubuntu
5. Abilita accesso SSH remoto
6.  
7. 
8. 
9. Esegui tutte le operazioni
10. Esci

## File di Configurazione

### `piastre_cfg.json`

Questo file contiene l'URL da caricare in modalità kiosk:

```json
{
    "url": "http://192.168.1.21"
}
```

### Avvio manuale

```
/home/user/Scrivania/MusicFestOn/start_piastre_web.sh
```

### Debug del servizio

```
sudo systemctl status piastre_web.service
```

### Disattivazione avvio automatico del servizio

```
sudo systemctl disable piastre_web.service
```

### Avvio automatico del servizio

```
sudo systemctl enable piastre_web.service
```