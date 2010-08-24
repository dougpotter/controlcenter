#!/bin/sh
# update_partner_beacon_requests.sh: 
#   Updates partner_beacon_requests table from processed logs in S3.

S3_BUCKET="xg-live-hadoop"
AWK_PARSER=$(dirname `readlink -f $0`)/hivetr.awk

PIDS=`s3cmd list xg-live-hadoop 1000 / | grep dir: | sed 's/[^0-9]//g' | \
  grep -v 1007 | grep -v 14557 | grep -v 15530 | grep -v 12269 | grep -v 0000`

YESTERDAY="$1"
shift

for pid in $PIDS ; do
  s3tosql -s 'awk -F\t -f '${AWK_PARSER} \
    ${S3_BUCKET}:${pid}/export-tsv/${YESTERDAY} partner_beacon_requests $@
done
