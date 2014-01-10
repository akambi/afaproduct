<?php

namespace CanalTP\ProductBundle\HttpKernel;

require_once __DIR__.'/../../../../app/AppKernel.php';

use Symfony\Component\Config\Loader\LoaderInterface;
use Symfony\Component\Console\Input\ArgvInput;
//use CanalTP\ProductBundle\DependencyInjection\Compiler\ContainerBuilder;


class AppKernel extends \AppKernel {

    const VERSION         = '0.1';
    protected $customerFolderName;
    protected $customerDir;
    
    /**
     * Constructor.
     *
     * {@inheritdoc}
     *
     * @api
     */
    public function __construct($environment, $debug)
    {
        parent::__construct($environment, $debug);
        $this->customerFolderName = $this->getCustomerFolder();
//        $this->customerDir = __DIR__ . '/../custom/';
        $this->customerDir = __DIR__ . '/../../../../custom/';
        
    }

    /**
     * {@inheritdoc}
     *
     * @return array An array of kernel parameters
     */
    protected function getKernelParameters()
    {
        return array_merge(
            parent::getKernelParameters(),
            $this->getCustomerParameters()
        );        
    }

    /**
     * Gets the customer parameters.
     *
     * @return array An array of parameters
     */
    protected function getCustomerParameters()
    {
        return array(
            'kernel.customer_root_dir' => $this->customerDir . $this->customerFolderName
        );
    }
    
    /**
     * {@inheritdoc}
     *
     * @return string The application root dir
     *
     * @api
     */
    public function getRootDir()
    {
        if (null === $this->rootDir) {
            $r = new \ReflectionObject($this);
            $this->rootDir = str_replace('\\', '/', dirname($r->getFileName()) . '/../../../../app');
        }

        return $this->rootDir;
    }
    
//    protected function getContainerBuilder()
//    {
//        // TODO: Etendre container builder au lieu d'hériter
//        return new ContainerBuilder(new ParameterBag($this->getKernelParameters()));
//    }
    
    public function registerContainerConfiguration(LoaderInterface $loader)
    {
     
        parent::registerContainerConfiguration($loader);
        
        // Load customer config if define
        $aCustomer = array();

        if ($this->customerFolderName === '') {
            // If no customer found (case of command line), load configs of all customers in order to generate all assets
            foreach (new \DirectoryIterator($this->customerDir) as $fn) {
                if (!$fn->isDot()) {
                    $aCustomer[] = $fn->getFilename();
                }
            }
        } else {
            $aCustomer[] = $this->customerFolderName;
        }

        // Load configs
        foreach ($aCustomer as $customer) {
            $sClientConfig = $this->customerDir . $customer . '/Resources/config/config.yml';
            if (is_file($sClientConfig)) {
                $loader->load($sClientConfig);
            }
        }
    }

    /**
     *  Define cache directory for each customer (virtualhost)
     * @return string
     */
    public function getCacheDir() {
        return $this->rootDir . '/cache/' . $this->customerFolderName . '/' . $this->environment;
    }

    /**
     *  Define log directory for each customer (virtualhost)
     * @return string
     */
    public function getLogDir() {
        return $this->rootDir . '/logs/' . $this->customerFolderName;
    }

    /**
     * Find current customer
     * @param \Symfony\Component\DependencyInjection\ContainerBuilder $container
     */
    public function getCustomerFolder() {

        $envParameters = $this->getEnvParameters();
        $folder = '';

        //en mode apache
        if (isset($envParameters['accesskey'])) {
            $folder = $envParameters['accesskey'];
        } //en mode CLI
        else if(php_sapi_name() == 'cli') {
            $input = new ArgvInput();
            $folder = $input->getParameterOption('--client');
        }

        return ucfirst($folder);
    }

}
