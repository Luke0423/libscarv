# Copyright (C) 2019 SCARV project <info@scarv.org>
#
# Use of this source code is restricted per the MIT license, a copy of which 
# can be found at https://opensource.org/licenses/MIT (or should be included 
# as LICENSE.txt within the associated archive or repository).

FROM ubuntu

ARG DATE

LABEL maintainer="SCARV project <info@scarv.org>" date="${DATE}" url="https://github.com/scarv/libscarv"

RUN apt-get --assume-yes --quiet update \
 && apt-get --assume-yes --quiet install apt-utils gettext-base gosu sudo python3 python3-pip python3-venv \
 && pip3                         install pycrypto pycryptodomex

include(`Dockerfile.in')

COPY ./entrypoint.sh /usr/sbin/entrypoint.sh
RUN chmod 755 /usr/sbin/entrypoint.sh

ENTRYPOINT [ "/usr/sbin/entrypoint.sh" ]