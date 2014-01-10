<?php

namespace CanalTP\ProductBundle\DependencyInjection;

use Symfony\Component\DependencyInjection\ContainerBuilder;
use Symfony\Component\DependencyInjection\Reference;
use Symfony\Component\Config\FileLocator;
use Symfony\Component\HttpKernel\DependencyInjection\Extension;
use Symfony\Component\DependencyInjection\Loader;
use Symfony\Component\Yaml\Yaml;
use  CanalTP\ProductBundle\DependencyInjection\Configuration as ProductConfiguration;
use CanalTP\ProductBundle\CanalTPProductBundle;

/**
 * This is the class that loads and manages your bundle configuration
 *
 * To learn more see {@link http://symfony.com/doc/current/cookbook/bundles/extension.html}
 */
class CanalTPProductExtension extends Extension {

    private $client = NULL;

    /**
     * {@inheritDoc}
     */
    public function load(array $configs, ContainerBuilder $container) {

        $this->client = CanalTPProductBundle::findClient($container);

        $sResourceUrl = '@CanalTPLieuIdealCoreBundle/Resources/config/routing.yml';
        $sLocalResourceUrl = NULL;

        if (($this->client) && ($this->client != 'Default')) {
            $this->addCustomConfiguration($container);
            $sLocalResourceUrl = '%kernel.customer_root_dir%/Resources/config/routing.yml';
        }


        $container
                ->register('lieu.routing.loader', 'CanalTP\ProductBundle\Routing\RoutingLoaderAdapter')
                ->addArgument($sResourceUrl)
                ->addArgument($sLocalResourceUrl)
                ->addArgument(new Reference('file_locator'))
                ->addTag('routing.loader');

        // Chargement configuration propre à transilien
        $configuration = new Configuration();
        $config = $this->processConfiguration($configuration, $configs);

        $loader = new Loader\YamlFileLoader($container, new FileLocator(__DIR__.'/../Resources/config'));
        $loader->load('services.yml');

//        foreach ($config['email'] as $key => $value) {
//            if(strpos($value, 'ENV::') !== false) {
//                $config['email'][$key] = getenv(substr($value, 5));
//            }
//        }
//
//        $container->setParameter('transilien.email',    $config['email']);
    }

    /**
     *  Ajoute les configurations, catalogues, views, assets du client
     */
    private function addCustomConfiguration(ContainerBuilder $container) {

        // Récupération des paramètres de configuration du coeur de lieu idéal
//        $sCoreClientConfig = __DIR__ . '/../../../../custom/' . $this->client . '/Resources/config/lieuideal.yml';
//        if (is_file($sCoreClientConfig)) {
//            $aCoreClientConfig = Yaml::parse($sCoreClientConfig);
//            $aCoreConfigs = array($aCoreClientConfig);
//            $oCoreConfiguration = new ProductConfiguration();
//            $oCoreConfig = $this->processConfiguration($oCoreConfiguration, $aCoreConfigs);
//
//            // Redéfinition des paramètres de configuration du coeur de lieu idéal si il existe (autocomplete, isochron, bestpoint, etc)
//            foreach ($oCoreConfig as $sNode => $aNodeValue) {
//                $container->setParameter('li.' . $sNode, $aNodeValue);
//            }
//        }

        $sResourceLang = '%kernel.root_dir%/../custom/' . $this->client . '/Resources/translations/messages.%locale%.yml';
        // Définit le loader de récupéreration du catalogue utilisé pour les traductions
        $container
                ->register('lieuideal.translation_loader', 'CanalTP\ProductBundle\Translation\TranslationLoader')
                ->addArgument($sResourceLang)
                ->addTag('translation.loader', array('alias' => 'yml'));

        $sResourceTwigDir = '%kernel.root_dir%/../custom/' . $this->client . '/Resources/views';
        // Remplace le loader de récupéreration des templates twig pour chaque client
        $container
            ->register('twig.loader', 'CanalTP\ProductBundle\Twig\Loader\TwigLoaderAdapter')
                ->addArgument($sResourceTwigDir)
                ->addArgument(new Reference('templating.locator'))
                ->addArgument(new Reference('templating.name_parser'));
//        $container
//            ->register('lieuideal.twig.extension', 'CanalTP\ProductBundle\Twig\Extension\TwigExtension')
//                ->addArgument(new Reference('service_container'))
//                ->addTag('twig.extension');

        $reflClass = new \ReflectionClass('Symfony\Bridge\Twig\Extension\FormExtension');
        $container->getDefinition('twig.loader')->addMethodCall('addPath', array(dirname(dirname($reflClass->getFileName())) . '/Resources/views/Form'));

        if (!empty($config['paths'])) {
            foreach ($config['paths'] as $path) {
                $container->getDefinition('twig.loader')->addMethodCall('addPath', array($path));
            }
        }
    }

}
