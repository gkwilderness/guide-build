# 📂 BUILD

## Subfolders

- 📂 [[DEV-CHUNKS/DEV-CHUNKS_INDEX|DEV-CHUNKS]]

## Notes

```dataview
TABLE WITHOUT ID file.link AS "Note", file.mtime AS "Modified"
FROM "BUILD"
WHERE file.name != this.file.name
SORT file.name ASC
```