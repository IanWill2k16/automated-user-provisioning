# Event-Driven Identity Provisioning Pipeline


## Overview


This project demonstrates an event-driven identity provisioning platform built on Azure. It ingests an HR-style webhook request, queues the request for reliable processing, and executes user provisioning logic using managed identities and infrastructure-as-code.


The design emphasizes loose coupling, least-privilege access, and operational safety while remaining simple enough to reason about and extend. By separating request intake from execution, the system avoids tight coupling to upstream systems and allows retries, throttling, and future producers without redesign.


---


## Architecture


**High-level flow:**


1. An external system (simulated HR / Jira webhook) sends an HTTP request to an Azure Function.
2. The Azure Function validates the request and enqueues it in Azure Storage Queue.
3. An Azure Automation Runbook polls the queue and processes provisioning requests.
4. Provisioning results are logged and a simulated callback is generated.


This separation allows ingestion, processing, and external integrations to evolve independently.


---


## Key Components


### Azure Function (Ingress)
- Receives and validates webhook payloads
- Uses Managed Identity for authentication
- Enqueues provisioning requests to Azure Storage Queue
- Returns asynchronous acceptance responses (HTTP 202)


### Azure Storage Queue
- Provides buffering and durability between systems
- Enables retry and failure isolation
- Decouples request ingestion from provisioning execution


### Azure Automation Account
- Processes queued provisioning requests
- Uses Managed Identity and RBAC for queue access
- Executes PowerShell runbooks for identity operations
- Logs execution details to Log Analytics


### Infrastructure as Code
- All infrastructure is provisioned with Terraform
- Modular design for reuse and clarity
- Remote state stored in Azure Storage
- GitHub Actions deploy infrastructure and application code using OIDC (no static credentials)


---


## Security Considerations


- No secrets are stored in source control
- Authentication uses Azure Managed Identities and OIDC
- RBAC scopes are limited to required resources
- Input validation is enforced at the API boundary


---


## Repository Structure

```
automated-user-provisioning/ 
├── function/ # Azure Function (Python) 
├── infra/ # Terraform infrastructure 
│ └── modules/ # Reusable Terraform modules 
└── .github/ # CI/CD workflows
```

---


## CI/CD


- GitHub Actions deploy infrastructure and application code
- Terraform is executed with remote state and OIDC authentication
- Function code is deployed only after infrastructure provisioning completes


---


## Current State


- Webhook ingestion and queueing implemented
- Infrastructure fully automated
- Provisioning logic stubbed for demonstration purposes
- External system callbacks currently simulated via logs


---


## Future Enhancements


- Store external API credentials in Azure Key Vault and retrieve them using Managed Identity
- Replace simulated callbacks with real Jira REST API interactions
- Enrich webhook payloads by querying external systems instead of sending full user details
- Add dead-letter queue handling for failed provisioning attempts
- Introduce idempotency safeguards to prevent duplicate user creation


---


## Purpose


This repository is intended as a reference implementation demonstrating how common identity provisioning workflows can be implemented using cloud-native, event-driven patterns with a focus on security, reliability, and maintainability.
