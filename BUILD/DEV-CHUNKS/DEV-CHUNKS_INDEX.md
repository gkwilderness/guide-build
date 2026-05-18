# 📂 DEV-CHUNKS

## Subfolders

- 📂 [[templates/templates_INDEX|templates]]

## Notes

```dataview
TABLE WITHOUT ID file.link AS "Note", file.mtime AS "Modified"
FROM "BUILD/DEV-CHUNKS"
WHERE file.name != this.file.name
SORT file.name ASC
```