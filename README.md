# Event-Driven Identity Provisioning Pipeline

## 🎯 Goal

Ingest an HR-style webhook request and automatically provision a user in Microsoft Entra ID using an event-driven Azure architecture.




## Future Enhancements

- Store Jira API credentials in Azure Key Vault and retrieve them at runtime using Managed Identity.
- Replace simulated Jira callbacks with real Jira REST API interactions (issue comments and status transitions).
- Simplify the webhook contract so Jira sends only the ticket identifier; the Azure Function will enrich the request by querying Jira for user details before queuing the provisioning request.
- Introduce dead-letter queue handling for failed provisioning attempts.
- Add idempotency safeguards to prevent duplicate user creation.