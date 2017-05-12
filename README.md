This script makes it possible to upload TeX-related packages to the the CTAN archive via the HTTP interface at <https://ctan.org/upload/save> in an automated fashion. You invoke the script as `ctan-upload.sh SCRIPT`, where `SCRIPT` is a shell script that defines variables describing your package. The variable names are an upper-case variant of the HTML form element names at <https://www.ctan.org/upload>; inspect the example shell script `example.def` for more information.

The `xmllint` and `curl` binaries are required.
