<?php
exit;
?>
;///////////////////////////////////////////////////////////////////////////////
;
; NagiosQL
;
;///////////////////////////////////////////////////////////////////////////////
;
; Project  : NagiosQL
; Component: Database Configuration
; Website  : http://www.nagiosql.org
; Date     : March 9, 2018, 4:48 pm
; Version  : 3.3.0
;
;///////////////////////////////////////////////////////////////////////////////
[db]
type         = mysqli
server       = localhost
port         = 3306
database     = db_nagiosql_v32
username     = nagiosql_user
password     = {{ password }}
[path]
base_url     = /nagiosql33/
base_path    = /var/www/html/nagiosql33/
