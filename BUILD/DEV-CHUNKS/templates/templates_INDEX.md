# 📂 templates

## Subfolders

- 📂 [[personal/personal_INDEX|personal]]

## Notes

```dataview
TABLE WITHOUT ID file.link AS "Note", file.mtime AS "Modified"
FROM "BUILD/DEV-CHUNKS/templates"
WHERE file.name != this.file.name
SORT file.name ASC
```