---
title: "Cleaning up Phrase Match"
type: project
area: wilderness
project: "Wilderness"
status: active
---
Absolutely. Here’s a focused strategy to improve traffic quality, clean up long-tail phrase match spillover, and automate it with ChatGPT.

---

## 1. **Improving Traffic Quality from Phrase Match**

Phrase match can balloon with irrelevant long-tail traffic. To tighten quality:

### a. **Refine Match Type Strategy**

- **Reintroduce Exact Match** for high-intent, converting queries.
    
- Use **Broad Match Modified (BMM)-style** structure with phrase match to guide intent. E.g., `"luxury safari"+"botswana"` rather than `"luxury safari botswana"`.
    

### b. **Use Intent-Based Keyword Grouping**

- Group keywords by **buyer intent** and separate them from **information-seeking** terms.
    
- Create ad copy and landing pages that repel non-buyers. E.g., mention price or exclusivity early in copy.
    

### c. **Leverage IF Functions in Ads**

Tailor copy to show different messages to known converting audiences vs new ones.

---

## 2. **Cleaning Up Phrase Match Long-Tail Junk**

### a. **Build a Negative Keyword Mining Workflow**

1. **Segment by Search Query Length**  
    Long queries (6+ words) tend to be low intent unless they're transactional. Pull SQRs by length.
    
2. **Pattern Detection**  
    Look for junk phrases like:
    
    - "cheap", "free", "how to", "definition", "jobs", "photos", "blog", "review", "comparison"
        
3. **Search Category Mapping**  
    Map search queries to categories (travel, jobs, blog, education) using rules or classification models.
    

### b. **Develop Negative Keyword Themes**

Use regex or keyword clustering to build scalable negative lists:

- Informational: `"how to"`, `"best way to"`, `"meaning of"`
    
- Price sensitivity: `"cheap"`, `"budget"`, `"affordable"`
    
- Jobs/Education: `"career"`, `"course"`, `"degree"`, `"university"`
    

---

## 3. **Automate Cleanup Using ChatGPT**

You can turn ChatGPT into your SQR janitor.

### a. **Automated Negative Keyword Extraction (ChatGPT Prompt)**

Paste in your SQR data and use this:

**Prompt:**

> You are a PPC expert. Below is a list of search terms triggering our ads. Identify and return a clean list of negative keyword themes based on low-intent or irrelevant traffic patterns (e.g., jobs, definitions, how-to, free stuff, blogs, etc.). Return your answer as a list of suggested negative keywords and their inferred theme.

_(Attach: CSV with search terms, impressions, clicks, conversions)_

**Optional Output Prompt:**

> Format the results into a two-column table:  
> | Negative Keyword | Theme |

### b. **Automated SQR Categorizer in Python + GPT**

For deeper automation:

1. Export search queries.
    
2. Feed each query into GPT with this prompt:
    
    > Classify this query as one of: “High Intent,” “Informational,” “Price Sensitive,” “Jobs/Education,” “Other.” Output just the label.
    
3. Filter anything not "High Intent" and dump themes into your negatives.
    

I can give you a script if you're using Python + OpenAI API.

---

## 4. **Bonus – Quality Scoring with GPT**

Ask GPT to **score** each SQR (0–10) based on buying intent, like this:

> Score this query from 0–10 based on likelihood to convert for luxury safari travel. A 0 is completely irrelevant (e.g., "safari job botswana"), 10 is a buyer (e.g., "book luxury safari botswana 2025").

Then bin and bulk-exclude anything scoring under 5.

---

## 5. **Ongoing Prevention Tactics**

- Set up **automated alerts** when CTR or CVR drops on phrase ad groups.
    
- Use **keyword insertion sparingly** — it attracts broad variants that don't match your CTA.
    
- **Weekly SQR audits**: Export, run through GPT, and update negatives in bulk.
    

---

Let me know what format your SQR data is in and I’ll build you a Python + GPT script or Sheets workflow to automate it.