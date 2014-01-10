<?php

/**
 * Description of TranslationLoader
 *
 *  Cette classe charge les catalogues Yml pour la translation à partir d'un dossier spécifique
 * 
 * @author akambi
 */

namespace CanalTP\ProductBundle\Translation;

use Symfony\Component\Config\Resource\FileResource;
use Symfony\Component\Yaml\Yaml;
use Symfony\Component\Translation\Loader\LoaderInterface;
use Symfony\Component\Translation\Loader\ArrayLoader;

class TranslationLoader extends ArrayLoader implements LoaderInterface {

    // Variable conservant l'url du catalogue local (utilisé par un client)
    private $sLocaleResource;

    public function __construct($sResource) {
        $this->sLocaleResource = $sResource;
    }

    public function load($resource, $locale, $domain = 'messages') {

        // chargez des traductions depuis la « ressource » d'une manière ou d'une autre
        // puis définissez les dans le catalogue
        $aMessages = Yaml::parse($resource);

        // empty file Resource translation file of bundle
        if (null !== $aMessages) {
            if (!is_array($aMessages)) {
                throw new \InvalidArgumentException(sprintf('The file "%s" must contain a YAML array.', $resource));
            }
        } else {
            $aMessages = array();
        }

        if (is_file($this->sLocaleResource)) {
            // chargez des traductions depuis la « ressource » local propre au client
            $aLocalMessages = Yaml::parse($this->sLocaleResource);
            if ((null !== $aLocalMessages) && (!is_array($aMessages))) {
                throw new \InvalidArgumentException(sprintf('The file "%s" must contain a YAML array.', $this->sLocaleResource));
            }
            // Fusionne les traductions globales à l'application avec les traductions propre au client 
            $aMessages = array_merge($aMessages, $aLocalMessages);
        }

        $catalogue = parent::load($aMessages, $locale, $domain);
        $catalogue->addResource(new FileResource($resource));
        $catalogue->addResource(new FileResource($this->sLocaleResource));

        return $catalogue;
    }

}

?>
