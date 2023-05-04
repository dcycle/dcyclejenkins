FROM jenkins/jenkins:latest

RUN apt-get update && \
  apt-get -y --no-install-recommends install python3 && \
  rm -rf /var/lib/apt/lists/*
