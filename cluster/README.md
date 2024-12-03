# Déploiement d'un Cluster Ceph Minimal sur Debian

Ce dossier contient un script pour déployer manuellement un cluster Ceph minimal sur la même machine sous Debian. 

## Prérequis

- Système Debian avec 3 disques disponibles (1 pour le système et 2 pour les OSDs).

## Fonctionnement du Script

Le script configure et déploie les composants suivants dans l'ordre :

1. **Configuration de l'adresse IP :**
   - Le script configure l'adresse IP d'une interface réseau. Vous pouvez modifier l'adresse IP et le nom de l'interface dans la section des variables en haut du script.

2. **Déploiement d'un Moniteur (MON) :**
   - Le script crée et initialise un moniteur Ceph sur la machine.

3. **Déploiement d'un Manager (MGR) :**
   - Le script crée un manager Ceph avec un nom spécifié (par défaut `mgr1`).

4. **Création de 2 OSDs :**
   - Le script crée deux OSDs en utilisant les disques `/dev/sda` et `/dev/sdb`.

## Variables à Modifier

Avant de lancer le script, vous pouvez ajuster les paramètres suivants dans la section des variables en haut du script :

- `INTERFACE`: Le nom de l'interface réseau (par défaut `ens34`).
- `MON_IP`: L'adresse IP du moniteur (par défaut `192.168.1.10`).
- `MON_IP_MASK`: Le masque de sous-réseau (par défaut `255.255.255.0`).
- `PUBLIC_NETWORK`: Le réseau public (par défaut `192.168.1.0/24`).
- `MANAGER_NAME`: Le nom du manager Ceph (par défaut `mgr1`).
- `DISK1` et `DISK2`: Le nom des des disques pour les OSDs (par défaut `sda` et `sdb`)


## Vérification de l'État du Cluster

Une fois le script exécuté, vous pouvez vérifier l'état du cluster avec la commande suivante :

```bash
ceph -s
```