# 📂 personal

## Notes

```dataview
TABLE WITHOUT ID file.link AS "Note", file.mtime AS "Modified"
FROM "BUILD/DEV-CHUNKS/templates/personal"
WHERE file.name != this.file.name
SORT file.name ASC
```