UPDATE_LIST=$( /scripts/cli.sh list-plugins | grep -e ')$' | awk '{ print $1 }' );
if [ ! -z "${UPDATE_LIST}" ]; then
  echo Updating Jenkins Plugins: ${UPDATE_LIST};
  /scripts/cli.sh install-plugin ${UPDATE_LIST};
  /scripts/cli.sh safe-restart;
fi
