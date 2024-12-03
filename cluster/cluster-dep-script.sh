#!/bin/bash

# Variables
INTERFACE="ens34"
HOSTNAME=$(hostname)
MON_IP="192.168.1.10"
MON_IP_MASK="255.255.255.0"
PUBLIC_NETWORK="192.168.1.0/24"
FSID=$(uuidgen)
MANAGER_NAME="mgr1"
DISK1="sda"
DISK2="sdb"

# Configurer l'adresse IP
sudo bash -c "cat >> /etc/network/interfaces" <<EOF
auto ${INTERFACE}
iface ${INTERFACE} inet static
    address ${MON_IP}
    netmask ${MON_IP_MASK}
EOF

sudo systemctl restart networking


#---------------------------------------------------------------------------------------------------

# Créer le fichier de configuration
sudo bash -c "cat > /etc/ceph/ceph.conf" <<EOF
[global]
fsid = ${FSID}
mon_initial_members = ${HOSTNAME}
mon_host = ${MON_IP}
public_network = ${PUBLIC_NETWORK}
auth_cluster_required = cephx
auth_service_required = cephx
auth_client_required = cephx
osd_pool_default_size = 2
osd_pool_default_min_size = 2
osd_pool_default_pg_num = 333
osd_crush_chooseleaf_type = 1
EOF

# Générer les keyrings
sudo ceph-authtool --create-keyring /tmp/ceph.mon.keyring --gen-key -n mon. --cap mon 'allow *'
sudo ceph-authtool --create-keyring /etc/ceph/ceph.client.admin.keyring --gen-key -n client.admin --cap mon 'allow *' --cap osd 'allow *' --cap mds 'allow *' --cap mgr 'allow *'
sudo ceph-authtool --create-keyring /var/lib/ceph/bootstrap-osd/ceph.keyring --gen-key -n client.bootstrap-osd --cap mon 'profile bootstrap-osd' --cap mgr 'allow r'

# Importer les clés dans ceph.mon.keyring
sudo ceph-authtool /tmp/ceph.mon.keyring --import-keyring /etc/ceph/ceph.client.admin.keyring
sudo ceph-authtool /tmp/ceph.mon.keyring --import-keyring /var/lib/ceph/bootstrap-osd/ceph.keyring
sudo chown ceph:ceph /tmp/ceph.mon.keyring

# Générer le monmap
sudo monmaptool --create --add ${HOSTNAME} ${MON_IP} --fsid ${FSID} /tmp/monmap

# Créer le répertoire de données pour le moniteur
sudo mkdir -p /var/lib/ceph/mon/ceph-${HOSTNAME}
sudo chown -R ceph:ceph /var/lib/ceph/mon/ceph-${HOSTNAME}

# Initialiser le moniteur
sudo -u ceph ceph-mon --mkfs -i ${HOSTNAME} --monmap /tmp/monmap --keyring /tmp/ceph.mon.keyring

# Attendre avant de démarrer le moniteur
sleep 4

# Démarrer le moniteur
sudo systemctl start ceph-mon@${HOSTNAME}


#---------------------------------------------------------------------------------------------------

# Déployer un manager
echo "Déploiement du manager : ${MANAGER_NAME}"

# 1. Créer une clé d'authentification pour le manager
sudo ceph auth get-or-create mgr.${MANAGER_NAME} mon 'allow profile mgr' osd 'allow *' mds 'allow *'

# 2. Créer le répertoire de données pour le manager
sudo mkdir -p /var/lib/ceph/mgr/ceph-${MANAGER_NAME}

# 3. Enregistrer la keyring dans le répertoire
sudo bash -c "ceph auth get mgr.${MANAGER_NAME} > /var/lib/ceph/mgr/ceph-${MANAGER_NAME}/keyring"

# 4. Définir les permissions correctes
sudo chown -R ceph:ceph /var/lib/ceph/mgr/ceph-${MANAGER_NAME}

# 5. Démarrer le daemon du manager
sudo -u ceph ceph-mgr -i ${MANAGER_NAME}


#---------------------------------------------------------------------------------------------------

# Ajouter deux OSDs
echo "Création des OSDs sur /dev/sda et /dev/sdb"

# Préparer et activer les OSDs
sudo ceph-volume lvm create --data /dev/${DISK1}
sudo ceph-volume lvm create --data /dev/${DISK2}






