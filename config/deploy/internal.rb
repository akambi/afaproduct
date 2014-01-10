# encoding: utf-8

server "10.2.16.34", :web, :app, :db, :primary => true
set :user,      'lideploy'                                  # Utilisatieur SSH
set :password,  'Yg7AC'                                     # Mot de passe de l'utilisateur SSH
set :deploy_to, '/var/www/li/product'                       # Dossier de deploiement de l'application

#bordeaux
set :brdx_client_folder,    'bordeaux'
set :brdx_servername,       'li-ihm.bordeaux.internal.canaltp.fr'

set :brdx_db_hostname,      'localhost'
set :brdx_db_database,      'li_product_brdx_intl'
set :brdx_db_username,      'lidbinternal'
set :brdx_db_password,      'Gh8ZX'

set :brdx_mail_hostname,    '10.150.34.177'
set :brdx_mail_username,    'null'
set :brdx_mail_password,    'null'

set :brdx_memcache_hostname, 'localhost'
set :brdx_memcache_port,     '11211'


#ile de france
set :idf_client_folder,    'idf'
set :idf_servername,       'li-ihm.idf.internal.canaltp.fr'

set :idf_db_hostname,      'localhost'
set :idf_db_database,      'li_product_idf_intl'
set :idf_db_username,      'lidbinternal'
set :idf_db_password,      'Gh8ZX'

set :idf_mail_hostname,    '10.150.34.177'
set :idf_mail_username,    'null'
set :idf_mail_password,    'null'

set :idf_memcache_hostname, 'localhost'
set :idf_memcache_port,     '11211'

set :db_username,     'lidbinternal'
set :db_password,     'Gh8ZX'