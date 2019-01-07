FROM ubuntu:latest

RUN mkdir /docker

COPY ./util-apt-mirror.sh ./ss-ubuntu-client-kit.sh /docker/
COPY ./docker_build/* /docker/

RUN ["bash", "/docker/util-apt-mirror.sh"]
RUN ["bash", "/docker/ss-ubuntu-client-kit.sh"]
RUN ["bash", "/docker/post-client-kit.sh"]

ENTRYPOINT ["bash", "/docker/start.sh"]
CMD ["bash"]
