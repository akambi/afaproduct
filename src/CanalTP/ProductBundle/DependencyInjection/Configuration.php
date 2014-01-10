<?php

namespace CanalTP\ProductBundle\DependencyInjection;

use Symfony\Component\Config\Definition\Builder\TreeBuilder;
use Symfony\Component\Config\Definition\ConfigurationInterface;
use Symfony\Component\Config\Definition\Builder\ArrayNodeDefinition;
use CanalTP\LieuIdealCoreBundle\DependencyInjection\Configuration as CoreBundleConfiguration;

/**
 * This is the class that validates and merges configuration from your app/config files
 *
 * To learn more see {@link http://symfony.com/doc/current/cookbook/bundles/extension.html#cookbook-bundles-extension-config-class}
 */
class Configuration extends CoreBundleConfiguration
{
    /**
     * {@inheritDoc}
     */
    public function getConfigTreeBuilder()
    {
        $treeBuilder = new TreeBuilder();
        $rootNode = $treeBuilder->root('canal_tp_isochron');

//        $this->addWebservicesSection($rootNode);
        $this->addLayoutSection($rootNode);
        
        return $treeBuilder;
    }


    /**
     * Ajout la section de navigation
     */
    private function addLayoutSection(ArrayNodeDefinition $rootNode)
    {
        $rootNode
            ->children()
                ->arrayNode('layout')
                    ->info('Configuration de layout')
                    ->children()
                        ->arrayNode('header')
                            ->info('Parametrage de header')
                            ->children()
                                ->booleanNode('active')
                                    ->info('Activer l\'affichage de l\'entête ')
                                    ->defaultTrue()
                                ->end()
                            ->end()
                        ->end()
                        ->arrayNode('footer')
                            ->info('Parametrage de footer')
                            ->children()
                                ->booleanNode('active')
                                    ->info('Activer l\'affichage de footer')
                                    ->defaultTrue()
                                ->end()
                            ->end()
                        ->end()
                        ->arrayNode('navigation')
                            ->info('Parametrage du menu de navigation')
                            ->children()
                                ->arrayNode('feedback')
                                    ->info('Configuration de l\'item votre avis')
                                    ->children()
                                        ->booleanNode('active')
                                            ->info('Activer l\'affichage de votre avis')
                                            ->defaultTrue()
                                        ->end()
                                    ->end()
                                ->end()
                            ->end()
                        ->end()
                    ->end()
                ->end()
            ->end()
        ->end()
        ;
    }
}
