<?php

/**
 * Description of TwigLoaderAdapter
 *
 *  Cette classe charge les templates twig à partir d'un dossier spécifique
 *
 * @author akambi
 */

namespace CanalTP\ProductBundle\Twig\Loader;

use Symfony\Bundle\TwigBundle\Loader\FilesystemLoader;

class TwigLoaderAdapter extends FilesystemLoader {

    private $sResourceTwigDir;
    
    public function __construct($sResourceTwigDir, $locator, $parser) {
        $this->sResourceTwigDir = $sResourceTwigDir;
        parent::__construct($locator, $parser);
    }
        
    /**
     *  Cette classe charge un template local si existant sinon charge le template parent
     * @param type $path : Chemin du template à charger dans le bundle
     * @return type : Chemin du template local chargé
     */
    protected function findTemplate($path) {
        
        $sNewResourceUrl = (string) $this->getLocalResource($path);
        if (is_file($sNewResourceUrl)) {
            if (isset($this->cache[$sNewResourceUrl])) {
                return $this->cache[$sNewResourceUrl];
            } else {
                return $this->cache[$sNewResourceUrl] = $sNewResourceUrl;
            }           
        } else {
            return parent::findTemplate($path);
        }
    }

    /**
     * Retrouve l'url du template local à partir du template original
     * @param type $name
     * 
     */
     private function getLocalResource($name) {
        $aResource = explode(":", $name);
        if (3 == count($aResource)) {
            $aResource[0] = $this->sResourceTwigDir;
            if ($aResource[1] === '') {
                unset($aResource[1]);
            }
            $sNewResourceUrl = implode("/", $aResource);
            return $sNewResourceUrl;
        }
        return false;
     }
}

?>
