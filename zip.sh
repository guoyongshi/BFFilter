#! /bin/sh

bfdir=`dirname $0`

cd $bfdir/..

if [ ! -f "BFFilter/BFFilter.toc" ]; then
	echo "BFFilter/BFFilter.toc not found"
	exit
fi

ver=`grep '## Version' BFFilter/BFFilter.toc |sed 's/.*: \?//'`

rm -f BFFilter-$ver.zip


zip -r BFFilter-$ver.zip BFFilter -x "BFFilter/.*" "BFFilter/zip.sh"

cd -

