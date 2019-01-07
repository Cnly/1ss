FROM ubuntu:latest

RUN mkdir /docker

COPY ./util_apt_mirror.sh ./ss_ubuntu_client_kit.sh /docker/
COPY ./docker_build/* /docker/

RUN ["bash", "/docker/util_apt_mirror.sh"]
RUN ["bash", "/docker/ss_ubuntu_client_kit.sh"]
RUN ["bash", "/docker/post-client-kit.sh"]

ENTRYPOINT ["bash", "/docker/start.sh"]
CMD ["bash"]
