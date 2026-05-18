# 📂 Agents

## Subfolders

- 📂 [[Personal/Personal_INDEX|Personal]]

## Notes

```dataview
TABLE WITHOUT ID file.link AS "Note", file.mtime AS "Modified"
FROM "Agents"
WHERE file.name != this.file.name
SORT file.name ASC
```