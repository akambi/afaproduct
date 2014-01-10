<?php

namespace CanalTP\ProductBundle\DependencyInjection\Compiler;

use Symfony\Component\DependencyInjection\ContainerBuilder;
use Symfony\Component\DependencyInjection\Compiler\CompilerPassInterface;
use CanalTP\ProductBundle\CanalTPProductBundle;
use Symfony\Component\Config\FileLocator;
use Symfony\Component\DependencyInjection\Loader;
use Symfony\Component\HttpKernel\Exception\NotFoundHttpException;

/**
 * Surcharge la configuration des extension symfony pour chaque client
 *
 * @author akambi
 */
class CanalTPMergeProductConfigurationCompilerPass implements CompilerPassInterface
{

    /**
     * {@inheritDoc}
     */
    public function process(ContainerBuilder $container) {

        $sCustomerFolder = CanalTPProductBundle::findClient($container);
        if (($sCustomerFolder) && ($sCustomerFolder != 'Default')) {
            $this->addCustomConfigurationClient($container, $sCustomerFolder);
        }

        $parameters = $container->getParameterBag()->all();
        $definitions = $container->getDefinitions();
        $aliases = $container->getAliases();

        foreach ($container->getExtensions() as $name => $extension) {
            if (!$config = $container->getExtensionConfig($name)) {
                // this extension was not called
                continue;
            }

            $config = $container->getParameterBag()->resolveValue($config);

            $tmpContainer = new ContainerBuilder($container->getParameterBag());
            $tmpContainer->addObjectResource($extension);

            $extension->load($config, $tmpContainer);

            $container->merge($tmpContainer);
        }

        $container->addDefinitions($definitions);
        $container->addAliases($aliases);
        $container->getParameterBag()->add($parameters);
    }
    
        /**
     *  Ajoute les configurations, catalogues, views, assets du client
     */
    private function addCustomConfigurationClient(ContainerBuilder $container, $sClientFolder)
    {
        $clientDir = $this->getClientDir($sClientFolder);

        $aConfigClient = array($clientDir . '/Resources/config');
        $oLocatorConfigClient = new FileLocator($aConfigClient);
        $oLoaderConfigClient = new Loader\YamlFileLoader($container, $oLocatorConfigClient);

        // Chargement du fichier de configuration des formulaires du client
        if (is_file($clientDir . '/Resources/config/lieuideal.form.parameters.yml')) {
            $oLoaderConfigClient->load('lieuideal.form.parameters.yml');
        }
    }

    private function getClientDir($client)
    {
        if (empty($client)) {
            throw new NotFoundHttpException('Le nom du client est obligatoire');
        }

        $projectDir = dirname(__FILE__) . '/../../../../../';
        $clientDir = $projectDir . DIRECTORY_SEPARATOR . 'custom' . DIRECTORY_SEPARATOR . $client;

        if (!is_dir($clientDir)) {
            throw new NotFoundHttpException('Le chemin "' . $clientDir . '" n\'est pas un repertoire');
        }

        return $clientDir;
    }

}

?>
