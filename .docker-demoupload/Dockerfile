from alpine:latest

RUN apk add --update --no-cache wget sftp 

# create the group and user
RUN addgroup -g 1000 q3user \
    && adduser -u 1000 -G q3user -D /server

# Now work on the folder...
USER q3user
WORKDIR /server

ENV DEMO_SFTP_ENABLED=0
ENV DEMO_SFTP_HOST="127.0.0.1"
ENV DEMO_SFTP_PORT=22
ENV DEMO_SFTP_USER=""
ENV DEMO_SFTP_PASS=""
ENV DEMO_SFTP_LOCAL_DIRECTORY=/server/defrag
ENV DEMO_SFTP_REMOTEDIR=/
ENV DEMO_FTPS_CRONTAB="*/30 * * * *"

COPY ./upload_demos.sh /bin/backup
COPY ./entry.sh /entry.sh

ENTRYPOINT ["./entry.sh"]