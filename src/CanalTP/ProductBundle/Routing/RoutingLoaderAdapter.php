<?php

/**
 * Description of RoutingLoader
 *
 * Cette classe charge les routing Yml pour un client donné
 * 
 * @author akambi
 */
namespace CanalTP\ProductBundle\Routing;

use Symfony\Component\Routing\Loader\YamlFileLoader;
use Symfony\Component\Config\FileLocatorInterface;

class RoutingLoaderAdapter extends YamlFileLoader
{

    private $loaded = false;
    // Variable conservant l'url de la route local (utilisé par un client) . Ne gère que les fichiers Yaml
    private $sLocaleResource;
    
    public function __construct($sDefaultResourceUrl, $sLocaleResource, FileLocatorInterface $locator) {
        
        // Si la resource locale n'est pas valide, alors charge la resource par défaut
        if (!is_file($sLocaleResource)) {
            $this->sLocaleResource = $sDefaultResourceUrl;
        } else {
            $this->sLocaleResource = $sLocaleResource;
        }
        parent::__construct($locator);
    }

    public function load($resource, $type = null)
    {
        if (true === $this->loaded) {
            throw new \RuntimeException('Do not add the "extra" loader twice');
        }
        
        $collection = parent::load($this->sLocaleResource, 'yaml');
        
        return $collection;
    }

    public function supports($resource, $type = null)
    {
        return 'extra' === $type;
    }
    
}

?>
