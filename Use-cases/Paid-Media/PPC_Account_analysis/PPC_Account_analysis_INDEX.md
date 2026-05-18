# 📂 PPC_Account_analysis

## Notes

```dataview
TABLE WITHOUT ID file.link AS "Note", file.mtime AS "Modified"
FROM "Use-cases/Paid-Media/PPC_Account_analysis"
WHERE file.name != this.file.name
SORT file.name ASC
```