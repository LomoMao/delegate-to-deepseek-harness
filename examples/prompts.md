# Example prompts

## Small implementation

```text
Use $delegate-to-deepseek-harness to implement the missing CSV export in reports/.
Do not change the public API. After the worker finishes, review the diff and run the focused tests yourself.
```

## Mechanical migration

```text
Use $delegate-to-deepseek-harness for the repetitive migration from oldConfig() to loadConfig().
Keep behavior unchanged and do not touch generated files. Verify with the existing test suite afterward.
```

## Read-heavy exploration

```text
Use $delegate-to-deepseek-harness to trace how session state reaches the persistence layer.
Ask the worker for file/line evidence. Do not make edits; summarize and cross-check the result yourself.
```
