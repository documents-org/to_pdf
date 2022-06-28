# ToPdf (0.3.0, 2021/10/12)

## Fonctionnalités

Pour le moment, toPdf supporte ces fonctionnalités :

- [x] Authentification par token  
- [x] Générer un PDF avec wkhtmltopdf comme moteur  
- [ ] Générer un PDF avec chrome comme moteur  
- [x] Générer un PDF à partir de HTML pré-rendu  
- [x] Générer un PDF à partir d'une URL
- [x] Proxy HTTP pour contourner d'éventuels problèmes de certificats
- [ ] Usage d'une "job queue"
- [x] Envoyer un e-mail avec un lien de téléchargement du PDF (valable 5 fois)  
- [x] Renvoyer automatiquement les e-mails en cas d'échec (incremental retry, 5 fois, espacé de n * 5 secondes)  
- [ ] Internationalisation des messages aux utilisateurs
- [x] Avertir d'une conversion PDF échouée  
- [x] Avertir d'une défaillance longue durée de l'API d'envoi d'e-mails  
- [x] Directement streamer le PDF en réponse à la requête  
- [ ] Panneau de contrôle pour voir les jobs  
- [ ] Panneau de contrôle pour voir les utilisateurs  

![](github/screenshot.png)

## Installation
Installer les dépendances avec `mix deps.get`.
Fournir les variables d'environnement nécessaires (voir le fichier `.env.template`) :

```bash
export SECRET_KEY_BASE=
export MAILJET_API_KEY=
export MAILJET_API_SECRET=
export MAIL_FROM_NAME=
export MAIL_FROM_ADDRESS=
export APP_DEVELOPER_EMAIL=
export TOPDF_PUBLIC_URL=
export TOPDF_PROXIFIED_URL=(facultatif, si vous souhaitez utiliser le proxy)
```

## Authentification 

Pour le moment, une liste de tokens est à fournir en fichier de configuration dans `~/.config/to_pdf/tokens`, un token par ligne.

## Usage

Envoyer un `POST` (ou un GET si il s'agit de visiter une URL) sur `/print`, avec ces paramètres :

```elixir
%{
  token: <string>
  email: <string> | nil
  proxy: true | false | nil
  type: "url" | "html_body"
  data: <string : url to visit> | <string : long rendered html body>
  printer: "webkit" (ok) | "chrome" (non implémenté)
  printer_params: <shell printer parameters: no user-controlled input>
}
```

Si `email` est `nil`, vous recevrez le PDF en corps de la réponse.

## Implémentation

Pour le moment, le gros du travail est fait dans ces modules :

- Piper (piper.ex) : utilitaire pour réprésenter des pipelines d'étapes de travail pouvant échouer
- DownloadAgent (download_agent.ex) : Gère les liens de téléchargement et leur expiration
- DownloadServer (download_server.ex) : Gère l'intervalle de collecte des liens expirés
- AuthAgent (auth_agent.ex) : S'occupe de charger et vérifier les tokens valides
- Printer (printer.ex) : Contient la délégation des tâches à Chrome / Wkhtmltopdf
- Notifier (notifier.ex) : Envoie les notifications de succès ou d'échec des tâches
- Proxy (proxy.ex) : Télécharge des ressources HTTPs (images, scripts, css) et les rend disponibles à des URLs locales en HTTP pour éviter les problèmes de wkhtmltopdf avec les certificats let's encrypt depuis le 30/09/2021

## Configurer un serveur vierge pour l'impression

```
# Envoyer la release sur le serveur
# Si vous utilisez le moteur wkhtmltopdf
sudo apt install wkhtmltopdf

# Si vous utilisez Chromium
# Installer npm (par exemple via la distro)
sudo apt install npm
sudo npm i -g puppeteer-pdf
sudo npm i -g puppeteer
# Voir le problème soulevé ici : https://github.com/coletiv/puppeteer-pdf/issues/13
cp -R /usr/local/lib/node_modules/puppeteer/.local-chromium/ /usr/local/lib/node_modules/puppeteer-pdf/node_modules/puppeteer/
# Dépendances implicites de chromium 
sudo apt install ca-certificates fonts-liberation libappindicator3-1 libasound2 libatk-bridge2.0-0 libatk1.0-0 libc6 libcairo2 libcups2 libdbus-1-3 libexpat1 libfontconfig1 libgbm1 libgcc1 libglib2.0-0 libgtk-3-0 libnspr4 libnss3 libpango-1.0-0 libpangocairo-1.0-0 libstdc++6 libx11-6 libx11-xcb1 libxcb1 libxcomposite1 libxcursor1 libxdamage1 libxext6 libxfixes3 libxi6 libxrandr2 libxrender1 libxss1 libxtst6 lsb-release wget xdg-utils
```

Ensuite, proxyfiez l'instance avec Nginx ou Apache.
En production, l'URL racine "/" renvoie simplement un 200 afin d'être utilisée avec un outil de monitoring type UptimeRobot.

