# Installation de Ceph avec LTTng activé sur Debian

Ce guide décrit les étapes pour construire et installer Ceph à partir de la source debian avec le support de LTTng activé.

### Installation des dépendances

```bash
sudo apt update
sudo apt install dpkg-dev devscripts -y
sudo apt install lttng-tools lttng-modules-dkms liblttng-ust-dev libbabeltrace-dev
```

## Étapes d'installation

1. **Récupérer le code source de Ceph**  
   ```bash
   apt source ceph
   ```

2. **Installer les dépendances de construction**  
   
   ```bash
   sudo apt build-dep ceph
   ```

3. **Modifier les règles de construction pour activer LTTng**  
   Accédez au répertoire contenant les fichiers sources :  

   ```bash
   cd ceph-<version>
   ```

   Ouvrez le fichier `debian/rules` pour modification :  

   ```bash
   nano debian/rules
   ```

   Modifiez les paramètres pour activer LTTng. Assurez-vous que la ligne suivante est présente :  

   ```
   extraopts += -DWITH_LTTNG=ON
   ```

4. **Construire les paquets Ceph**  
   Construisez les paquets Ceph avec les options nécessaires :  

   ```bash
   DEB_BUILD_OPTIONS=nocheck DEB_CMAKE_EXTRA_ARGS="-DWITH_LTTNG=ON" dpkg-buildpackage -uc -us
   ```

5. **Installer les paquets construits**  
   Une fois la construction terminée, installez les paquets :  

   ```bash
   sudo dpkg -i ../ceph*.deb
   ```

## Notes supplémentaires

- Si vous rencontrez des problèmes de dépendances, utilisez la commande suivante pour résoudre les conflits :  
  ```bash
  sudo apt install -f
  ```


