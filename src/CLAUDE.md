# Code conventions for this project's `src/`

This file applies when Claude is working in `product-master-data-model/src/`.

## Style

- Match the existing code style. If there's a linter config, follow it strictly.
- New files mirror the structure of nearby existing files.
- No mixing of paradigms inside a module without a reason worth stating in DECISIONS.md.

## Naming

- dbt models: snake_case, prefixed by layer (`stg_`, `int_`, `dim_`, `fct_`)
- SQL columns: snake_case nouns
- Python functions: verbs (`parse_config`, `fetch_records`)
- Avoid abbreviations unless they're GS1-standard (`gtin`, `sscc`, `gdsn`)

## Imports

- Sort imports: external first, then internal absolute, then relative.
- No unused imports left in code.

## Comments

- Comment why, not what. The code already says what.
- TODO comments include a date or issue reference.

## Tests

- dbt tests: not_null, unique, accepted_values on every key column
- Each new non-trivial Python function gets at least one test in `tests/`
- Test names describe behavior in plain English

## Error handling

- Don't swallow errors. If you catch one, log or rethrow with context.
- No bare `except:` blocks without comment explaining why.

## Don't invent

- Before adding a new utility, check if a similar one already exists.
- Before adding a dependency, ask the user (and log to DECISIONS.md).
- Before refactoring an existing pattern, surface it as a question, not a fait accompli.

## When stuck

- Smallest reproducer.
- One change at a time.
- Run the test, read the actual output (not what you expected).
