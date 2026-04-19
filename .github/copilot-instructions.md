# Copilot Workspace Instructions

This repository uses the SDD documents as the source of truth.

- For frontend work, always follow [SDD-Frontend.md](../SDD-Frontend.md).
- For backend work, always follow [SDD-Backend.md](../SDD-Backend.md).
- Treat `MUST` and `MUST NOT` as mandatory.
- If a request is missing required implementation details, first identify the missing assumptions before coding.
- Prefer incremental changes that preserve existing behavior unless the user explicitly asks for a refactor.
- Keep UI, service, API client, DTO, validation, logging, and i18n rules aligned with the SDD.
- When touching frontend code, use the component -> service -> API client flow and avoid direct API calls from components.
- When touching backend code, use the controller -> service -> DAO flow and avoid direct data access from controllers.

If the user asks for a change in this workspace, apply the relevant SDD automatically without asking them to restate it.