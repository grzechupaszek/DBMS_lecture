# Running SQLite Shell

## Open the database

```bash
sqlite3 /workspaces/DBMS_lecture/backend/movies.db
```

## Useful shell commands

| Command | Description |
|---|---|
| `.tables` | List all tables |
| `.schema TableName` | Show CREATE statement for a table |
| `.headers on` | Show column names in results |
| `.mode column` | Align output in columns |
| `.quit` | Exit the shell |

## Recommended startup sequence

```sql
.headers on
.mode column
```

## Split terminal in VSCode

`Ctrl+Shift+5` — opens a second terminal panel side by side.
