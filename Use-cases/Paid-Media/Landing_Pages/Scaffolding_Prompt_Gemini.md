---
title: "Scaffolding_Prompt_Gemini"
type: project
area: wilderness
project: "Wilderness"
status: active
---
**[META-PROMPT INSTRUCTION: Begin Generation]**

**Objective:** Generate a complete, ready-to-run boilerplate for a static website project adhering to the specified technology stack and architectural patterns. The primary goal is to provide a highly modular and maintainable foundation where content can be managed by non-developers through JSON files, while presentation logic is handled by Smarty templates.

**Target Audience for the Generated Code:** A developer setting up the project, and a junior team member responsible for content editing (JSON files only).

**Finalized Technology Stack:**

- **Backend Logic:** PHP (latest stable version, no specific framework).
- **Data Storage:** JSON files (PHP's native `json_decode()` will be used, no external YAML library).
- **Templating Engine:** Smarty (latest stable version, installed via Composer).
- **Web Server:** Apache (utilizing `.htaccess` for URL rewriting).
- **Frontend Framework:** Bootstrap (for CSS, loaded via CDN).
- **JavaScript Library:** jQuery (loaded via CDN).
- **Icon Library:** Font Awesome (loaded via CDN).
- **Dependency Management:** Composer.
- **Development Environment:** Assumes PHP's built-in server or Apache Virtual Host pointing to `public/`.

**Core Requirements & Architectural Decisions:**

1. **Modular Structure:**
    - Separate directories for configuration (JSON data), templates, compiled templates, cache, and public assets.
    - Component-based approach for Smarty templates (e.g., `_hero.tpl`, `_features.tpl`).
    - Modular CSS organization (component-based, pure CSS, no preprocessors for now).
2. **Content Management (JSON):**
    - Each page's content will be stored in a dedicated JSON file (e.g., `homepage.json`, `about.json`).
    - A central `site_index.json` file will manage the list of available pages, their titles, and slugs for dynamic navigation.
3. **URL Rewriting (`.htaccess`):**
    - Implement clean URLs (e.g., `/about` instead of `/?page=about`) using Apache's `mod_rewrite`.
    - Ensure proper handling for existing files (CSS, JS, images) and directories.
4. **PHP Logic:**
    - A single entry point (`public/index.php`) responsible for:
        - Loading Composer autoload.
        - Initializing Smarty.
        - Parsing the requested page slug from the URL.
        - Loading the appropriate JSON data file.
        - Passing data to Smarty.
        - Handling 404 (page not found) and JSON parsing errors.
    - Include logic to load `site_index.json` into Smarty for navigation generation.
5. **Smarty Templating:**
    - Use template inheritance (`{extends}`, `{block}`) for a consistent base layout (`base.tpl`).
    - Utilize `{include file='...'}` for reusable components (`_hero.tpl`, `_features.tpl`).
    - Implement basic variable output (`{$var}`), conditional logic (`{if}`), and loops (`{foreach}`).
    - Ensure proper HTML escaping (`|escape`) for all dynamic content.
    - Placeholder templates for 404 and error pages.
6. **Frontend (Bootstrap & jQuery):**
    - Bootstrap CSS and JS will be loaded via CDN links in `base.tpl`.
    - jQuery will be loaded via CDN.
    - Font Awesome CSS will be loaded via CDN for icons.
    - Include a placeholder `style.css` for custom CSS and `script.js` for custom JavaScript.
7. **Generic Landing Page Components:** Include scaffolding for common landing page sections:
    - Hero section (title, subtitle, image, CTA).
    - Features section (multiple feature blocks with title, description, icon).
    - Call to Action (CTA) section (title, text, button).
    - Footer (copyright, navigation links).
    - These components should be driven by data from the JSON files.

**Output Requirements:**

For each file listed below, provide its complete content. Do NOT provide boilerplate comments that explain how to use the file if it's already implicitly clear from the code or filename (e.g., don't add comments like "This is the homepage template"). Focus on clean, functional code.

**File and Folder Structure to Generate:**

```
project-root/
├── config/
│   └── pages/
│       ├── homepage.json
│       └── generic.json
│   └── site_index.json
├── templates/
│   ├── base.tpl
│   ├── homepage.tpl
│   ├── generic.tpl
│   ├── 404.tpl      # Basic 404 page template
│   ├── error.tpl    # Basic error display template
│   └── components/  # Directory for reusable Smarty components
│       ├── _hero.tpl
│       ├── _features.tpl
│       ├── _call_to_action.tpl
│       └── _footer.tpl
├── templates_c/     # Smarty compiled templates (empty initially)
├── cache/           # Smarty cache (empty initially)
├── public/
│   ├── index.php    # Main PHP entry point
│   ├── .htaccess    # Apache URL rewrite rules
│   └── css/
│       └── style.css # Custom CSS file (empty initially)
│   └── js/
│       └── script.js # Custom JS file (empty initially)
├── vendor/          # Composer dependencies (managed by Composer)
├── composer.json    # Composer configuration
└── composer.lock    # Composer lock file (can be empty initially, generated by composer)
```

**Specific Content for Each File:**

1. **`composer.json`**
2. **`public/.htaccess`**
3. **`public/index.php`** (Core PHP logic)
4. **`config/site_index.json`** (Example with homepage and generic page)
5. **`config/pages/homepage.json`** (Full content for landing page components)
6. **`config/pages/generic.json`** (Simple title and content)
7. **`templates/base.tpl`** (Main layout, includes Bootstrap/jQuery CDNs, navigation loop from `$pages` variable, `current_page_slug` check for active state)
8. **`templates/homepage.tpl`** (Extends `base.tpl`, includes component partials)
9. **`templates/generic.tpl`** (Extends `base.tpl`, displays generic page content)
10. **`templates/404.tpl`** (Simple 404 page)
11. **`templates/error.tpl`** (Displays general error message)
12. **`templates/components/_hero.tpl`** (Bootstrap Jumbotron structure)
13. **`templates/components/_features.tpl`** (Bootstrap row/cols, Font Awesome icons)
14. **`templates/components/_call_to_action.tpl`** (Bootstrap background, large button)
15. **`templates/components/_footer.tpl`** (Basic copyright and links from JSON)
16. **`public/css/style.css`** (Empty, for custom CSS)
17. **`public/js/script.js`** (Empty, for custom JS)

**Setup Instructions (for a human user to follow after generation):**

1. **Create Project Structure:** Create the directories and empty files exactly as specified.
2. **Populate Files:** Copy the generated content into their respective files.
3. **Install Composer:** Ensure Composer is installed globally on your system.
4. **Install Dependencies:** Navigate to `project-root/` in your terminal and run `composer install`.
5. **Configure Apache:** Ensure `mod_rewrite` is enabled and your Apache Virtual Host (or equivalent for your local server setup) points to the `public/` directory with `AllowOverride All`.
6. **Start PHP Server:** For local testing, navigate to `project-root/` in your terminal and run `php -S localhost:8000 -t public`.
7. **Access:** Open your browser to `http://localhost:8000/` (for homepage) or `http://localhost:8000/about` (for generic page).

**[META-PROMPT INSTRUCTION: End Generation]**