ARG BASE_IMAGE
FROM ${BASE_IMAGE}

# ENV variables
ENV DEBIAN_FRONTEND=noninteractive
ENV TZ="UTC"
ENV CUPSADMIN=admin
ENV CUPSPASSWORD=password

LABEL org.opencontainers.image.source="https://github.com/alvadorn/cups-docker"
LABEL org.opencontainers.image.description="CUPS Printer Server"
LABEL org.opencontainers.image.author="Igor Sant'Ana <contato {at} igorsantana {dot} com>"
LABEL org.opencontainers.image.url="https://github.com/alvadorn/cups-docker/blob/main/README.md"
LABEL org.opencontainers.image.licenses=MIT

# Install dependencies
RUN apt update -qq && \ 
apt install -qqy \ 
apt-utils \ 
usbutils \ 
cups \ 
cups-filters \ 
printer-driver-all \ 
printer-driver-cups-pdf \ 
printer-driver-foo2zjs \ 
foomatic-db-compressed-ppds \ 
openprinting-ppds \ 
hpijs-ppds \ 
hp-ppd \ 
hplip \ 
avahi-daemon && \ 
apt clean && \ 
rm -rf /var/lib/apt/lists/*

EXPOSE 631
EXPOSE 5353/udp

# Baked-in config file changes
RUN sed -i 's/Listen localhost:631/Listen 0.0.0.0:631/' /etc/cups/cupsd.conf && \ 
sed -i 's/Browsing Off/Browsing On/' /etc/cups/cupsd.conf && \ 
sed -i 's/<Location \/>/<Location \/>\n  Allow All/' /etc/cups/cupsd.conf && \ 
sed -i 's/<Location \/admin>/<Location \/admin>\n  Allow All\n  Require user @SYSTEM/' /etc/cups/cupsd.conf && \ 
sed -i 's/<Location \/admin\/conf>/<Location \/admin\/conf>\n  Allow All/' /etc/cups/cupsd.conf && \ 
echo "ServerAlias *" >>/etc/cups/cupsd.conf && \ 
echo "DefaultEncryption Never" >>/etc/cups/cupsd.conf

# back up cups configs in case used does not add their own
RUN cp -rp /etc/cups /etc/cups-bak
VOLUME [ "/etc/cups" ]

COPY entrypoint.sh /
RUN chmod +x /entrypoint.sh

CMD ["/entrypoint.sh"]
