# wpcheck

Shell script to find out of date Wordpress installations and components.

## Requirements

[WP-CLI](http://wp-cli.org/) does most of the actual work.  It requires PHP and such.

This script can email site admins.  Postfix, Sendmail, or something similar needs to be configured, or this will fail (and probably do so silently).

`sudo` is required when `--update-all` is passed.

## Installation and configuration

Rename wpcheck.conf.sample to wpcheck.conf, and configure the values in the required section.

Full paths to WP-CLI and PHP aren't strictly required, but including them rather than relying on your $PATH value is most reliable.

## Usage notes

This script expects Wordpress core, plugins, and themes to be up to date with wordpress.org.  It also complains about sites that, by default, allow comments and/or pingbacks on new posts.

Run the script as needed or set up a crontab run as a user with read access for all web-accessible paths (or at least all in the script's search path).  The script does not need to be run as root but passes the --allow-root flag to wp-cli so that it can be.

Pass `--email-admins` for the script to email results to site admins (per the value of 'admin_email' in the wp_options table).  Results are only sent when updates are needed or a site allows comments/pingbacks by default and has not been white listed to allow them.

Pass `--update-all` for the script to update all out of date core, themes, and plugins.

The script only accepts one argument.  If both `--email-admins` and `--update-all` are passed, the first will be respected.  The second will be ignored.  This is easily corrected but perhaps shouldn't be, since automatic udpates aren't guaranteed to work.  Using the script for completely automated status reports and heavily assisted manual updates is generally best practice.

The full path to `sudo` isn't available to the script, which will prevent crontabs from calling `--update-all` on some systems.

See the end of the config file to exclude sites (such as dev sites with restricted access) prevent emailing to particular users (this is useful for reducing clutter when a site admin also received crontab results).  Sites can also be whitelisted for allowing comments and/or pingbacks on new posts.

