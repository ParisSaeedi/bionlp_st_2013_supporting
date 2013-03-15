# Short-hands for the build products.
#
# Author:		Pontus Stenetorp	<pontus stenetorp se>
# Version:		2013-03-12

.DEFAULT_GOAL=checksums
.PHONY: checksums
checksums:
	../tls/checksums.sh ./ `find . -name '*.tar.gz'`

.PHONY: urls
urls:
	../src/gp_urls.sh

.PHONY: clean
clean:
	find . -name '*.tar.gz' | xargs -r rm
	rm -f CHECKSUM.MD5 CHECKSUM.SHA512
