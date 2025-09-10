# Dockerfile per Flutter Web
FROM nginx:alpine

# Rimuovi la configurazione default di nginx
RUN rm /etc/nginx/conf.d/default.conf

# Copia la configurazione nginx personalizzata
COPY nginx.conf /etc/nginx/conf.d/

# Copia i file build di Flutter nella directory di nginx
COPY build/web/ /usr/share/nginx/html/

# Esponi la porta 80
EXPOSE 80

# Nginx si avvia automaticamente