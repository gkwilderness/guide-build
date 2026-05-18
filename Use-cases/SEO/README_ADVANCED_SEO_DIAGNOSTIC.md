# Advanced SEO Diagnostic System — Complete Setup Guide

**Status:** ✅ Ready to Deploy
**Last Updated:** April 1, 2026
**Next Review:** April 8, 2026 (after first Monday run)

---

## What You've Built

You've created an **AI-driven SEO performance engine** that:
- Runs every Monday at 7 AM automatically
- Pulls data from GSC, GA4, and Ahrefs
- Diagnoses root causes (not just metrics)
- Quantifies opportunities by conversion value
- Generates executive-ready outputs (dashboard + report + Slack notification)
- Requires zero follow-up questions from the SEO manager

**This is your proof point for "Claude as recommendation engine for SEO at scale."** Once validated on gorilla-trekking, you can replicate it across all 6 camps and 30+ experience pages.

---

## Files Created

| File | Purpose | Location |
|------|---------|----------|
| **seo-weekly-diagnostic-SKILL.md** | Skill definition with all 5 diagnostic layers | `/Winning Wilderness (SEO)/` |
| **WEEKLY_SEO_PROMPT_TEMPLATE.md** | Step-by-step executable prompt (7 layers) | `/Winning Wilderness (SEO)/` |
| **DIAGNOSTIC_METHODOLOGY_GUIDE.md** | Interpretation guide for all metrics, benchmarks, diagnosis patterns | `/Winning Wilderness (SEO)/` |
| **README_ADVANCED_SEO_DIAGNOSTIC.md** (this file) | Setup guide + maintenance checklist | `/Winning Wilderness (SEO)/` |
| **Scheduled Task** | Runs every Monday at 7:05 AM | `/Users/admin/Documents/Claude/Scheduled/weekly-seo-diagnostic-gorilla-trekking/` |

---

## How It Works

### **Every Monday at 7:05 AM:**

The scheduled task automatically:
1. Pulls GSC metrics (last 7 days vs prior 7 days)
2. Pulls GA4 conversions (enquiry events)
3. Pulls Ahrefs SERP data + competitive analysis
4. Diagnoses root causes for any metric moves
5. Scores opportunities by conversion value
6. Generates three outputs:
   - **Dashboard HTML** → `/Winning Wilderness (SEO)/dashboards/Gorilla_Trekking_Weekly_[YYYY-MM-DD].html`
   - **Strategic Report DOCX** → `/Winning Wilderness (SEO)/performance/Gorilla_Trekking_Performance_Check_[DD-Mon-YYYY].docx`
   - **Slack Notification** → `/seo-automation/slack_gorilla.txt` (ready to copy-paste)

### **SEO Manager's Workflow:**

Every Monday morning:
1. Check `/seo-automation/slack_gorilla.txt` → copy-paste to Slack
2. Open the dashboard HTML → review KPIs, trends, opportunities
3. Open the .docx report → read executive summary + recommendations
4. Pick top 3 opportunities → assign to team
5. Track implementation through week

---

## Pre-Deployment Checklist

Before the first run on Monday, **verify these configurations:**

### **GSC Setup**
- [ ] Verify property: `sc-domain:wildernessdestinations.com`
- [ ] Check that /experiences/safari/gorilla-trekking is indexed and getting impressions
- [ ] Confirm you have Search Console access for this property

### **GA4 Setup**
- [ ] Go to GA4 Admin → Events → find "enquiry" event
- [ ] Verify it's marked as a **Key Event** (conversion)
- [ ] Check that gorilla-trekking page is tracking enquiry events
- [ ] Get GA4 property ID (G-XXXXXXXXX format) and note it
- [ ] If conversion value is not tracked per-event, note the historical average deal value (from sales)

### **Ahrefs Setup**
- [ ] Verify Ahrefs project ID: `7669662`
- [ ] Confirm your Ahrefs API key is connected
- [ ] Test: Can you pull SERP data for "gorilla trekking" keyword?

### **File Paths Setup**
- [ ] Verify `/Winning Wilderness (SEO)/performance/` exists and is writable
- [ ] Verify `/Winning Wilderness (SEO)/dashboards/` exists and is writable
- [ ] Verify `/seo-automation/` exists and is writable

### **First Run (Optional but Recommended)**
- [ ] Click "Run now" on the scheduled task to trigger it manually Monday morning
- [ ] This pre-approves all tool permissions and catches any data source issues before automation starts
- [ ] Review the outputs to ensure they match your expectations

---

## Interpreting the Outputs

### **The Dashboard (HTML)**

Open in browser. Key sections:

1. **KPI Cards** (top)
   - Shows clicks, impressions, CTR, position, enquiries, conversion rate
   - Each card shows WoW (week-over-week) % change in red/green
   - Green = metrics improved, Red = metrics declined

2. **Status Badge** (WIN / TRAFFIC ONLY / NO IMPACT / LOSS)
   - WIN: clicks up AND CTR up AND position stable/improved
   - TRAFFIC ONLY: clicks up but CTR flat/down (impression-driven, not optimization-driven)
   - NO IMPACT: flat across all metrics
   - LOSS: clicks or impressions down >10%

3. **4-Week Trend Chart**
   - Visual trend of clicks, CTR, position over 4 weeks
   - Helps spot momentum (improving or declining?)

4. **Top 15 Keywords Table**
   - Sortable by clicks, CTR, conversion value upside
   - Flagged keywords highlighted in red (opportunity)

5. **Opportunity Scorecard**
   - Ranked opportunities with conversion value uplift
   - Quick reference for which to fix first

6. **Competitive Heatmap**
   - Us vs top 5 competitors on messaging angles
   - Shows which angles we're missing

7. **Lead Funnel**
   - Sessions → Enquiries → Deal Value
   - Shows conversion drop-off points

---

### **The Report (DOCX)**

Read in order:

1. **Executive Summary** (1 paragraph)
   - Status, headline metrics, key finding, next action
   - Read this first. If the answer makes sense, you can skip the detail sections.

2. **Performance Snapshot** (Table)
   - Metrics comparison: this week vs prior week vs 4-week avg
   - Use this to assess whether moves are anomalies or trends

3. **Keyword Diagnostic** (Table + Narrative)
   - Top 15 keywords with flags for CTR/position issues
   - Which keywords are opportunities (fixable)?

4. **Root Cause Analysis** (Narrative)
   - Why each metric moved
   - Evidence for diagnosis (not guesses)
   - Skip this if you already understand the issue

5. **On-Page Diagnostic** (Table)
   - Meta, H1, word count, schema vs benchmarks
   - Quick wins identified here

6. **Competitive Positioning** (Table + Narrative)
   - What competitors do that we don't
   - Messaging gaps = quick content wins

7. **Opportunity Roadmap** (Prioritized List)
   - Top 5 ranked by $ impact + effort
   - For each: specific action, success metric, timeline, owner
   - Pick top 3 per month

---

### **The Slack Notification (Text File)**

Copy the entire contents of `/seo-automation/slack_gorilla.txt` and paste into Slack weekly channel.

Format:
- 🦍 Header with date + URL
- 📊 Headline metrics with WoW %
- 💼 Leads & revenue signal
- 🔑 Top opportunity with upside
- 🏆 Status badge + explanation
- 📈 Competitive position (1-liner)
- → Priority actions (top 3)
- Link to full dashboard & report

Post every Monday morning so team sees it in standup.

---

## Common Questions

### **Q: Can I run this manually anytime, or only Mondays?**
A: Run manually anytime by clicking "Run now" on the scheduled task. Use for troubleshooting (e.g., clicks dropped 50% mid-week).

### **Q: What if GA4 hasn't processed data yet?**
A: GA4 typically processes within 2 hours. If data is unavailable, the task will note this in the report and flag for manual investigation. Run the next day if needed.

### **Q: How do I update the page URL if I want to run this for a different experience?**
A: Edit the scheduled task prompt. Replace:
```
PAGE_URL: /experiences/safari/jao-camp
FILE_NAMES: Jao_Camp_Weekly_[...]
```
Then create a new scheduled task with a new name (e.g., `weekly-seo-diagnostic-jao-camp`).

### **Q: What if a competitor appears in top 5?**
A: The diagnostic will flag them in competitive analysis. If they stay top 5 for 2+ weeks, add them to your ongoing competitive monitoring. Consider backlink outreach or content differentiation.

### **Q: How do I scale this to all 6 camps + 30 experience pages?**
A: After validating gorilla-trekking for 4 weeks:
1. Create duplicate WEEKLY_SEO_PROMPT_TEMPLATE.md files for each page (replace PAGE_URL, GA4_CONVERSION_EVENT)
2. Create new scheduled tasks for each page (e.g., `weekly-seo-diagnostic-jao-camp`, `weekly-seo-diagnostic-tubu-tree`)
3. Consolidate outputs: Create a weekly "SEO Scorecard" that rolls up all 6 camp diagnostics into one executive summary
4. This gives you one Monday dashboard with all 30+ pages' status and top opportunities

---

## Maintenance & Updates

### **Weekly (During First Month)**
- [ ] Run the diagnostic manually if automated run fails
- [ ] Review outputs for accuracy
- [ ] Note any data source issues or edge cases

### **Monthly (After First Month)**
- [ ] Review methodology guide for accuracy
- [ ] Update seasonal baselines (if seasonality patterns change)
- [ ] Check if competitor landscape shifted (new competitors in top 5?)
- [ ] Verify GA4 conversion value is still accurate

### **Quarterly (Every 3 Months)**
- [ ] Review all diagnostics from past 12 weeks
- [ ] Check if any opportunities are working (did we implement them?)
- [ ] Measure impact of fixes (are conversions up as predicted?)
- [ ] Adjust conversion value if deal mix changed
- [ ] Add new pages to diagnostic portfolio if needed

---

## Troubleshooting

### **"Dashboard HTML won't open"**
- Check that the file is in `/Winning Wilderness (SEO)/dashboards/`
- Ensure browser can access local HTML files
- Verify file path in Slack notification matches actual file location

### **"Report DOCX is blank or incomplete"**
- Check that `/Winning Wilderness (SEO)/performance/` is writable
- Verify docx skill is available and working
- Look at scheduled task logs for errors

### **"GA4 data is missing"**
- Verify GA4 property ID in task parameters is correct
- Check that "enquiry" event is marked as Key Event in GA4 Admin
- Confirm gorilla-trekking page is tracking enquiry events (filter traffic to gorilla URL)
- If data is delayed, run task the next day

### **"SERP features aren't showing in report"**
- Verify Ahrefs API is connected and project ID is correct
- Check that Ahrefs has indexed the SERP for your keywords
- If Ahrefs data is stale (>7 days old), request fresh crawl

### **"Conversions are 0 every week"**
- Verify GA4 conversion event is correctly named and configured
- Check that form submissions / contact events are firing (use GA4 Real-Time)
- If zero is accurate, the page genuinely isn't driving conversions (content issue)

---

## ROI & Success Metrics

**Measure success by:**

1. **Speed of diagnosis** — Can SEO manager understand "why" in <5 min without asking follow-ups? (Target: yes)
2. **Recommendation quality** — Do recommended actions lead to ranking/CTR improvements? (Target: 70%+ of recommendations work)
3. **Time saved** — Hours spent diagnosing vs manually pulling data. (Target: 5 hours saved/month per page)
4. **Conversion impact** — Do implemented recommendations drive more enquiries? (Target: +15% conversion value/month)
5. **Scaling** — Can you replicate this system to all 6 camps + 30 pages? (Target: yes, by end of Q2)

---

## Next Steps

### **Immediate (This Week)**
1. ✅ Complete pre-deployment checklist (above)
2. ✅ Test scheduled task: click "Run now" Monday morning
3. ✅ Review outputs (dashboard + report + Slack notification)
4. ✅ Share with SEO team + get feedback

### **Short-term (Next 4 Weeks)**
1. Run diagnostic every Monday
2. Track which recommendations you implement
3. Measure impact (are conversions up as predicted?)
4. Refine based on feedback
5. Document any edge cases or improvements needed

### **Medium-term (Months 2–3)**
1. Validate system works consistently
2. Add performance comparisons (actual results vs predicted)
3. Identify patterns (which recommendation types work best?)
4. Plan for scaling to other pages

### **Long-term (Month 4+)**
1. Replicate system to Jao Camp, Tubu Tree, Pelo, Jacana, Kwetsani, Bisate
2. Create consolidated SEO Scorecard (all 6 camps + 30 pages in one Monday view)
3. Build predictive model (which fixes drive which improvements?)
4. Automate SEO roadmap generation from diagnostics

---

## Contact & Support

If diagnostic quality issues arise:
1. Check DIAGNOSTIC_METHODOLOGY_GUIDE.md for interpretation
2. Review WEEKLY_SEO_PROMPT_TEMPLATE.md for workflow
3. Check pre-deployment checklist (data source issue?)
4. If still unclear, run diagnostic manually with additional context/notes

---

## Version History

| Version | Date | Changes |
|---------|------|---------|
| 1.0 | Apr 1, 2026 | Initial release. 5-layer diagnostic, GA4 conversions, Ahrefs competitive data, ExCo-ready outputs. |

---

**Created for:** Wilderness Destinations SEO Team
**Proof point for:** Claude as AI-driven recommendation engine for SEO
**Scalable to:** 6 camps + 30+ experience pages
**Next milestone:** Validate on gorilla-trekking for 4 weeks, then replicate
