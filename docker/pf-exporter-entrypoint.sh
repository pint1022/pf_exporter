#!/usr/bin/env bash
set -euo pipefail

# We want to setcap only when the container is started with the right caps
PF_EXPORTER=$(readlink -f $(which pf-exporter))
if [ -z "$NO_SETCAP" ]; then
   setcap 'cap_sys_admin=+ep' $PF_EXPORTER
   if [ $? -eq 0 ]; then
      if ! $DCGM_EXPORTER -v 1>/dev/null 2>/dev/null; then
         >&2 echo "Warning #2: pf-exporter doesn't have sufficient privileges to expose profiling metrics. To get profiling metrics with dcgm-exporter, use --cap-add SYS_ADMIN"
         setcap 'cap_sys_admin=-ep' $DCGM_EXPORTER
      fi
   else
      >&2 echo "Warning #1: pf-exporter doesn't have sufficient privileges to expose profiling metrics. To get profiling metrics with dcgm-exporter, use --cap-add SYS_ADMIN"
   fi

fi

# Pass the command line arguments to dcgm-exporter
set -- $PF_EXPORTER "$@"
exec "$@"
