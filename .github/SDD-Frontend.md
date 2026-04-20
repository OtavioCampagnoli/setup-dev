---
description: Frontend SDD architecture and coding standards
alwaysApply: true
---

# SDD Frontend Standards (Angular + TypeScript)

## Rule Strength
- The terms `MUST`, `MUST NOT`, and `SHOULD` are normative for all new code.
- If a legacy file is touched, apply these rules to the touched scope when feasible.

## Scope Policy
- New code MUST follow this rule set fully.
- Legacy code MAY remain as is unless it is being changed.
- When editing legacy screens, you SHOULD migrate contracts to DTO classes (or interfaces when required) in the same change when low risk.

## Package and Layer Structure
- Flow MUST be: Component -> Service -> API Client.
- Packages SHOULD follow:
  - `components`
  - `pages`
  - `services`
  - `api` (HTTP clients)
  - `dto`
  - `model`
  - `mapper`
  - `guards`
  - `interceptors`
- Components MUST orchestrate request/response and UI interaction only.
- Business rules MUST stay in service layer.
- Data access MUST stay in API client layer.

## Naming Conventions
- Service classes MUST match `[A-Z].*Service`.
- API client classes MUST match `[A-Z].*ApiClient`.
- New model classes MUST match `[A-Z].*Model` and file name `ClassNameModel.ts`.
- New component DTO classes MUST match:
  - `*RequestDTO`
  - `*ResponseDTO`
- Interfaces MAY be used when required by framework contracts or polymorphic design, but class SHOULD be preferred first.
- Legacy names MAY remain unchanged unless business requirements demand renaming.

## DTO and Validation Rules
- New component/service methods MUST use DTO classes for request and response contracts.
- Components MUST NOT expose or consume raw `*Model` contracts directly in new flows.
- Request DTOs MUST be validated in forms using Angular validators.
- Component DTO parameters MUST be validated before submission.
- Validation and contract errors SHOULD use i18n-based messages.

## Class vs Interface Preference
- New domain and contract types SHOULD be authored as `class` first.
- `interface` SHOULD be used only when there is a concrete need (framework constraint, declaration merging, or multiple implementations).
- If both are viable, MUST prefer `class`.

## TypeScript and Angular Rules
- Code MUST target Angular 14 and the TypeScript version compatible with Angular 14 in this project configuration.
- `var` MUST NOT be used in frontend code.
- `const` SHOULD be used by default; use `let` only when reassignment is required.
- Angular standalone components and typed forms SHOULD be used when feasible.
- RxJS subscriptions in components MUST be properly cleaned up.

## RxJS Reactive Patterns
- Features with async workflows SHOULD prefer RxJS stream composition over imperative callback chains.
- Request trigger sources (submit, filters, pagination, route params) SHOULD be modeled as streams and composed with operators.
- In Angular 14 projects, components MUST use `takeUntil` + `Subject<void>` (or an equivalent Angular 14-compatible lifecycle pattern) when manual `subscribe` is required.
- Components SHOULD prefer template `async` pipe for rendering Observable state instead of imperative assignment.
- API calls from UI-triggered streams MUST use the correct flattening operator:
  - `switchMap` for latest-only interactions (search, filters, route changes)
  - `concatMap` for ordered queued operations
  - `exhaustMap` to ignore re-entrancy during in-flight submission
  - `mergeMap` only when safe parallelism is intentional
- Streams with side effects MUST centralize error handling using `catchError` and return a safe fallback stream.
- Reused derived streams SHOULD use `shareReplay({ bufferSize: 1, refCount: true })` to avoid duplicate HTTP calls.
- Service APIs SHOULD return `Observable<...>` and avoid converting to Promise unless required by an external contract.
- Nested `subscribe` calls MUST NOT be introduced.
- User-facing stream errors MUST map to i18n keys and consistent UI state (loading/success/error).

## Logging and i18n Rules
- Application errors MUST be handled consistently in services/interceptors.
- Error logs MUST include operation context (feature, action, reason) without sensitive data.
- User-facing messages MUST use i18n keys (no hardcoded user-facing text).
- i18n message files MUST be maintained in the frontend i18n location.
- i18n key format SHOULD be `domain.entity.action.error`.

## Persistence and Mapping Rules
- API client implementations MUST use Angular `HttpClient` by default.
- API response conversion MUST use dedicated Mapper classes/functions.
- Mappers MUST NOT contain business rules.
- HTTP endpoint definitions MUST remain in API client layer.
- Request construction MUST NOT interpolate untrusted user input directly.

## Forbidden Patterns
- Component MUST NOT inject or call API clients directly when service abstraction exists.
- Component MUST NOT return or render `*Model` contracts directly in new flows.
- API client MUST NOT implement business rules.
- Service MUST NOT bypass API client for remote data access.
- Hardcoded user-facing strings MUST NOT be introduced.

## Definition of Done (DoD) for New Features
- Request/response classes follow `*RequestDTO`/`*ResponseDTO`.
- Request DTO is validated in forms before submission.
- Component calls service only; service calls API client.
- API client uses `HttpClient` and dedicated Mapper.
- Errors include contextual data and avoid sensitive content.
- User-facing messages are i18n key based.
- Model naming follows `ClassNameModel.ts`.

## SDD Spec Minimum (Required Before Coding)
- Each implementation ticket MUST define:
  - Problem statement
  - Scope in/out
  - UI contract changes (request/response/states/navigation)
  - Business rules and edge cases
  - API impact (endpoints/payloads/status codes)
  - i18n keys to add/change
  - Report/dashboard impact (if any)
- If any item is unknown, the ticket MUST record assumptions before implementation.

## Acceptance Criteria Pattern
- Each feature MUST include at least:
  - Happy path criterion
  - Validation failure criterion
  - Authorization/security criterion (when applicable)
  - Data/API integration criterion
  - Observability criterion (expected logs/metrics)
- Criteria SHOULD be testable in Given/When/Then style.

## Traceability Rules
- PR description MUST map each acceptance criterion to:
  - Code location
  - Test case name
- New i18n keys SHOULD be listed in PR notes for review.
- API contract changes MUST be listed in PR notes for QA validation.

## Testing Strategy Rules
- New service behavior MUST have unit tests for business rules.
- New component contracts MUST have integration tests for validation and UI status behavior.
- API client changes SHOULD include integration tests against the test environment profile.
- Bug fixes MUST include a regression test reproducing the previous failure.

## API Compatibility and Versioning
- Public UI/API contract breaking changes MUST NOT be introduced without explicit versioning or approved migration plan.
- DTO field removals/renames MUST include backward-compatibility assessment in the spec.
- New optional fields SHOULD be additive and backward compatible by default.

## Security and Privacy Rules
- Sensitive fields (passwords, tokens, personal ids) MUST NOT be logged.
- Input from external users MUST be validated before business processing.
- API access MUST use safe parameter handling and MUST NOT concatenate untrusted input into URLs unsafely.
- Authorization checks MUST be explicit for protected routes/actions.

## Performance and Reliability
- Specs SHOULD define expected list sizes and pagination behavior.
- Screens returning large collections SHOULD require pagination or lazy loading.
- Expensive operations SHOULD include timeout/retry strategy when calling external services.
- Failure handling MUST return consistent business error responses with i18n keys.
- Retry behavior SHOULD be explicit (`retry`/`retryWhen` with bounded attempts and backoff) and MUST NOT retry non-idempotent operations blindly.

## Rollout and Migration Policy
- Behavior-changing features SHOULD include rollback notes in PR description.
- Legacy-to-SDD migrations SHOULD be incremental by touched module, not big-bang refactors.

## Bad vs Good Examples

### Component contract
```typescript
// BAD
submit(model: UserModel) {
  return this.userService.save(model);
}

// GOOD
submit(request: UserRequestDTO) {
  return this.userService.save(request);
}
```

### DTO naming
```typescript
// BAD
export interface SaveUserDTO {}

// GOOD
export class UserRequestDTO {}
export class UserResponseDTO {}
```

### Validation in DTO/Form
```typescript
// BAD
export interface UserRequestDTO {
  email: string;
}

// GOOD
this.form = this.fb.group({
  email: ['', [Validators.required, Validators.email]]
} as const);
```

### Layering
```typescript
// BAD
export class UserComponent {
  constructor(private userApiClient: UserApiClient) {}
}

// GOOD
export class UserComponent {
  constructor(private userService: UserService) {}
}
```

### Service and API naming
```typescript
// BAD
export class UserHandler {}
export class UserRepository {}

// GOOD
export class UserService {}
export class UserApiClient {}
```

### Forbidden direct API usage in component
```typescript
// BAD
export class UserComponent {
  constructor(private userApiClient: UserApiClient) {}
}

// GOOD
export class UserComponent {
  constructor(private userService: UserService) {}
}
```

### HttpClient with Mapper
```typescript
// BAD
return this.http.get('/api/users');

// GOOD
return this.http
  .get<UserResponseDTO[]>('/api/users')
  .pipe(map(rows => rows.map(UserMapper.toModel)));
```

### Logging with context
```typescript
// BAD
console.error('Error');

// GOOD
this.logger.error('Failed to save user', { userId, action: 'saveUser', reason: err?.message });
```

### i18n messages
```typescript
// BAD
this.toast.error('User not found');

// GOOD
this.toast.error(this.translate.instant('error.user.notFound'));
```

### Model naming
```typescript
// BAD
export interface User {}

// GOOD
export class UserModel {}
```

### TypeScript const usage
```typescript
// BAD
let users = [];

// GOOD
const users: UserModel[] = [];
```

### RxJS flattening operators
```typescript
// BAD
this.searchControl.valueChanges.subscribe(term => {
  this.userService.search(term).subscribe(users => (this.users = users));
});

// GOOD
readonly users$ = this.searchControl.valueChanges.pipe(
  debounceTime(300),
  distinctUntilChanged(),
  switchMap(term => this.userService.search(term)),
  catchError(() => of([]))
);
```

### Submission flow and cleanup
```typescript
// BAD
submit() {
  this.userService.save(this.form.value).subscribe();
}

// GOOD
readonly submit$ = new Subject<UserRequestDTO>();
private readonly destroy$ = new Subject<void>();

ngOnInit() {
  this.submit$
    .pipe(
      exhaustMap(request => this.userService.save(request)),
      takeUntil(this.destroy$)
    )
    .subscribe();
}

ngOnDestroy() {
  this.destroy$.next();
  this.destroy$.complete();
}
```
