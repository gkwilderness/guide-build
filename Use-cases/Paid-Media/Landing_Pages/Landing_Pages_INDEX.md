# 📂 Landing_Pages

## Notes

```dataview
TABLE WITHOUT ID file.link AS "Note", file.mtime AS "Modified"
FROM "Use-cases/Paid-Media/Landing_Pages"
WHERE file.name != this.file.name
SORT file.name ASC
```