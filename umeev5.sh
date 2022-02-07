#!/bin/bash


read -p "Enter node name: " UMEE_NODENAME
echo 'export UMEE_NODENAME='\"${UMEE_NODENAME}\" >> $HOME/.bash_profile

sudo apt update
sudo apt upgrade -y
sudo apt install make clang pkg-config libssl-dev build-essential git jq ncdu -y

wget -O go1.17.2.linux-amd64.tar.gz https://golang.org/dl/go1.17.2.linux-amd64.tar.gz

rm -rf /usr/local/go && tar -C /usr/local -xzf go1.17.2.linux-amd64.tar.gz && rm go1.17.2.linux-amd64.tar.gz

echo 'export GOROOT=/usr/local/go' >> $HOME/.bash_profile
echo 'export GOPATH=$HOME/go' >> $HOME/.bash_profile
echo 'export GO111MODULE=on' >> $HOME/.bash_profile
echo 'export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin' >> $HOME/.bash_profile
echo 'export UMEE_CHAIN=umee-betanet-v5' >> $HOME/.bash_profile

source $HOME/.bash_profile

go version

cd $HOME
rm -r $HOME/umee
git clone --depth 1 --branch v0.7.4 https://github.com/umee-network/umee.git
cd umee && make install
umeed version
umeed init ${UMEE_NODENAME} --chain-id $UMEE_CHAIN
wget -O $HOME/.umee/config/genesis.json "https://raw.githubusercontent.com/umee-network/testnets/main/networks/umee-betanet-v5/genesis.json"
sha256sum $HOME/.umee/config/genesis.json
umeed unsafe-reset-all
sed -i.bak -e "s/^minimum-gas-prices = \"\"/minimum-gas-prices = \"0.001uumee\"/" $HOME/.umee/config/app.toml
sed -i '/\[grpc\]/{:a;n;/enabled/s/false/true/;Ta};/\[api\]/{:a;n;/enable/s/false/true/;Ta;}' $HOME/.umee/config/app.toml
external_address=`curl ifconfig.me`
peers="8ca2c44d5ed4716f99c15e61099c6b085cd8b266@45.76.91.152:26656,1b18e2e71df92fb42272ceb52e6b4c85b3a25ada@185.92.222.137:26656"
sed -i.bak -e "s/^external_address = \"\"/external_address = \"$external_address:26656\"/; s/^persistent_peers *=.*/persistent_peers = \"$peers\"/" $HOME/.umee/config/config.toml


cd $HOME

echo "[Unit]
Description=Umee
After=network.target

[Service]
User=$USER
Type=simple
ExecStart=$(which umeed) start
Restart=on-failure
LimitNOFILE=65535

[Install]
WantedBy=multi-user.target" > $HOME/umeed.service

mv umeed.service /etc/systemd/system

systemctl daemon-reload
systemctl enable umeed
systemctl restart umeed

echo 'run for monitor'
echo 'journalctl -u umeed -f'
