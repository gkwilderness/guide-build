# 📂 Templates

## Subfolders

- 📂 [[Projects/Projects_INDEX|Projects]]

## Notes

```dataview
TABLE WITHOUT ID file.link AS "Note", file.mtime AS "Modified"
FROM "Use-cases/Templates"
WHERE file.name != this.file.name
SORT file.name ASC
```