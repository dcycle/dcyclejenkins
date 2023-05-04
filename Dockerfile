FROM jenkins/jenkins:latest

USER root

RUN apt-get update && \
  apt-get -y --no-install-recommends install python3 && \
  rm -rf /var/lib/apt/lists/*

USER jenkins
