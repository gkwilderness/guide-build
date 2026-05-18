# 📂 __META

## Notes

```dataview
TABLE WITHOUT ID file.link AS "Note", file.mtime AS "Modified"
FROM "__META"
WHERE file.name != this.file.name
SORT file.name ASC
```