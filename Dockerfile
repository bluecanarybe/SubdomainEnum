FROM python:3-alpine

RUN apk add --update-cache \
    git wget curl nano unzip go

RUN export CGO_ENABLED=0

RUN go get -v github.com/OWASP/Amass/v3/...

RUN go get -u github.com/tomnomnom/assetfinder

RUN cd /var/tmp/ && git clone https://github.com/fleetcaptain/Turbolist3r.git; \
    cd /var/tmp/Turbolist3r && pip install -r requirements.txt

RUN cd /var/tmp/ && git clone https://github.com/shmilylty/OneForAll.git; \
    cd /var/tmp/OneForAll && python3 -m pip install -U pip setuptools wheel && pip3 install -r requirements.txt

RUN go env GO111MODULE=on && go get github.com/projectdiscovery/chaos-client/cmd/chaos

RUN go get -u github.com/tomnomnom/httprobe

RUN go get -u github.com/bluecanarybe/ResponseChecker

RUN GO111MODULE=on go get -v github.com/projectdiscovery/httpx/cmd/httpx

ADD subdomains.sh subdomains.sh
RUN chmod +x subdomains.sh

CMD echo "Please specify your target in the Docker run command"
