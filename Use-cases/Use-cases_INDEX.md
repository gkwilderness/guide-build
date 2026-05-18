# 📂 Use-cases

## Subfolders

- 📂 [[_META/_META_INDEX|_META]]
- 📂 [[_Notes/_Notes_INDEX|_Notes]]
- 📂 [[Apex/Apex_INDEX|Apex]]
- 📂 [[CapitalCore/CapitalCore_INDEX|CapitalCore]]
- 📂 [[Lead_Quality_Engineering/Lead_Quality_Engineering_INDEX|Lead_Quality_Engineering]]
- 📂 [[Library/Library_INDEX|Library]]
- 📂 [[Paid-Media/Paid-Media_INDEX|Paid-Media]]
- 📂 [[SEO/SEO_INDEX|SEO]]
- 📂 [[Templates/Templates_INDEX|Templates]]

## Notes

```dataview
TABLE WITHOUT ID file.link AS "Note", file.mtime AS "Modified"
FROM "Use-cases"
WHERE file.name != this.file.name
SORT file.name ASC
```