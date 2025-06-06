#!/bin/sh

if ! command -v go &> /dev/null
then
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
            curl https://dl.google.com/go/go1.20.linux-amd64.tar.gz -o go-install.tar.gz
    elif [[ "$OSTYPE" == "darwin"* ]]; then
            curl https://go.dev/dl/go1.22.4.darwin-amd64.tar.gz -o go-install.tar.gz
    fi

    sudo rm -rf /usr/local/go 
    sudo tar -C /usr/local -xzf go-install.tar.gz

    export PATH=$PATH:/usr/local/go/bin

    echo PATH=$PATH:/usr/local/go/bin >> $HOME/.profile

    source $HOME/.profile

    rm go-install.tar.gz
fi


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

go install github.com/ffuf/ffuf/v2@latest

echo export PATH="$(go env GOPATH)/bin:$PATH" >>$HOME/.profile

source $HOME/.profile


# install dirsearch

echo "install dirsearch" 
echo "https://www.geeksforgeeks.org/dirsearch-go-implementation-of-dirsearch/"

echo "install SecLists"
echo "https://github.com/danielmiessler/SecLists"

