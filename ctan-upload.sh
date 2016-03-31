#!/bin/sh
die() { printf '%s\n' "${*:2}"; exit $1; }

# Source the passed file.
[ -e "$1" ] && . "$1"

# Perform sanity checks.
[ -z "$PKG" ] && die 1 Undefined PKG
[ -z "$VERS" ] && die 2 Undefined VERS
[ -z "$AUTHOR" ] && die 3 Undefined AUTHOR
[ ! -e "$FILENAME" ] && die 4 Undefined FILENAME
[ -z "$EMAIL" ] && die 5 Undefined EMAIL
[ -z "$DESCRIPTION" ] && die 6 Undefined DESCRIPTION
[ -z "$CTANPATH" ] && die 7 Undefined CTANPATH
[ -z "$TYPE" ] && die 8 Undefined TYPE
[ "$TYPE" = announce -a -z "$ANNOUNCEMENT" ] &&
  die 9 TYPE is announce, but ANNOUNCEMENT is undefined

# Retrieve a ticket number from CTAN.
COOKIEJAR=`mktemp`
trap 'rm $COOKIEJAR' EXIT
TICKET="$(curl -c $COOKIEJAR -s 'https://ctan.org/upload' |
  sed -nr '/<input name="ticket"/s/.*<input name="ticket".*value="([^"]*)".*/\1/p')"
[ -z "$TICKET" ] && die 10 Failed to download ticket number.

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
     -b $COOKIEJAR https://ctan.org/upload/save | tee $RESPONSE
  grep <$RESPONSE -qF 'Your contribution has been uploaded' ||
  die 11 Upload failed: "`cat $RESPONSE`"
