<?php

$ip = shell_exec('curl -s ifconfig.co/ip');

$country = geoip_country_code_by_name($ip);
if ($country) {
	$timezone = geoip_time_zone_by_country_and_region($country);
	if ($timezone) {
	echo $timezone;
	}
}

?>