# wpcheck

Shell script to find out of date Wordpress installations and components.

## Requirements

[WP-CLI](http://wp-cli.org/) does most of the actual work.  It requires PHP and such.

This script can email site admins.  Postfix, Sendmail, or something similar needs to be configured, or this will fail (and probably do so silently).

## Installation and configuration

Rename wpcheck.conf.sample to wpcheck.conf, and configure the values in the required section.

Full paths to WP-CLI and PHP aren't strictly required, but including them rather than relying on your $PATH value is most reliable.

## Usage notes

This script expects Wordpress core, plugins, and themes to be up to date with wordpress.org.  It also complains about sites that, by default, allow comments and/or pingbacks on new posts.

Run the script as needed or set up a crontab run as a user with read access for all web-accessible paths (or at least all in the script's search path).  The script does not need to be run as root but passes the --allow-root flag to wp-cli so that it can be.

Pass `--email-admins` for the script to email results to site admins (per the value of 'admin_email' in the wp_options table).  Results are only sent when updates are needed or a site allows comments/pingbacks by default and has not been white listed to allow them.

See the end of the config file to exclude sites (such as dev sites with restricted access) prevent emailing to particular users (this is useful for reducing clutter when a site admin also received crontab results).  Sites can also be whitelisted for allowing comments and/or pingbacks on new posts.

## Automatic updates

This script could be modified to use wp-cli to update out of date Wordpress instances, plugins, and themes. This would require adding something like `sudo -u $SITE_OWNER `$WP core update $FLAGS`. Note that $SITE_OWNER is not calculated by the current script, though that's easy enough.  Unlike Wordpress' built in auto-updating feature, this would not require that your web server's owner-user have write access to WP core, plugin, and theme files.  I may build this, but it has limited usefulness, since sites still require manual testing post-update.

