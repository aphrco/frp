#!/bin/bash

read -p "Enter the number of Iran servers: " iran_server_count
for ((i = 1; i <= $iran_server_count; i++)); do
    read -p "Enter the IP address of Iran server $i: " iran_server_ip
    read -p "Enter the name of Iran server $i: " iran_server_name

    frpc_config_file="/root/frp/frpc_$iran_server_name.toml"
    echo "[common]" > "$frpc_config_file"
    echo "server_addr = \"$iran_server_ip\"" >> "$frpc_config_file"
    echo "server_port = \"4433\"" >> "$frpc_config_file"
    echo "vhost_https_port = \"8443\"" >> "$frpc_config_file"
    echo "transport.tls.disableCustomTLSFirstByte = false" >> "$frpc_config_file"
    echo "token = \"azumi\"" >> "$frpc_config_file"
    echo "includes = \"/root/frp/conf/*.toml\"" >> "$frpc_config_file"

    frpc_service_file="/etc/systemd/system/azumifrpc_$iran_server_name.service"
    echo "[Unit]" > "$frpc_service_file"
    echo "Description=frpc service" >> "$frpc_service_file"
    echo "After=network.target" >> "$frpc_service_file"
    echo "" >> "$frpc_service_file"
    echo "[Service]" >> "$frpc_service_file"
    echo "ExecStart=/root/frp/./frpc -c /root/frp/frpc_$iran_server_name.toml" >> "$frpc_service_file"
    echo "Restart=always" >> "$frpc_service_file"
    echo "RestartSec=5" >> "$frpc_service_file"
    echo "LimitNOFILE=1048576" >> "$frpc_service_file"
    echo "User=root" >> "$frpc_service_file"
    echo "" >> "$frpc_service_file"
    echo "[Install]" >> "$frpc_service_file"
    echo "WantedBy=multi-user.target" >> "$frpc_service_file"

    systemctl daemon-reload
    systemctl enable "azumifrpc_$iran_server_name.service"
    systemctl start "azumifrpc_$iran_server_name.service"
    systemctl status "azumifrpc_$iran_server_name.service"
done
