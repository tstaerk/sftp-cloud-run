# Use Ubuntu latest as the base image
# test
FROM ubuntu:latest

# Avoid prompts from apt
ENV DEBIAN_FRONTEND=noninteractive

# Update packages and install OpenSSH Server and vim
RUN apt-get update && \
    apt-get install -y openssh-server vim && \
    rm -rf /var/lib/apt/lists/*

# Set up user for SFTP with no shell login
RUN useradd -m -d /home/sftpuser -s /usr/sbin/nologin sftpuser && \
    mkdir -p /home/sftpuser/.ssh && \
    chown sftpuser:sftpuser /home/sftpuser/.ssh && \
    chmod 700 /home/sftpuser/.ssh

# Put the public key
# Replace with your public key
RUN echo "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDiLjVdEPdCFZcWdROCEGFOA8ABlWXH4jxNslyFSOJ78Ug+OSCrZPu6Us+CPA6MkcZ439QivYYbqebzAnBvJSFoKqChovJGQ4ceYdLZlQVGs6U6yFgF6yr6IlobcF6Czww0fSXjzul4pXx0nNt9pd0BBMzKv7szUCQDMxPBKB35J/DZU5ArkeNhvGOpHYc774hDa2tdZVql3gM5aHXIZH4ABlVqjiIWOXSn03X5ks9w5ZtTgtOJ365uivWdCOhMtDjmSYiHJIbilioxwCe+7ZOy41MF+jfw+Li1Ru52pnC21gboHnJmSl+mkRaQl5HGqdZFIk0mZOHN8BfYllA5FvyQemdgy80HohCWUPTDDf6Gqjj/BRLe1Ab/KYuKNhKToR0BCQCALQAsFheqDcPRaimy9ADOxovEjIEwWDyl6hLE9oU/bmL5pxL5IqmILR2NLgLmc5mzSMsX4TrmIUB0QQ5oRfJANGNCI+diPNWjTmL/fc87zjlcS/Oz6HxS5F7rgRc= thorsten@tweedleburg" > /home/sftpuser/.ssh/authorized_keys

# Set permissions for the public key
RUN chmod 600 /home/sftpuser/.ssh/authorized_keys && \
    chown sftpuser:sftpuser /home/sftpuser/.ssh/authorized_keys

# Create a directory for SFTP that the user will have access to
RUN mkdir -p /home/sftpuser/sftp/upload && \
    chown root:root /home/sftpuser /home/sftpuser/sftp && \
    chmod 755 /home/sftpuser /home/sftpuser/sftp && \
    chown sftpuser:sftpuser /home/sftpuser/sftp/upload && \
    chmod 755 /home/sftpuser/sftp/upload

# Configure SSH for SFTP
RUN mkdir -p /run/sshd && \
    echo "Match User sftpuser" >> /etc/ssh/sshd_config && \
    echo "    ChrootDirectory /home/sftpuser/sftp" >> /etc/ssh/sshd_config && \
    echo "    ForceCommand internal-sftp" >> /etc/ssh/sshd_config && \
    echo "    PasswordAuthentication no" >> /etc/ssh/sshd_config && \
    echo "    PubkeyAuthentication yes" >> /etc/ssh/sshd_config && \
    echo "    PermitTunnel no" >> /etc/ssh/sshd_config && \
    echo "    AllowAgentForwarding no" >> /etc/ssh/sshd_config && \
    echo "    AllowTcpForwarding no" >> /etc/ssh/sshd_config && \
    echo "    X11Forwarding no" >> /etc/ssh/sshd_config

# Expose the SSH port
EXPOSE 22

# Run SSHD on container start
CMD ["/usr/sbin/sshd", "-D", "-e"]
