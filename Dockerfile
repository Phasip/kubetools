FROM ubuntu:latest
# kubectl
RUN apt update && DEBIAN_FRONTEND=noninteractive apt -y install curl apt-transport-https gnupg
RUN curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
RUN echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" > /etc/apt/sources.list.d/kubernetes.list
RUN apt update && DEBIAN_FRONTEND=noninteractive apt -y install kubelet kubeadm kubectl

# KubiScan
RUN apt update && \
	DEBIAN_FRONTEND=noninteractive apt install -y python3 git python3-pip
RUN pip3 install kubernetes
RUN pip3 install PTable
RUN git clone https://github.com/cyberark/KubiScan.git /KubiScan
RUN echo "alias kubiscan='python3 /KubiScan/KubiScan.py'" > /root/.bash_aliases

# krew
ADD https://github.com/kubernetes-sigs/krew/releases/latest/download/krew-linux_amd64.tar.gz /tmp
RUN cd /tmp && tar zxvf /tmp/krew-linux_amd64.tar.gz && ./krew-linux_amd64 install krew
RUN echo 'export PATH="${PATH}:${HOME}/.krew/bin"' >> /root/.bashrc

# raccess
# /bin/bash -i to load path from .bashrc
RUN /bin/bash -ci 'kubectl krew install access-matrix'

# Networking tools and stuff
RUN apt update && DEBIAN_FRONTEND=noninteractive apt -y install wget vim nmap less arp-scan curl \
	dnsutils dsniff iproute2 iputils-ping jq net-tools netcat-traditional \
	openssh-client procps socat tcpdump traceroute libcap2-bin smbclient \
	libnfs-utils docker.io

# kube-hunter
RUN pip3 install kube-hunter

# kube bench
COPY --from=aquasec/kube-bench:latest /usr/local/bin/kube-bench /usr/local/bin/kube-bench

# kube score
COPY --from=zegl/kube-score:latest /kube-score /usr/bin/kube-score
