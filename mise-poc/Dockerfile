# POC base: Debian trixie (matches the primary servers) with mise + chezmoi baked
# in so iteration is fast. The actual provisioning is driven by `mise bootstrap`
# against the mounted config, NOT by this Dockerfile.
FROM debian:trixie

# Minimal prereqs to fetch + run mise/chezmoi and let mise drive apt itself.
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        ca-certificates curl sudo git \
    && rm -rf /var/lib/apt/lists/*

# A non-root user that mimics the real "server_user" (has passwordless sudo so
# mise bootstrap tasks can shell out to apt/systemctl like they would on a host).
ARG USER=riku
RUN useradd -m -s /bin/bash "$USER" \
    && echo "$USER ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/$USER

USER ${USER}
ENV USER=${USER}
WORKDIR /home/${USER}

# Install mise (user-local) and chezmoi.
RUN curl -fsSL https://mise.run | sh
ENV PATH="/home/${USER}/.local/bin:${PATH}"
RUN curl -fsSL get.chezmoi.io | sh -s -- -b /home/${USER}/.local/bin

# The POC mise config is mounted at run time to /home/$USER/.config/mise/config.toml
CMD ["bash"]
