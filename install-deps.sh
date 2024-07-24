#!/bin/sh

curl https://dl.google.com/go/go1.20.linux-amd64.tar.gz -o go1.20.linux-amd64.tar.gz

sudo rm -rf /usr/local/go 
sudo tar -C /usr/local -xzf go1.20.linux-amd64.tar.gz

export PATH=$PATH:/usr/local/go/bin

echo PATH=$PATH:/usr/local/go/bin >> $HOME/.profile

rm go1.20.linux-amd64.tar.gz

go version


go install github.com/tomnomnom/assetfinder@latest

go install github.com/tomnomnom/gron@latest

go install github.com/tomnomnom/httprobe@latest

go install github.com/tomnomnom/waybackurls@latest

go install github.com/tomnomnom/meg@latest

go install github.com/tomnomnom/anew@latest

go install github.com/tomnomnom/fff@latest

go install github.com/projectdiscovery/nuclei/v2/cmd/nuclei@latest

go install github.com/OJ/gobuster/v3@latest

echo export PATH="$(go env GOPATH)/bin:$PATH" >>$HOME/.profile
