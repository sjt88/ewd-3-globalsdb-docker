FROM ubuntu:14.04

LABEL vesion=0.1.0
LABEL usage="\
      docker run -p 8080:8080                          \
        -v /path/to/www:/ewd3/www                      \
        -v /path/to/ewd-startup-file.js:/ewd3/app.js   \
        todo/ewd3-globalsdb                            \
"

RUN sudo apt-get update
RUN sudo apt-get install -y wget gzip openssh-server curl git

# globalsdb
RUN sudo sysctl -w kernel.shmall=536870912
RUN sudo sysctl -w kernel.shmmax=536870912
RUN sudo /bin/su -c "echo 'kernel.shmall=536870912' >> /etc/sysctl.conf"
RUN sudo /bin/su -c "echo 'kernel.shmmax=536870912' >> /etc/sysctl.conf"
RUN wget https://s3-eu-west-1.amazonaws.com/globalsdb/globals_2013.2.0.350.0_unix.tar.gz
RUN gzip -cd globals_2013.2.0.350.0_unix.tar.gz | tar -x
RUN rm globals_2013.2.0.350.0_unix.tar.gz
ENV INSTALL_DIR /kit_unix_globals
ENV EWD3_DIR /ewd3
ENV ISC_QUIET yes
ENV ISC_TGTDIR /globalsdb
ENV ISC_PLATFORM lnxsusex64
RUN mkdir $INSTALL_DIR/globalsdb
RUN cd $INSTALL_DIR && ./installGlobals
RUN rm -rf $INSTALL_DIR

# nvm
ENV NVM_DIR /nvm
RUN git clone https://github.com/creationix/nvm.git "$NVM_DIR"
RUN cd "$NVM_DIR" && git checkout `git describe --abbrev=0 --tags --match "v[0-9]*" origin`
ENV NODE_VERSION 4.5.0
RUN . $NVM_DIR/nvm.sh \
    && nvm install $NODE_VERSION

# ewd-3
RUN mkdir $EWD3_DIR
RUN cd $EWD3_DIR \
    && $NVM_DIR/versions/node/v$NODE_VERSION/bin/npm install ewd-xpress \
    && $NVM_DIR/versions/node/v$NODE_VERSION/bin/npm install ewd-xpress-monitor \
    && $NVM_DIR/versions/node/v$NODE_VERSION/bin/npm install ewd-client

# cache.node
RUN cd $EWD3_DIR/node_modules \
    && wget https://s3-eu-west-1.amazonaws.com/cache.node/build-113/linux/cache421.node \
    && mv cache421.node cache.node
RUN cp $EWD3_DIR/node_modules/ewd-xpress/example/ewd-xpress-globalsdb.js $EWD3_DIR/ewd-xpress.js

# RUN mkdir $EWD3_DIR/www && mkdir $EWD3_DIR/www/ewd-xpress-monitor
# RUN cp $EWD3_DIR/node_modules/ewd-xpress-monitor/www/bundle.js $EWD3_DIR/www/ewd-xpress-monitor
# RUN cp $EWD3_DIR/node_modules/ewd-xpress-monitor/www/*.html $EWD3_DIR/www/ewd-xpress-monitor
# RUN cp $EWD3_DIR/node_modules/ewd-xpress-monitor/www/*.css $EWD3_DIR/www/ewd-xpress-monitor
# RUN cp $EWD3_DIR/node_modules/ewd-client/lib/proto/ewd-client.js $EWD3_DIR/www/ewd-client.js
# RUN cd $EWD3_DIR

EXPOSE 8080:8080

CMD cd $EWD3_DIR && echo "starting ewd-3 application..." && /nvm/versions/node/v$NODE_VERSION/bin/node $EWD3_DIR/app.js
