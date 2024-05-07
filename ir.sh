#!/bin/bash

apt install python3 -y && \
apt install wget -y && \
apt install python3-pip -y && \
pip install colorama && \
pip install netifaces && \
apt install curl -y

python3 <(curl -Ls https://raw.githubusercontent.com/Azumi67/FRP_Reverse_Loadbalance/main/loadbalance.py --ipv4) <<EOF
2
EOF

read -p "Enter the number of external tunnel:(tedad server ha , port ha) " server_count

sed -i '/./d' ./frp/frps.toml

for ((i = 1; i <= $server_count; i++)); do
    read -p "Enter the name of Tunnel  $i: " server_name

    read -p "Enter the local port range for T7unnel $i (e.g., 10001-10009 | 2022-2024): " local_port_range
    echo "$(cat <<EOF
[common]
bind_port = 4433
vhost_https_port = 8443
transport.tls.disable_custom_tls_first_byte = false
token = azumi

[$server_name]
type = tcp
local_port = $local_port_range
remote_port = $local_port_range
use_encryption = true
use_compression = true
EOF
)" >> "./frp/frps.toml"
done

echo "frps.toml file has been updated successfully."

cat <<EOF > /etc/systemd/system/azumifrps4.service
[Unit]
Description=frps service
After=network.target

[Service]
ExecStart=/root/frp/./frps -c /root/frp/frps.toml
Restart=always
RestartSec=5
LimitNOFILE=1048576
User=root

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable azumifrps4.service
systemctl start azumifrps4.service
systemctl status azumifrps4.service
echo "Sucsses Tunnel Connect" 