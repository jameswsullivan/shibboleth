FROM rockylinux:9.2

COPY ./rockylinux.shibboleth.repo /etc/yum.repos.d/shibboleth.repo

RUN dnf update -y && \
    dnf install nano httpd shibboleth.x86_64 -y && \
    mkdir /opt/shibboleth && \
    rm -rf /etc/localtime && \
    ln -fs /usr/share/zoneinfo/US/Central /etc/localtime

COPY ./shibboleth2.xml.test /etc/shibboleth/shibboleth2.xml
COPY ./rockylinux.entrypoint.sh /opt/shibboleth/entrypoint.sh

RUN chmod +x /opt/shibboleth/entrypoint.sh

EXPOSE 80 443
ENTRYPOINT [ "/opt/shibboleth/entrypoint.sh" ]