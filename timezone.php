<?php

//usage php -f timezone.php ip.add.re.ss

$ip = $argv[1];

$country = geoip_country_code_by_name($ip);
if ($country) {
	$timezone = geoip_time_zone_by_country_and_region($country);
	if ($timezone) {
	echo $timezone;
	}
}

?>