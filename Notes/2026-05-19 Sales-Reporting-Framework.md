# Sales Reporting Framework — UHNW Safari

**Captured:** 2026-05-16  
**Source:** Guide conversation with Gareth  
**Status:** Inbox — to develop week of 2026-05-19  
**Context:** Building a deterministic sales performance reporting system in HubSpot for the safari sales team. UHNW, ultra-luxury, high-touch, low-volume. 4–6 week close cycle, 6–9 month travel horizon. Lead scoring: A/B/C/D. Primarily US market, no US team, no 24/7 coverage.

---

## Design Principles

Build around the questions a sales manager would ask — not data dumps. Three views of the data:

- **Exco** — revenue, forecast, pipeline value, coverage risk. Strategic lens.
- **Sales Manager** — full weekly view: flow, response, conversion, rep performance, leakage.
- **Team Member** — their own pipeline, their own response times, their own conversion. Self-accountable.

*(Note: second additional bullet was cut off in capture — revisit with Gareth)*

---

## Question Framework (Weekly Sales Management)

### 1. Lead Flow & Quality

- How many new leads came in this week, and what's the A/B/C/D split? No
- Is the A/B mix improving, holding, or degrading vs last week?
- What's the geographic breakdown — US vs rest of world?
- What % of A leads came in outside of team working hours? *(coverage gap made visible)*

---

### 2. First Response Time

*Single biggest lever for UHNW conversion. Speed signals seriousness.*

- What was the average time-to-first-contact for A leads? For B leads?
- How many A leads waited more than 4 hours? More than 24?
- What % of US A leads went uncontacted on day of submission?
- Is there a pattern between response time and subsequent conversion rate?

---

### 3. Pipeline Health & Stage Distribution

- How many leads are in each HubSpot stage right now?
- What moved forward this week? What didn't move at all?
- How many active leads have had zero activity in 7+ days?
- Are any A or B leads stalling — and if so, at what stage?

---

### 4. Cycle Velocity

- What's the average time from lead to proposal this week/month?
- What's the average lead-to-booking cycle? Is it tracking to the 4–6 week target or drifting?j
- Are there leads that have been in the pipeline longer than 8 weeks? What's happening with them?

---

### 5. Conversion Funnel

- Lead → qualified: what % this week?
- Qualified → proposal sent: what %?
- Proposal → booking: what %?
- Break these down by lead tier — an A lead that doesn't convert is a different problem than a C lead.

---

### 6. Revenue & Bookings

- How many bookings this week and what's the total value?
- Average booking value — is it tracking to target?
- Which lead tier are bookings coming from? *(validates scoring model)*
- What's the travel date distribution of new bookings? Are we filling the right windows?

---

### 7. Forward Pipeline & Forecast

- What's the total pipeline value in active leads?
- What's the realistic booking forecast for the next 4–6 weeks based on stage and age?
- How many months of travel demand are we currently holding in the pipeline?
- What revenue is "at risk" — defined as A/B leads with no activity in 5+ days?

---

### 8. Lost Deals & Leakage

- How many leads were marked lost or disqualified this week?
- At what stage did they exit?
- What were the stated reasons? *(UHNW clients rarely give a real reason — proxies matter)*
- How many A/B leads went cold without a close attempt?

---

### 9. Rep Performance

- How many meaningful touches did each rep make this week? (calls, substantive emails — not CRM auto-logs)
- How many proposals did each rep send?
- What's each rep's conversion rate: qualified → proposal, and proposal → booking?
- Who has the healthiest pipeline by value and stage distribution?
- Are there reps consistently taking longer on first response?

---

### 10. US / Geography Coverage

*Runs across all of the above — deserves its own cut.*

- What % of total A leads are US-based?
- What's the average first response time for US leads specifically?
- How many US A leads are being lost or going cold before first contact?
- Is the US conversion rate materially lower than other regions — and if so, is response time the explanation?

*This data will make the case for the US coverage decision: out-of-hours rota, contractor, US hire, or automated first-touch with a human follow-up SLA.*

---

## Questions Deprioritised for Weekly Cadence

- Lead source attribution → monthly
- Brand/product mix → quarterly
- Nurture pipeline conversion → monthly (slow-moving)

---

## Next Steps

- [ ] Decide on the third design principle (message cut off — confirm with Gareth)
- [ ] Map questions to HubSpot objects and properties
- [ ] Define the three reporting views in detail (exco / sales manager / team member)
- [ ] Identify data gaps in current HubSpot setup
- [ ] Agree on response time SLAs by lead tier
