#!/usr/bin/env bash

pluginName="$(echo $1 | tr A-Z a-z)"
pluginVersion="$(echo $pluginName | tr a-z A-Z)_VERSION"

echo "Creation of the plugin's structure named : $pluginName"

mkdir $1 && cd $1
mkdir front inc locale tools tests

# Minimal setup.php
cat <<EOT > setup.php
<?php

define('${pluginVersion}', '1.0.0');

/**
 * Init the hooks of the plugins - Needed
 *
 * @return void
 */
function plugin_init_${pluginName}() {
   global \$PLUGIN_HOOKS;

   //required!
   \$PLUGIN_HOOKS['csrf_compliant']['${pluginName}'] = true;

   //some code here, like call to Plugin::registerClass(), populating PLUGIN_HOOKS, ...
}

/**
 * Get the name and the version of the plugin - Needed
 *
 * @return array
 */
function plugin_version_${pluginName}() {
   return [
      'name'           => 'SII/${pluginName}',
      'version'        => ${pluginVersion},
      'author'         => 'Guillaume Cassou',
      'license'        => 'proprietary',
      'requirements'   => [
         'glpi'   => [
            'min' => '9.3.1'
         ],
         'php'    => [
            'min' => '7.0' 
         ]
      ]
   ];
}

/**
 * Optional : check prerequisites before install : may print errors or add to message after redirect
 *
 * @return boolean
 */
function plugin_${pluginName}_check_prerequisites() {
   //do what the checks you want
   return true;
}

/**
 * Check configuration process for plugin : need to return true if succeeded
 * Can display a message only if failure and $verbose is true
 *
 * @param boolean $verbose Enable verbosity. Default to false
 *
 * @return boolean
 */
function plugin_${pluginName}_check_config($verbose = false) {
   if (true) { // Your configuration check
      return true;
   }

   if ($verbose) {
      echo "Installed, but not configured";
   }
   return false;
}
EOT

# Minimal hook.php
cat <<EOT > hook.php
<?php

/**
 * Install hook
 *
 * @return boolean
 */
function plugin_${pluginName}_install() {
   //do some stuff like instanciating databases, default values, ...
   return true;
}

/**
 * Uninstall hook
 *
 * @return boolean
 */
function plugin_${pluginName}_uninstall() {
   //to some stuff, like removing tables, generated files, ...
   return true;
}
EOT

# Minimal composer.json
cat <<EOT > composer.json
{
    "name": "SII/${pluginName}",
    "license": "proprietary",
    "type": "project",
    "description": "A Glpi plugin - ${pluginName}",
    "scripts":{
        "test":[
            "@verify",
            "phpunit"
        ],
        "verify": "vendor/bin/phpcs -p --ignore=vendor --standard=vendor/glpi-project/coding-standard/GlpiStandard/ ."
    }
}
EOT

# Minimal .gitignore
cat <<EOT > .gitignore
vendor/
node_modules/
EOT

cat <<EOT > README.md
# Aide developpement d'un plugin GLPI

Ce plugin devra être installé dans le dossier plugins/ de GLPI

### Structure du plugin : ###
- front : Tous les fichiers PHP directement utilisés pour afficher quelque chose à l'utilisateur
- inc : Contiendra toutes les classes
- locale : Si le plugin dispose d'une internationalisation, les fichiers nécéssaires devront se trouver ici.
- tools : Tous les fichiers de scripting
- test : Tous les tests unitaires
- setup.php : Sera automatiquement chargé à partir du noyau de GLPI afin d’obtenir sa version, de vérifier les prérequis, etc.
- hook.php : Contient tous les hooks qui peuvent être appelés dans le plugin (modification de base de données par exemple).


### Setup.php : ### https://glpi-developer-documentation.readthedocs.io/en/master/plugins/requirements.html#setup-php
- Chargé automatiquement par le GLPI pour faire des vérifications/charger des constantes
- Bonne pratique de faire define('MYEXAMPLE_VERSION', '1.2.10');
- Formalisme des fonctions à respecter
- Référencement des hooks


### Hook.php : ### https://glpi-developer-documentation.readthedocs.io/en/master/plugins/requirements.html#hook-php
- Contient plusieurs hooks nécessaires dont au moins un pour l’installation et un pour la suppression du plugin


### Standards de code : ### https://glpi-developer-documentation.readthedocs.io/en/master/codingstandards.html
- On peut automatiser la vérification de standards
- composer require --dev glpi-project/coding-standard
- Dans un .travis.yml par exemple :
    script:
        - vendor/bin/phpcs -p --ignore=vendor --standard=vendor/glpi-project/coding-standard/GlpiStandard/ . 


### Base de données : ### https://glpi-developer-documentation.readthedocs.io/en/master/plugins/database.html
- Ne jamais changer le comportement interne de la base, seulement ajouter/supprimer ses propres tables.
- Devra respecter ceci https://glpi-developer-documentation.readthedocs.io/en/master/devapi/database/dbmodel.html#dbmodel
- Les modifications de tables sont effectuées dans le fichier hook.php en utilisant la classe Migration https://forge.glpi-project.org/apidoc/class-Migration.html
- Peux être managée au travers de la classe CommonDBTM et ses descendants


### Classes : ### https://glpi-developer-documentation.readthedocs.io/en/master/plugins/objects.html
- Il y a déjà de nombreuses classes disponibles pour faciliter le travail : https://glpi-developer-documentation.readthedocs.io/en/master/devapi/mainobjects.html
- Toutes les classes disponibles au sein de GLPI : https://forge.glpi-project.org/apidoc/index.html


### Taches automatiques : ### https://glpi-developer-documentation.readthedocs.io/en/master/devapi/crontasks.html
- Glpi fourni une classe CronTask pour effectuer des taches automatiquement : https://forge.glpi-project.org/apidoc/class-CronTask.html


### Tools : ### https://glpi-developer-documentation.readthedocs.io/en/master/devapi/tools.html


### Massive Actions : ### https://glpi-developer-documentation.readthedocs.io/en/master/plugins/massiveactions.html


### Tips and tricks : ### https://glpi-developer-documentation.readthedocs.io/en/master/plugins/tips.html


### Notifications : ### https://glpi-developer-documentation.readthedocs.io/en/master/plugins/notifications.html
EOT

# Dev dependencies required for development
sudo composer require --dev glpi-project/coding-standard
sudo composer require --dev phpunit/phpunit:6

# Init a git repo
git init
git add .
git commit -m 'Initial commit'

# if [ -n "$2" ]; then
#     git push --set-upstream "https://name/$2" master
# fi

echo "Done"
