# Hub-Spoke Secure Network Architecture

This project implements a hub-spoke network topology in Azure.

## Design goals
- Centralized security and routing
- Workload isolation
- Scalable spoke onboarding

## Components
- Hub VNet: shared services and security
- Spoke VNets: application and data workloads
- VNet Peering: hub ↔ spokes

## Security considerations
- Traffic inspection is centralized
- Spokes have no direct peering between them
