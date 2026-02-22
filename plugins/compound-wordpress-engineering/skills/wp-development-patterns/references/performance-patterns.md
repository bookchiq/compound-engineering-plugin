# WordPress Performance Patterns

## Database Query Optimization

### WP_Query Best Practices
```php
// Always set posts_per_page (never -1 in production)
$query = new WP_Query( array(
    'post_type'      => 'product',
    'posts_per_page' => 20,
    'no_found_rows'  => true, // Skip SQL_CALC_FOUND_ROWS if no pagination needed
    'update_post_meta_cache' => false, // Skip if not reading meta
    'update_post_term_cache' => false, // Skip if not reading terms
    'fields'         => 'ids', // Only fetch IDs if that's all you need
) );
```

### Avoid N+1 Queries
```php
// BAD: get_post_meta() in loop
foreach ( $posts as $post ) {
    $meta = get_post_meta( $post->ID, 'my_meta', true ); // 1 query per post
}

// GOOD: Prime the cache before the loop
update_post_meta_cache( wp_list_pluck( $posts, 'ID' ) );
foreach ( $posts as $post ) {
    $meta = get_post_meta( $post->ID, 'my_meta', true ); // From cache
}
```

### Direct $wpdb Queries
```php
// Always include LIMIT
$results = $wpdb->get_results(
    $wpdb->prepare(
        "SELECT id, title FROM %i WHERE status = %s LIMIT %d",
        $table, 'active', 100
    )
);
```

## Caching

### Object Cache (wp_cache)
```php
function my_plugin_get_expensive_data( $key ) {
    $data = wp_cache_get( $key, 'my_plugin' );
    if ( false === $data ) {
        $data = expensive_computation( $key );
        wp_cache_set( $key, $data, 'my_plugin', HOUR_IN_SECONDS );
    }
    return $data;
}
```

### Transients (for external API calls)
```php
function my_plugin_get_api_data() {
    $data = get_transient( 'my_plugin_api_data' );
    if ( false === $data ) {
        $response = wp_remote_get( 'https://api.example.com/data' );
        if ( ! is_wp_error( $response ) ) {
            $data = json_decode( wp_remote_retrieve_body( $response ), true );
            set_transient( 'my_plugin_api_data', $data, HOUR_IN_SECONDS );
        }
    }
    return $data;
}
```

### Options Autoloading
```php
// For rarely-used options, disable autoload
add_option( 'my_plugin_log', $data, '', 'no' );
// Or with update_option (WordPress 6.6+):
update_option( 'my_plugin_log', $data, false );
```

## Hook Placement

| Hook | When to Use | Avoid |
|------|-------------|-------|
| `plugins_loaded` | Cross-plugin dependencies, translations | Heavy operations |
| `init` | CPT/taxonomy registration, shortcodes | Database queries |
| `wp` | Access queried object, conditional logic | Enqueuing scripts |
| `wp_enqueue_scripts` | Frontend scripts/styles | Admin assets |
| `admin_enqueue_scripts` | Admin scripts/styles (check $hook) | Frontend assets |
| `rest_api_init` | REST route registration | Other hooks |

## Asset Loading

```php
// Conditional loading — only on pages that need it
add_action( 'wp_enqueue_scripts', function() {
    if ( is_singular( 'product' ) ) {
        wp_enqueue_script(
            'my-plugin-product',
            MY_PLUGIN_URL . 'assets/js/product.js',
            array(),
            MY_PLUGIN_VERSION,
            array( 'strategy' => 'defer', 'in_footer' => true )
        );
    }
});

// Per-block styles (WordPress 5.9+)
add_action( 'init', function() {
    wp_enqueue_block_style( 'core/paragraph', array(
        'handle' => 'my-plugin-paragraph',
        'src'    => MY_PLUGIN_URL . 'assets/css/paragraph.css',
    ) );
});
```

## Background Processing

```php
// Use WP-Cron for background tasks
if ( ! wp_next_scheduled( 'my_plugin_daily_task' ) ) {
    wp_schedule_event( time(), 'daily', 'my_plugin_daily_task' );
}
add_action( 'my_plugin_daily_task', 'my_plugin_run_daily_task' );

// Clean up on deactivation
register_deactivation_hook( __FILE__, function() {
    wp_clear_scheduled_hook( 'my_plugin_daily_task' );
});
```

## Performance Anti-Patterns

| Anti-Pattern | Fix |
|--------------|-----|
| `'posts_per_page' => -1` | Set a reasonable limit |
| `query_posts()` | Use `WP_Query` or `pre_get_posts` |
| `get_posts()` without limit | Set `numberposts` |
| `$wpdb->get_results()` without LIMIT | Add LIMIT clause |
| `get_post_meta()` in loops | Prime cache with `update_post_meta_cache()` |
| Queries in template parts | Pass data from main query |
| `get_template_part()` in tight loops | Consider alternative structure |
| Scripts in `<head>` | Use `$in_footer = true` or `defer` strategy |
| Full library imports | Load only needed components |
| Operations on `init` | Use conditional checks or later hooks |
