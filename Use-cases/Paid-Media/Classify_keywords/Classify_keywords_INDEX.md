# 📂 Classify_keywords

## Notes

```dataview
TABLE WITHOUT ID file.link AS "Note", file.mtime AS "Modified"
FROM "Use-cases/Paid-Media/Classify_keywords"
WHERE file.name != this.file.name
SORT file.name ASC
```