FROM ubuntu:16.04

RUN apt-get update -y && \
    apt-get install curl -y && \
    apt-get -y install openssh-client && \
    mkdir "/tmp/ssh_daemon/" && \
	ssh-keygen -t rsa -f /tmp/ssh_daemon/ssh_host_rsa_key -q -N "" && \
	mkdir -p "/tmp/otptest_user/.ssh/" && \
	ssh-keygen -t rsa -f /tmp/otptest_user/.ssh/id_rsa


ARG REL_NAME
ARG REL_VSN=1
ARG ERTS_VSN=10.0.5

ENV BINDIR /erts-${ERTS_VSN}/bin
ENV BOOT /releases/${REL_VSN}/dockerapp_release
ENV CONFIG /releases/${REL_VSN}/sys.config
ENV ARGS_FILE /releases/${REL_VSN}/vm.args

ENV TZ=GMT

ENTRYPOINT exec ${BINDIR}/erlexec -boot_var ERTS_LIB_DIR /lib -boot ${BOOT} -noinput -config ${CONFIG} -args_file ${ARGS_FILE}

ADD _rel/dockerapp_release/ /
