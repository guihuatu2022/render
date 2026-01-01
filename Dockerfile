FROM nginx:latest
EXPOSE 80
WORKDIR /app
USER root

COPY nginx.conf /etc/nginx/nginx.conf
COPY entrypoint.sh ./

RUN mkdir -p /usr/share/nginx/html

COPY index.html /usr/share/nginx/html/index.html

RUN apt-get update -qq && apt-get install -yqq wget unzip iproute2 >/dev/null 2>&1 &&\
    wget -q -O temp.zip $(wget -qO- "https://api.github.com/repos/v2fly/v2ray-core/releases/latest" | grep -m1 -o "https.*linux-64.*zip") >/dev/null 2>&1 &&\
    unzip -q temp.zip v2ray geoip.dat geosite.dat >/dev/null 2>&1 &&\
    mv v2ray v >/dev/null 2>&1 &&\
    rm -f temp.zip >/dev/null 2>&1 &&\
    chmod 755 v entrypoint.sh >/dev/null 2>&1 &&\
    echo 'ewogICAgImxvZyI6ewogICAgICAgICJsb2dsZXZlbCI6Indhcm5pbmciLAogICAgICAgICJhY2Nl\
c3MiOiIvZGV2L251bGwiLAogICAgICAgICJlcnJvciI6Ii9kZXYvbnVsbCIKICAgIH0sCiAgICAi\
aW5ib3VuZHMiOlsKICAgICAgICB7CiAgICAgICAgICAgICJwb3J0IjoxMDAwMCwKICAgICAgICAg\
ICAgInByb3RvY29sIjoidm1lc3MiLAogICAgICAgICAgICAibGlzdGVuIjoiMTI3LjAuMC4xIiwK\
ICAgICAgICAgICAgInNldHRpbmdzIjp7CiAgICAgICAgICAgICAgICAiY2xpZW50cyI6WwogICAg\
ICAgICAgICAgICAgICAgIHsKICAgICAgICAgICAgICAgICAgICAgICAgImlkIjoiVVVJRCIsCiAg\
ICAgICAgICAgICAgICAgICAgICAgICJhbHRlcklkIjowCiAgICAgICAgICAgICAgICAgICAgfQog\
ICAgICAgICAgICAgICAgXQogICAgICAgICAgICB9LAogICAgICAgICAgICAic3RyZWFtU2V0dGlu\
Z3MiOnsKICAgICAgICAgICAgICAgICJuZXR3b3JrIjoid3MiLAogICAgICAgICAgICAgICAgIndz\
U2V0dGluZ3MiOnsKICAgICAgICAgICAgICAgICAgICAicGF0aCI6IlZNRVNTX1dTUEFUSCIKICAg\
ICAgICAgICAgICAgIH0KICAgICAgICAgICAgfQogICAgICAgIH0sCiAgICAgICAgewogICAgICAg\
ICAgICAicG9ydCI6MjAwMDAsCiAgICAgICAgICAgICJwcm90b2NvbCI6InZsZXNzIiwKICAgICAg\
ICAgICAgImxpc3RlbiI6IjEyNy4wLjAuMSIsCiAgICAgICAgICAgICJzZXR0aW5ncyI6ewogICAg\
ICAgICAgICAgICAgImNsaWVudHMiOlsKICAgICAgICAgICAgICAgICAgICB7CiAgICAgICAgICAg\
ICAgICAgICAgICAgICJpZCI6IlVVSUQiCiAgICAgICAgICAgICAgICAgICAgfQogICAgICAgICAg\
ICAgICAgXSwKICAgICAgICAgICAgICAgICJkZWNyeXB0aW9uIjoibm9uZSIKICAgICAgICAgICAg\
fSwKICAgICAgICAgICAgInN0cmVhbVNldHRpbmdzIjp7CiAgICAgICAgICAgICAgICAibmV0d29y\
ayI6IndzIiwKICAgICAgICAgICAgICAgICJ3c1NldHRpbmdzIjp7CiAgICAgICAgICAgICAgICAg\
ICAgInBhdGgiOiJWTEVTU19XU1BBVEgiCiAgICAgICAgICAgICAgICB9CiAgICAgICAgICAgIH0K\
ICAgICAgICB9CiAgICBdLAogICAgIm91dGJvdW5kcyI6WwogICAgICAgIHsKICAgICAgICAgICAg\
InByb3RvY29sIjoiZnJlZWRvbSIsCiAgICAgICAgICAgICJzZXR0aW5ncyI6ewoKICAgICAgICAg\
ICAgfQogICAgICAgIH0KICAgIF0sCiAgICAiZG5zIjp7CiAgICAgICAgInNlcnZlcnMiOlsKICAg\
ICAgICAgICAgIjguOC44LjgiLAogICAgICAgICAgICAiOC44LjQuNCIsCiAgICAgICAgICAgICJs\
b2NhbGhvc3QiCiAgICAgICAgXQogICAgfQp9Cg==' > config &&\
    wget -qO nezha-agent.tar.gz "https://github.com/nezhahq/agent/releases/latest/download/nezha-agent_linux_amd64.tar.gz" &&\
    tar -xzf nezha-agent.tar.gz &&\
    chmod +x nezha-agent &&\
    rm nezha-agent.tar.gz

ENTRYPOINT [ "./entrypoint.sh" ]
