# 📂 Specs

## Notes

```dataview
TABLE WITHOUT ID file.link AS "Note", file.mtime AS "Modified"
FROM "Specs"
WHERE file.name != this.file.name
SORT file.name ASC
```