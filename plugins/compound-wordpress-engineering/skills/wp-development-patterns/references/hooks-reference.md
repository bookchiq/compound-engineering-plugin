# WordPress Hooks Reference

## Execution Order (Frontend Request)

```
muplugins_loaded
plugins_loaded          → Cross-plugin dependencies, load textdomain
setup_theme
after_setup_theme       → add_theme_support(), register_nav_menus(), add_image_size()
init                    → register_post_type(), register_taxonomy(), register_block_type()
wp_loaded               → After all init hooks complete
parse_request
send_headers
parse_query
pre_get_posts           → Modify main query (check $query->is_main_query())
wp                      → Main query is set up (access $wp_query)
template_redirect       → Redirects, conditional checks
template_include        → Override template file
wp_enqueue_scripts      → Enqueue frontend CSS/JS
wp_head                 → Inside <head>
the_content             → Filter post content (runs multiple times!)
wp_footer               → Before </body>
shutdown
```

## Execution Order (Admin Request)

```
plugins_loaded
init
admin_init              → After admin initializes
admin_menu              → Register admin pages
admin_enqueue_scripts   → Enqueue admin CSS/JS (receives $hook_suffix)
admin_notices           → Display admin notices
```

## Execution Order (REST API)

```
plugins_loaded
init
rest_api_init           → Register REST routes
rest_pre_dispatch       → Before REST processing
rest_dispatch_request   → During REST processing
rest_post_dispatch      → After REST processing
```

## Execution Order (AJAX)

```
plugins_loaded
init
wp_ajax_{action}            → Logged-in users
wp_ajax_nopriv_{action}     → Non-logged-in users
```

## Execution Order (Cron)

```
plugins_loaded
init
{scheduled_hook}            → Your custom cron hook
```

## Key Actions

| Hook | When to Use | Common Mistakes |
|------|-------------|-----------------|
| `plugins_loaded` | Cross-plugin API, translations | Heavy computation |
| `init` | CPTs, taxonomies, shortcodes, blocks | Enqueuing scripts |
| `wp` | Conditional logic needing queried object | Too late for CPTs |
| `wp_enqueue_scripts` | Frontend scripts/styles | Loading admin assets |
| `admin_enqueue_scripts` | Admin scripts/styles | Missing $hook check |
| `rest_api_init` | REST route registration | Using `init` for REST |
| `admin_menu` | Register admin pages | Heavy queries |
| `admin_init` | Admin-side initialization | Frontend code |
| `save_post` | After post save | Not checking post type |
| `pre_get_posts` | Modify main query | Not checking is_main_query() |
| `template_redirect` | Redirects, access control | Output before redirect |
| `wp_head` | Meta tags, inline scripts | Large script blocks |
| `wp_footer` | Deferred scripts, tracking | Critical scripts |
| `widgets_init` | Register widget areas | Too late for sidebars |

## Key Filters

| Filter | Purpose |
|--------|---------|
| `the_content` | Modify post content before display |
| `the_title` | Modify post title before display |
| `the_excerpt` | Modify post excerpt before display |
| `body_class` | Add/remove body CSS classes |
| `post_class` | Add/remove post CSS classes |
| `wp_nav_menu_items` | Modify navigation menu output |
| `upload_mimes` | Allow/restrict upload file types |
| `login_redirect` | Custom login redirect URL |
| `authenticate` | Custom authentication logic |
| `rest_prepare_{post_type}` | Modify REST API response for post type |
| `block_type_metadata` | Modify block registration metadata |

## Common Patterns

### Conditional Registration
```php
// Only load admin code on admin pages
if ( is_admin() ) {
    add_action( 'admin_init', 'my_plugin_admin_init' );
}

// Only load frontend code on frontend
if ( ! is_admin() ) {
    add_action( 'wp_enqueue_scripts', 'my_plugin_frontend_assets' );
}
```

### Priority Control
```php
// Run early (before most plugins)
add_action( 'init', 'my_plugin_early_init', 5 );

// Run at default priority
add_action( 'init', 'my_plugin_init' ); // priority 10

// Run late (after most plugins)
add_action( 'init', 'my_plugin_late_init', 20 );
```

### Removing Hooks
```php
// Must match exact callback AND priority
remove_action( 'wp_head', 'wp_generator' );         // priority 10 (default)
remove_action( 'wp_head', 'feed_links', 2 );        // priority 2
remove_filter( 'the_content', 'wpautop' );           // priority 10 (default)
```
