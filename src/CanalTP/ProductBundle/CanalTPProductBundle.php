<?php

namespace CanalTP\ProductBundle;

use Symfony\Component\HttpKernel\Bundle\Bundle;
use Symfony\Component\DependencyInjection\ContainerBuilder;
use CanalTP\ProductBundle\DependencyInjection\Compiler\CanalTPMergeProductConfigurationCompilerPass;
use Symfony\Component\Console\Input\ArgvInput;

class CanalTPProductBundle extends Bundle {

    public function build(ContainerBuilder $container) {

        parent::build($container);
        // Add a compiler pass to deal overload of customer config .
        $container->addCompilerPass(new CanalTPMergeProductConfigurationCompilerPass);
    }

    /**
     * Find current customer in global apache variable or in command line parameter
     * @param \Symfony\Component\DependencyInjection\ContainerBuilder $container
     */
    public static function findClient(ContainerBuilder $container)
    {
        $sCustomer = NULL;

        if ($container->hasParameter('ACCESSKEY')) {
            $sCustomer = ucfirst($container->getParameter('ACCESSKEY'));
        } else if(php_sapi_name() == 'cli') {
            $input = new ArgvInput();
            $sCustomer = $input->getParameterOption('--client');
        }

        return $sCustomer;
    }

}
