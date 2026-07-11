# OpenWorld VPN — Infrastructure

Infrastructure configuration used to build, deploy, and run OpenWorld VPN.

## Structure

```
infrastructure/
├── docker/        # Dockerfiles and container build configuration
├── deployment/    # Deployment manifests (Kubernetes, Terraform, Compose, etc.)
└── vpn-server/    # VPN server provisioning and configuration
```

## Module Overview

- **docker** — Dockerfiles and related container build configuration for the backend,
  admin dashboard, and supporting services.
- **deployment** — Deployment manifests and infrastructure-as-code for staging and
  production environments.
- **vpn-server** — Configuration and provisioning scripts for OpenVPN/WireGuard server
  nodes. Real VPN server functionality is not implemented yet.

## Status

This is a placeholder scaffold. No production secrets or real deployment
configuration are included.
