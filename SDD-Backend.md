---
description: Java 17 backend SDD architecture and coding standards
alwaysApply: true
---

# SDD Backend Standards (Java 17)

## Rule Strength
- The terms `MUST`, `MUST NOT`, and `SHOULD` are normative for all new code.
- If a legacy file is touched, apply these rules to the touched scope when feasible.

## Scope Policy
- New code MUST follow this rule set fully.
- Legacy code MAY remain as is unless it is being changed.
- When editing legacy endpoints, you SHOULD migrate contracts to DTOs in the same change when low risk.

## Package and Layer Structure
- Flow MUST be: Controller -> IService -> IDAO.
- Packages SHOULD follow:
  - `controller`
  - `service` (interfaces)
  - `service/impl` (implementations)
  - `dao` (interfaces)
  - `dao/impl` (implementations)
  - `dto`
  - `model`
  - `mapper`
- Controllers MUST orchestrate request/response only.
- Business rules MUST stay in service layer.
- Data access MUST stay in DAO layer.

## Naming Conventions
- Service interfaces MUST match `I[A-Z].*Service`.
- Service implementations MUST match `[A-Z].*Service`.
- DAO interfaces MUST match `I[A-Z].*DAO`.
- DAO implementations MUST match `[A-Z].*DAO`.
- New model classes MUST match `[A-Z].*Model` and file name `ClassNameModel.java`.
- New controller DTOs MUST match:
  - `[A-Z].*RequestDTO`
  - `[A-Z].*ResponseDTO`
- Legacy names MAY remain unchanged unless business requirements demand renaming.

## DTO and Validation Rules
- New controller methods MUST use DTOs for request and response contracts.
- Controllers MUST NOT expose `*Model` directly in new endpoints.
- Request DTOs MUST use `jakarta.validation` annotations.
- Controller DTO parameters MUST use `@Valid`.
- Validation and contract errors SHOULD return i18n-based messages.

## Java 17 and Lombok Rules
- Code MUST target Java 17.
- `var` SHOULD be used only when inferred type is immediately obvious.
- Lombok SHOULD be used to reduce boilerplate (`@Getter/@Setter`, `@Data` when appropriate, constructors).
- `@Builder(toBuilder = true)` SHOULD be used when copy/mutation flow is required.

## Logging and i18n Rules
- Application logs MUST use SLF4J (`@Slf4j` or logger field).
- Error logs MUST include operation context (entity id, action, reason) without sensitive data.
- User-facing messages MUST use i18n keys (no hardcoded user-facing text).
- Message bundles MUST be maintained in `src/main/resources/i18n/messages*.properties`.
- i18n key format SHOULD be `domain.entity.action.error`.

## Persistence and Mapping Rules
- DAO implementations MUST use `JdbcTemplate` by default.
- Query result conversion MUST use dedicated Mapper classes.
- Mappers MUST NOT contain business rules.
- SQL MUST remain in DAO layer.
- SQL MUST NOT interpolate user input directly (use parameters).

## Reporting Rules
- Jasper templates MUST be stored under `src/main/resources/reports`.
- Report names SHOULD be centralized via constants/configuration.

## Forbidden Patterns
- Controller MUST NOT inject or call DAO directly.
- Controller MUST NOT return `*Model` in new endpoints.
- DAO MUST NOT implement business rules.
- Service MUST NOT bypass DAO for persistence code.
- Hardcoded user-facing strings MUST NOT be introduced.

## Definition of Done (DoD) for New Endpoints
- Request/response classes follow `*RequestDTO`/`*ResponseDTO`.
- Request DTO uses `jakarta.validation`; controller uses `@Valid`.
- Controller calls service only; service calls DAO.
- DAO uses `JdbcTemplate` and dedicated Mapper.
- Logs include contextual data and avoid sensitive content.
- User-facing messages are i18n key based.
- Model naming follows `ClassNameModel.java`.

## SDD Spec Minimum (Required Before Coding)
- Each implementation ticket MUST define:
  - Problem statement
  - Scope in/out
  - API contract changes (request/response/status codes)
  - Business rules and edge cases
  - Persistence impact (tables/queries/indexes)
  - i18n keys to add/change
  - Report impact in `src/main/resources/reports` (if any)
- If any item is unknown, the ticket MUST record assumptions before implementation.

## Acceptance Criteria Pattern
- Each feature MUST include at least:
  - Happy path criterion
  - Validation failure criterion
  - Authorization/security criterion (when applicable)
  - Data persistence criterion
  - Observability criterion (expected logs/metrics)
- Criteria SHOULD be testable in Given/When/Then style.

## Traceability Rules
- PR description MUST map each acceptance criterion to:
  - Code location
  - Test case name
- New i18n keys SHOULD be listed in PR notes for review.
- DB changes MUST reference migration script name under `src/main/resources/db/migration`.

## Testing Strategy Rules
- New service behavior MUST have unit tests for business rules.
- New controller contracts MUST have integration tests for validation and HTTP status behavior.
- DAO query changes SHOULD include integration tests against the test database profile.
- Bug fixes MUST include a regression test reproducing the previous failure.

## API Compatibility and Versioning
- Public endpoint breaking changes MUST NOT be introduced without explicit versioning or approved migration plan.
- DTO field removals/renames MUST include backward-compatibility assessment in the spec.
- New optional fields SHOULD be additive and backward compatible by default.

## Security and Privacy Rules
- Sensitive fields (passwords, tokens, personal ids) MUST NOT be logged.
- Input from external clients MUST be validated before business processing.
- SQL access MUST be parameterized and MUST NOT concatenate untrusted input.
- Authorization checks MUST be explicit for protected operations.

## Performance and Reliability
- Specs SHOULD define expected query cardinality and pagination behavior.
- Endpoints returning collections SHOULD require pagination for large datasets.
- Expensive operations SHOULD include timeout/retry strategy when calling external services.
- Failure handling MUST return consistent business error responses with i18n keys.

## Rollout and Migration Policy
- DB schema changes MUST be delivered via migration scripts, never manual production edits.
- Behavior-changing features SHOULD include rollback notes in PR description.
- Legacy-to-SDD migrations SHOULD be incremental by touched module, not big-bang refactors.

## Bad vs Good Examples

### Controller contract
```java
// BAD
@PostMapping("/save")
public ResponseEntity<UserModel> save(@Valid @RequestBody UserModel model) {
    return ResponseEntity.ok(userService.save(model));
}

// GOOD
@PostMapping("/save")
public ResponseEntity<UserResponseDTO> save(@Valid @RequestBody UserRequestDTO request) {
    return ResponseEntity.ok(userService.save(request));
}
```

### DTO naming
```java
// BAD
public class SaveUserDTO {}

// GOOD
public class UserRequestDTO {}
public class UserResponseDTO {}
```

### Validation in DTO
```java
// BAD
public class UserRequestDTO {
    private String email;
}

// GOOD
public class UserRequestDTO {
    @NotBlank
    @Email
    private String email;
}
```

### Layering
```java
// BAD
@RestController
public class UserController {
    @Autowired
    private IUserDAO userDAO;
}

// GOOD
@RestController
public class UserController {
    private final IUserService userService;
}
```

### Service and DAO naming
```java
// BAD
public interface UserService {}
public interface UserRepository {}

// GOOD
public interface IUserService {}
public class UserService implements IUserService {}
public interface IUserDAO {}
public class UserDAO implements IUserDAO {}
```

### Forbidden direct DAO usage in controller
```java
// BAD
@RestController
public class UserController {
    private final IUserDAO userDAO;
}

// GOOD
@RestController
public class UserController {
    private final IUserService userService;
}
```

### JdbcTemplate with Mapper
```java
// BAD
List<Map<String, Object>> rows = jdbcTemplate.queryForList(sql);

// GOOD
return jdbcTemplate.query(sql, params, new UserMapper());
```

### Logging with context
```java
// BAD
log.error("Error");

// GOOD
log.error("Failed to save user. userId={}, email={}", userId, request.getEmail(), ex);
```

### i18n messages
```java
// BAD
throw new BusException("User not found");

// GOOD
throw new BusException(messageSource.getMessage("error.user.notFound", null, locale));
```

### Model naming
```java
// BAD
public class User {}

// GOOD
public class UserModel {}
```

### Java 17 var usage
```java
// BAD (type not obvious)
var result = service.process(a, b, c);

// GOOD (type obvious)
var users = new ArrayList<UserModel>();
```
