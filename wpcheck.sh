#!/bin/sh

# wp-cli segfaults a lot. Ensure php.core is dumped into the script directory instead of
# into WP installations. Note that when a segfault occurs, one or more checks below fail.
# This script does not look for which checks fail but will print a non-specific segfault
# warning.
SCRIPT=`readlink -f "$0"`
SH_PATH=`dirname "$SCRIPT"`
cd "$SH_PATH"

CONFIG=`cat "$SH_PATH"/wpcheck.conf`
WP=`echo "$CONFIG" | sed -E -n 's/^ *wp_path *= *//p'`
SEARCH_PATH=`echo "$CONFIG" | sed -E -n 's/^ *search_path *= *//p' | sed -E 's/ *$//'`
FIND_FLAGS=`echo "$CONFIG" | sed -E -n 's/^ *find_flags *= *//p'`
EMAIL_B=`echo "$CONFIG" | sed -E -n 's/^ *email_b *= *//p'`
EMAIL_F=`echo "$CONFIG" | sed -E -n 's/^ *email_f *= *//p'`
MESSAGE_COMMENTS=`echo "$CONFIG" | sed -E -n 's/^ *message_comments *= *//p'`
MESSAGE_PINGBACKS=`echo "$CONFIG" | sed -E -n 's/^ *message_pingbacks *= *//p'`

# wp-cli requires WP_CLI_PHP.
WP_CLI_PHP=`echo "$CONFIG" | sed -E -n 's/^ *php_path *= *//p'`
export WP_CLI_PHP

for WPPATH in `find $SEARCH_PATH -type d -name 'wp-admin' $FIND_FLAGS`
do
  WPPATH=` echo "$WPPATH" | sed -E 's~/wp-admin$~~g'`
  echo $'\n'$WPPATH
  FLAGS='--allow-root --path='"$WPPATH"
  SITE_URL=`$WP option get siteurl $FLAGS | sed -E -n 's~[^/]+//~~p'`
  if ! echo "$CONFIG" | grep -qs -E "^ *skip $SITE_URL *"'$'
  then
    ADMIN_EMAIL=`$WP option get admin_email $FLAGS`
    STATUS=`$WP option get blogname $FLAGS`$'\n'"$SITE_URL"$'\n'"$ADMIN_EMAIL"
    ISSUES=0
    
    if $WP core check-update $FLAGS | grep -qs 'package_url'
    then
      ISSUES=$((1+ISSUES))
      STATUS="$STATUS"$'\n--Core update needed (Currently version '`$WP core version $FLAGS`')'
    fi
    
    if ! echo "$CONFIG" | grep -qs -E "^ *allow comments $SITE_URL *"
    then
      if $WP option get default_comment_status $FLAGS | grep -qs 'open'
      then
        ISSUES=$((1+ISSUES))
        STATUS="$STATUS"$'\n'"$MESSAGE_COMMENTS"
      fi
    fi
  
    if ! echo "$CONFIG" | grep -qs -E "^ *allow pingbacks $SITE_URL *"
    then
      if $WP option get default_ping_status $FLAGS | grep -qs 'open'
      then
        ISSUES=$((1+ISSUES))
        STATUS="$STATUS"$'\n--'"$MESSAGE_PINGBACKS"
      fi
    fi
    
    PTEST=` $WP plugin status $FLAGS | grep -E '^ +[^AIN ]+[AIN]? ' | sed -E 's/^ +[^AIN ]+[AIN]? /    /g'`
    if [ "$PTEST" != "" ]
    then
      ISSUES=$((1+ISSUES))
      STATUS="$STATUS"$'\n--Plugin update(s) needed:\n'"$PTEST"
    fi
  
    TTEST=` $WP theme  status $FLAGS | grep -E '^ +[^AINP ]{1,2}[AINP]? ' | sed -E 's/^ +[^AINP ]{1,2}[AINP]? /    /g'`
    if [ "$TTEST" != "" ]
    then
      ISSUES=$((1+ISSUES))
      STATUS="$STATUS"$'\n--Theme update(s) needed:\n'"$TTEST"
    fi
  
    if [ "$ISSUES" -gt 0 ]
    then
      echo "$STATUS"
      NO_EMAIL=`echo "$CONFIG" | grep -E "^ *no email $ADMIN_EMAIL*" `
      if [ "$NO_EMAIL" == "" -a "--email-admins" == "$1" ]
      then
        echo "$STATUS" | mail -s "Wordpress upgrades needed" -b "$EMAIL_B" "$ADMIN_EMAIL" -f "$EMAIL_F"
        echo "mail sent"
      else
        echo "no email"
      fi
    fi
  fi
done

