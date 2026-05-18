# 📂 Specifications

## Notes

```dataview
TABLE WITHOUT ID file.link AS "Note", file.mtime AS "Modified"
FROM "Use-cases/Apex/Specifications"
WHERE file.name != this.file.name
SORT file.name ASC
```