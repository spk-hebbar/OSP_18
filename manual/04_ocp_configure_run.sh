#!/bin/bash

set -xe

sudo ip link add link eno2 name eno2.1501 type vlan id 1501
sudo ip link set eno2.1501 up

sudo chmod -R 777 /home/stack/dev-scripts

make -C $HOME/src/dev-scripts requirements configure

#If you get an error related to SSH public key, copy them manually to the required file

#If you get an error like a network already exists, then we need to delete the default network.
#if [ $? -ne 0 ]; then
#	make -C $HOME/dev-scripts/ clean
#	sudo virsh net-destroy default && sudo virsh net-undefine default
#	make -C $HOME/dev-scripts requirements configure
#fi
#


# Define the IP and subnet information for each network
declare -A NETWORK_CONFIG
NETWORK_CONFIG=(
    ["osp_trunk_ip"]="192.168.122.1"
    ["osp_trunk_netmask"]="24"
    ["osp_external_ip"]="192.168.10.1"
    ["osp_external_netmask"]="24"
)

# Predefined network interfaces
export OSP_TRUNK_IF="enp196s0f1np1"  # osp_trunk
export OSP_EXTERNAL_IF="eno2.1501"    # osp_external

# Function to create a basic bridge configuration
create_bridge_config() {
    local network_name=$1
    local network_ip=$2
    local network_netmask=$3
    local network_if=$4

    sudo tee -a /etc/NetworkManager/system-connections/${network_name}.nmconnection <<EOF
[connection]
id=${network_name}
type=bridge
interface-name=${network_name}
[bridge]
stp=false
EOF

    # Handle IPv4/IPv6 configuration
    if [ "$(ipversion $network_ip)" == "6" ]; then
        sudo tee -a /etc/NetworkManager/system-connections/${network_name}.nmconnection <<EOF
[ipv4]
method=disabled
[ipv6]
addr-gen-mode=eui64
address1=${network_ip}/64
method=manual
EOF
    else
        sudo tee -a /etc/NetworkManager/system-connections/${network_name}.nmconnection <<EOF
[ipv4]
address1=${network_ip}/${network_netmask}
method=manual
[ipv6]
addr-gen-mode=eui64
method=disabled
EOF
    fi
    sudo chmod 600 /etc/NetworkManager/system-connections/${network_name}.nmconnection
    sudo nmcli con load /etc/NetworkManager/system-connections/${network_name}.nmconnection
    sudo nmcli con up ${network_name}

    # Configure the network interface
    sudo tee -a /etc/NetworkManager/system-connections/${network_if}.nmconnection <<EOF
[connection]
id=${network_if}
type=ethernet
interface-name=${network_if}
master=${network_name}
slave-type=bridge
EOF
}

# Function to apply VLAN trunk mode for osp_trunk
configure_vlan_trunk() {
    local network_if=$1
    sudo tee -a /etc/NetworkManager/system-connections/${network_if}.nmconnection <<EOF
[bridge]
vlan-filtering=true
[vlan]
trunk=true
trunk-tags=1502-1505
EOF
}

# Check and create osp_trunk connection if it doesn't exist
if ! nmcli connection show "osp_trunk" > /dev/null 2>&1; then
    sudo nmcli connection add type bridge con-name "osp_trunk" dev "$OSP_TRUNK_IF" \
        ip4 "${NETWORK_CONFIG[osp_trunk_ip]}/${NETWORK_CONFIG[osp_trunk_netmask]}" \
        ipv4.method manual
    echo "osp_trunk connection created."
else
    echo "osp_trunk connection already exists."
fi

# Check and create osp_external connection if it doesn't exist
if ! nmcli connection show "osp_external" > /dev/null 2>&1; then
    sudo nmcli connection add type vlan con-name "osp_external" dev "$OSP_EXTERNAL_IF" \
        ip4 "${NETWORK_CONFIG[osp_external_ip]}/${NETWORK_CONFIG[osp_external_netmask]}" \
        ipv4.method manual parent "$OSP_TRUNK_IF" vlan.id 1501
    echo "osp_external connection created."
else
    echo "osp_external connection already exists."
fi

# Loop through each network name in EXTRA_NETWORK_NAMES
for NETWORK_NAME in $EXTRA_NETWORK_NAMES; do
    NETWORK_IP="${NETWORK_CONFIG[${NETWORK_NAME}_ip]}"
    NETWORK_NETMASK="${NETWORK_CONFIG[${NETWORK_NAME}_netmask]}"

    # Use predefined interfaces
    if [ "$NETWORK_NAME" == "osp_trunk" ]; then
        NETWORK_IF="$OSP_TRUNK_IF"
    elif [ "$NETWORK_NAME" == "osp_external" ]; then
        NETWORK_IF="$OSP_EXTERNAL_IF"
    fi

    if [ ! -e /etc/NetworkManager/system-connections/${NETWORK_NAME}.nmconnection ]; then
        # Create basic bridge config
        create_bridge_config "$NETWORK_NAME" "$NETWORK_IP" "$NETWORK_NETMASK" "$NETWORK_IF"
    fi

    # Apply VLAN trunk mode for osp_trunk
    if [ "$NETWORK_NAME" == "osp_trunk" ]; then
        configure_vlan_trunk "$NETWORK_IF"
    fi

    sudo nmcli con load /etc/NetworkManager/system-connections/${NETWORK_IF}.nmconnection
    sudo nmcli con up ${NETWORK_IF}
done

set +x  # Disable debugging output
echo "Script completed."

make -C $HOME/src/dev-scripts/ build_installer ironic install_config ocp_run bell
