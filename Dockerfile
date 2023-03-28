ARG LINUX_VERSION=2023
ARG ODBC_VERSION=1.4.56.1000
ARG RSQL_VERSION=1.0.6

FROM amazonlinux:${LINUX_VERSION}

WORKDIR /tmp

RUN yum update -y && \
    yum install -y unixODBC openssl && \
    yum clean all

ARG EXTENSION="rpm"

# TODO: Installing the RPMs on Amazon Linux fails because of incompatible architectures... 32-bit doesn't work either.
# TODO: It's 2023 and the official Amazon Linux image can't even install the official Redshift dirvers?!
# TODO: I'd use Debian instead, because they have a DEB for ODBC, but they only have an RPM for RSQL... :(

####################################################### ODBC #######################################################
# https://docs.aws.amazon.com/redshift/latest/mgmt/configure-odbc-connection.html#odbc-driver-linux-how-to-install #
####################################################################################################################

ARG ODBC_VERSION
ARG ODBC_FILE="AmazonRedshiftODBC-64-bit-${ODBC_VERSION}-1.x86_64.${EXTENSION}"
ARG ODBC_URL="https://s3.amazonaws.com/redshift-downloads/drivers/odbc/${ODBC_VERSION}/${ODBC_FILE}"
RUN curl -o ${ODBC_FILE} ${ODBC_URL}
RUN yum --nogpgcheck localinstall ${ODBC_FILE}
RUN cp /opt/amazon/redshiftodbc/Setup/odbc.ini ~/.odbc.ini

####################################################### RSQL #######################################################
# https://docs.aws.amazon.com/redshift/latest/mgmt/rsql-query-tool-getting-started.html                            #
####################################################################################################################

ARG RSQL_VERSION
ARG RSQL_FILE="AmazonRedshiftRsql-${RSQL_VERSION}.x86_64.${EXTENSION}"
ARG RSQL_URL="https://s3.amazonaws.com/redshift-downloads/amazon-redshift-rsql/${RSQL_VERSION}/${RSQL_FILE}"
RUN curl -o ${RSQL_FILE} ${RSQL_URL}
# I don't know why the docs use both yum and rpm for different steps, but...
RUN sudo rpm -i ${RSQL_FILE}

####################################################################################################################

ENV ODBCINI=~/.odbc.ini
ENV ODBCSYSINI=/opt/amazon/redshiftodbc/Setup
ENV AMAZONREDSHIFTODBCINI=/opt/amazon/redshiftodbc/lib/64/amazon.redshiftodbc.ini

ENTRYPOINT ["/usr/bin/rsql"]
