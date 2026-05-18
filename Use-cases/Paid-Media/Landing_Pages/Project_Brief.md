---
title: "Project_Brief"
type: project
area: wilderness
project: "Wilderness"
status: active
---
# Project Brief: Modular Static Website Platform

## 1. Project Overview

This project aims to establish a robust, modular, and easily manageable platform for creating static websites. The core objective is to allow non-technical team members (specifically, a junior content editor) to manage website content efficiently using simple data files, while developers focus on the underlying code and presentation logic. This separation of concerns will streamline content updates and enhance overall project maintainability and scalability.

---

## 2. Project Goal

To build a foundational system for static web pages that is:

- **Content-Driven:** All page-specific content (text, images, CTAs, SEO meta) is stored in easily editable JSON files.
- **Modular:** Components (e.g., hero sections, feature blocks) are reusable across different pages and managed as separate template files.
- **Maintainable:** Clear separation between data, presentation, and logic, making updates and debugging straightforward.
- **Scalable:** Designed to effortlessly manage an initial set of 30 pages, with potential for future expansion.
- **User-Friendly:** For content editors, the process of updating content should be as simple as editing JSON files.

---

## 3. Key Features & Functionality

- **Clean URLs:** Implement human-readable URLs (e.g., `/about` instead of `/?page=about`) via Apache's `.htaccess` rewrite rules.
- **Dynamic Navigation:** A central `site_index.json` file will manage all site pages, enabling automated navigation menu generation.
- **Page Content Management:** Each page's specific content will reside in its own dedicated JSON file (`config/pages/page-slug.json`).
- **Reusable UI Components:** Utilize a component-based approach for common page elements (hero, features, call-to-action, footer), allowing for rapid page assembly.
- **Error Handling:** Implement basic 404 (Page Not Found) and general error display pages for a graceful user experience.

---

## 4. Technical Stack Specification

- **Backend & Logic:** **PHP** (latest stable version).
- **Data Storage:** **JSON** files for all content and site index. PHP's native `json_decode()` will be used for parsing.
- **Templating Engine:** **Smarty** (latest stable version via Composer) for all presentation layer logic, utilizing template inheritance (`{extends}`, `{block}`) and includes (`{include}`).
- **Web Server:** **Apache** with `mod_rewrite` enabled to handle clean URLs.
- **Frontend Framework:** **Bootstrap 4.x** (CSS only, loaded via CDN) for responsive design and UI components.
- **JavaScript Library:** **jQuery 3.x** (loaded via CDN) for any basic client-side interactions.
- **Icons:** **Font Awesome 5.x** (loaded via CDN) for vector icons.
- **Dependency Management:** **Composer** for managing PHP libraries (Smarty).
- **CSS:** Pure **CSS** (no preprocessors like Sass/Less initially), organized into a modular, component-based structure.

---

## 5. Architectural Principles

- **Strict Separation of Concerns:**
    - **Data Layer:** JSON files only. Managed by content editors.
    - **Logic Layer:** PHP files only. Handles data fetching, processing, and passing to templates.
    - **Presentation Layer:** Smarty templates only. Manages HTML structure and data display.
- **Component-Based Templating:** Common UI elements are developed as reusable Smarty partials (`templates/components/_*.tpl`).
- **Modular CSS:** CSS will be organized into logical files (e.g., `base.css`, `components/*.css`, `pages/*.css`) under `public/css/`, reflecting the component structure.
- **Security:** Default HTML escaping will be used via Smarty modifiers to prevent XSS vulnerabilities.

---

## 6. Deliverables

- **Complete Codebase:** A functional project structure with all specified files and initial scaffolding, ready for immediate local deployment.
- **Core Logic:** `public/index.php` handling routing, JSON parsing, and Smarty rendering.
- **Base Layout:** `templates/base.tpl` providing the overall site structure, header, navigation, and footer.
- **Example Pages:** `homepage.json` and `generic.json` with corresponding `homepage.tpl` and `generic.tpl` templates.
- **Reusable Components:** Example Smarty partials for common sections (`_hero.tpl`, `_features.tpl`, `_call_to_action.tpl`, `_footer.tpl`).
- **Site Index:** `site_index.json` to power dynamic navigation.
- **Basic Styling:** An empty `public/css/style.css` and `public/js/script.js` for custom additions.
- **Deployment Configuration:** `public/.htaccess` for clean URLs.
- **Setup Instructions:** Clear, step-by-step instructions for getting the project running locally.

---

## 7. Future Considerations

While not part of this initial scope, the architecture should allow for future enhancements such as:

- Caching mechanisms (Smarty's built-in caching).
- More advanced routing logic (if pages become extremely numerous or require dynamic parameters).
- Integration with static site generation tools (if pure static HTML files become a requirement).