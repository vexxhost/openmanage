FROM centos:7

ARG VERSION

COPY check_openmanage /usr/local/bin/check_openmanage
RUN yum -y install perl && \
    yum clean all

RUN curl https://linux.dell.com/repo/hardware/DSU_$VERSION/bootstrap.cgi | bash
RUN yum -y install which srvadmin-base srvadmin-storageservices && \
    yum clean all

COPY run.sh /run.sh
ENTRYPOINT ["/run.sh"]