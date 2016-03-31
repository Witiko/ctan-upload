#!/bin/sh
die() { printf '%s\n' "${*:2}"; exit $1; }

# Source the passed file.
[ -e "$1" ] && . "$1"

# Perform sanity checks.
[ -z "$PKG" ] && die 1 Undefined / empty PKG
[ -z "$VERS" ] && die 2 Undefined / empty VERS
[ -z "$AUTHOR" ] && die 3 Undefined / empty AUTHOR
[ -z "$FILENAME" ] && die 4 Undefined / empty FILENAME
[ ! -e "$FILENAME" ] && die 5 File FILENAME does not exist
[ -z "$EMAIL" ] && die 6 Undefined / empty EMAIL
[ -z "$DESCRIPTION" ] && die 7 Undefined / empty DESCRIPTION
[ -z "$CTANPATH" ] && die 8 Undefined / empty CTANPATH
[ -z "$TYPE" ] && die 9 Undefined / empty TYPE
[ "$TYPE" = announce -a -z "$ANNOUNCEMENT" ] &&
  die 10 TYPE is announce, but ANNOUNCEMENT is undefined / empty

# Retrieve a ticket number from CTAN.
COOKIEJAR=`mktemp`
trap 'rm $COOKIEJAR' EXIT
TICKET="$(curl -c $COOKIEJAR -s 'https://ctan.org/upload' |
  sed -nr '/<input name="ticket"/s/.*<input name="ticket".*value="([^"]*)".*/\1/p')"
[ -z "$TICKET" ] && die 11 Failed to download ticket number.

# Send the archive.
RESPONSE=`mktemp`
trap 'rm $COOKIEJAR $RESPONSE' EXIT
curl -F ticket="$TICKET" \
     -F pkg="$PKG" \
     -F vers="$VERS" \
     -F author="$AUTHOR" \
     -F uploader="$UPLOADER" \
     -F email="$EMAIL" \
     -F description="$DESCRIPTION" \
     -F ctanPath="$CTANPATH" \
     -F type="$TYPE" \
     -F announcement="$ANNOUNCEMENT" \
     -F note="$NOTE" \
     -F license="$LICENSE" \
     -F 'file=@'"$FILENAME"';type=application/zip' \
     -F SUBMIT='Submit contribution' \
     -b $COOKIEJAR https://ctan.org/upload/save >$RESPONSE
grep <$RESPONSE -qF 'Your contribution has been uploaded' ||
  die 12 Upload failed: "`cat $RESPONSE`"
