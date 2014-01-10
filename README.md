Lieu Idéal
==========

Lieu Idéal utilise le framework Symfony 2 (Symfony Standard Edition).

Ce document contient les informations nécessaires à l'installation de Lieu Idéal. Pour
des informations plus détailler sur la configuration ou le fonctionnement de 
l'application, une documentation est disponible.



Liste des dépendences
---------------------

- PHP  >5.3.8
- PostgreSQL >8.4 *(9.1 recommandé)*
- PostGIS  >1.5 *(2.0 recommandé)*
- Ruby >1.93p194
- RubyGems >1.8
- Git > 1.7
- Apache 2
- XVFB
- WKHTMLtoPDF 0.9.*


Déploiement de Lieu Idéal
--------------------------

Vous disposez de deux solutions pour installer Lieu Idéal, L'interface de déploiement (Cano)
ou en ligne de commande sur votre machine. Ces deux procédures sont décrites dans les instructions
 ci-dessous :


### Installation via Cano (IHM de déploiement)

Après avoir installer les éléments indiqués ci-dessus, allez sur l'IHM de déploiement.

L'installation requiert préalablement la préparation de la machine. La tâche ci-dessous vous
indique les éléments à installer :

    deploy:setup


Cependant, certaines tâches ne peuvent être réalisées par les scripts de déploiement. Les deux
tâches ci-dessous vous fournisse des informations à utiliser dans commandes suivantes :


Configurer PostgreSQL pour l'utilisateur et PostGIS :

  Sur l'environnement à configurer

    $ su postgres
    $ create -P {db_user}

  A la question `Shall the new role be a superuser ?`, répondre `n`
  A la question `Shall the new role be allowed to create databases ?`, répondre `y`
  A la question `Shall the new role be allowed to create more new roles ?`, répondre `y`

    $ createlang plpgsql {db_name}
    $ psql -f /usr/share/postgresql/{postgresql_version}/contrib/{postgis_version}/postgis.sql {db_name}
    $ psql -f /usr/share/postgresql/{postgresql_version}/contrib/{postgis_version}/spatial_ref_sys.sql {db_name}


Une fois cette opération effectué vous pouvez déploier la dernière version avec :

    deploy


### Installation depuis votre machine


Installer Ruby si nécessaire : 

    $ (sudo) apt-get install ruby

Installer les dépendences associé à Ruby (utilisé pour le déploiement)

    $ cd {app_folder} && (sudo) gem install bundle && bundle install

Lancer les scripts de déploiement : 

    $ cd {app_folder} && deploy:setup




Personnalisation de Lieu Idéal
------------------------------

### Installation de Composer et Symfony

Symfony utilise [Composer][2] pour gérer ces dépendences, ainsi pour initialiser un
nouveau projet, il vous suffit de commencer par installer Composer dans un nouveau
dossier comme suit:

    curl -s http://getcomposer.org/installer | php

Ensuite, initialisez un nouveau projet Symfony avec la commande suivante :

    php composer.phar create-project symfony/framework-standard-edition ./


### Installation du vendor Lieu Idéal

Dans le fichier `composer.json`, vous devez ajouter la ligne suivante dans `require` :

    "require": {
        ...
        "canaltp/lieuideal": "1.0.0",
    },

Puis après `require`, 

    "repositories": [
        {
            "type": "package",
            "package": {
                "name": "canaltp/lieuideal",
                "version": "1.0.0",
                "source": {
                    "url" : "http://hg.prod.canaltp.fr/lieuideal/core",
                    "type": "hg",
                    "reference": "1.0.0"
                },
                "autoload": {
                    "psr-0": { "CanalTP/LieuIdealCoreBundle": "lib/" }
                },
                "require": {
                    "php": ">=5.3.3",
                    "symfony/symfony": "2.1.0",
                    "symfony/event-dispatcher": "2.1.0",
                    "symfony/assetic-bundle": "2.1.0",
                    "symfony/swiftmailer-bundle": "2.1.0",
                    "symfony/monolog-bundle": "2.1.0",
                    "sensio/distribution-bundle": "2.1.*",
                    "sensio/framework-extra-bundle": "2.1.*",
                    "sensio/generator-bundle": "2.1.*",
                    "doctrine/orm": ">=2.2.3,<2.4-dev",
                    "doctrine/doctrine-bundle": "1.0.*",
                    "doctrine/doctrine-migrations-bundle": "dev-master",
                    "twig/extensions": "1.0.*",
                    "jms/security-extra-bundle": "1.2.*",
                    "jms/di-extra-bundle": "1.1.*",
                    "friendsofsymfony/jsrouting-bundle": "1.0.*",
                    "canaltp/wom": "1.0.0",
                }
            }
        }
    ]

Il ne reste plus qu'à installer les vendors : 

    php composer.phar install

### Générer un nouveau bundle pour personnaliser Lieu Idéal

Lieu Idéal utilise un thème par défaut; vous devez créer un nouveau bundle pour
personnaliser ses fonctionnalités. [Symfony propose un tutorial][16] pour cela.

Une fois votre nouveau bundle crée, vous devez étendre celui-ci en modifiant le
fichier {votre_bundle}Bundle.php qui se trouve à la racine de votre Bundle. Vous
devez ajouter une méthode `getParent` et retourner la chaîne `CanalTPLieuIdealCoreBundle`
Exemple :

    <?php
    namespace CanalTP\ProductBundle;
    use Symfony\Component\HttpKernel\Bundle\Bundle;

    class CanalTPLieuIdealProductBundle extends Bundle
    {
      public function getParent()
      {
        return 'CanalTPLieuIdealCoreBundle';
      }
    }

### Ajout et personnalisation des 'routes' de Lieu Idéal

Par défaut, Symfony utilise les annotations pour la configuration des routes, cependant il
est nécessaire d'utiliser la configuration avec les fichiers YAML pour étendre les 'routes'
de Lieu Idéal. Il faut par conséquent modifier votre fichier `app/config/routing.yml` pour
remplacer sur la ligne `type` de votre bundle la valeur `annotation` par `yaml` puis créer
le fichier suivant `{votre_bundle}/Resources/config/routing.yml` que vous utilisez sur la 
ligne `resource` de `app/config/routing.yml. Une fois cela fait, ajouter dans ce fichier
les lignes suivantes :

    canaltp_lieuidealcore_bestpoint:
      resource: @CanalTPLieuIdealCoreBundle/Resources/config/routing/bestpoint.yml
      prefix: /bestpoint

    canaltp_lieuidealcore_isochron:
      resource: @CanalTPLieuIdealCoreBundle/Resources/config/routing/isochron.yml
      prefix: /isochron

    canaltp_lieuidealcore_planjourney:
      resource: @CanalTPLieuIdealCoreBundle/Resources/config/routing/planjourney.yml
      prefix: /planjourney

    canaltp_lieuidealcore_autocompletion:
      resource: @CanalTPLieuIdealCoreBundle/Resources/config/routing/autocompletion.yml
      prefix: /autocompletion

Vous pouvez rapidement tester Lieu Idéal avec les URLs suivantes :

    /isochron
    /bestpoint

Chaque ligne `prefix` représente les valeurs par défaut, il suffit de remplacer ces valeurs pour
modifier les URLs.


### Autres modifications




NOTA BENE
---------

Once you're feeling good, you can move onto reading the official
[Symfony2 book][5].

A default bundle, `AcmeDemoBundle`, shows you Symfony2 in action. After
playing with it, you can remove it by following these steps:

  * delete the `src/Acme` directory;

  * remove the routing entries referencing AcmeBundle in
    `app/config/routing_dev.yml`;

  * remove the AcmeBundle from the registered bundles in `app/AppKernel.php`;

  * remove the `web/bundles/acmedemo` directory;

  * remove the `security.providers`, `security.firewalls.login` and
    `security.firewalls.secured_area` entries in the `security.yml` file or
    tweak the security configuration to fit your needs.


Enjoy!

[1]:  http://symfony.com/doc/2.1/book/installation.html
[2]:  http://getcomposer.org/
[3]:  http://symfony.com/download
[4]:  http://symfony.com/doc/2.1/quick_tour/the_big_picture.html
[5]:  http://symfony.com/doc/2.1/index.html
[6]:  http://symfony.com/doc/2.1/bundles/SensioFrameworkExtraBundle/index.html
[7]:  http://symfony.com/doc/2.1/book/doctrine.html
[8]:  http://symfony.com/doc/2.1/book/templating.html
[9]:  http://symfony.com/doc/2.1/book/security.html
[10]: http://symfony.com/doc/2.1/cookbook/email.html
[11]: http://symfony.com/doc/2.1/cookbook/logging/monolog.html
[12]: http://symfony.com/doc/2.1/cookbook/assetic/asset_management.html
[13]: http://jmsyst.com/bundles/JMSSecurityExtraBundle/master
[14]: http://jmsyst.com/bundles/JMSDiExtraBundle/master
[15]: http://symfony.com/doc/2.1/bundles/SensioGeneratorBundle/index.html
[16]: http://symfony.com/doc/current/bundles/SensioGeneratorBundle/commands/generate_bundle.html
