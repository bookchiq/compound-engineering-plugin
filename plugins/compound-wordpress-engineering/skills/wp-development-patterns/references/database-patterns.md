# WordPress Database Patterns

## $wpdb Basics

```php
global $wpdb;

// Table names — always use prefix
$table = $wpdb->prefix . 'my_custom_table';

// Core table properties
$wpdb->posts;        // wp_posts
$wpdb->postmeta;     // wp_postmeta
$wpdb->users;        // wp_users
$wpdb->usermeta;     // wp_usermeta
$wpdb->options;      // wp_options
$wpdb->terms;        // wp_terms
$wpdb->term_taxonomy; // wp_term_taxonomy
```

## Prepared Statements

```php
// SELECT with prepare
$results = $wpdb->get_results(
    $wpdb->prepare(
        "SELECT * FROM %i WHERE status = %s AND count > %d LIMIT %d",
        $wpdb->prefix . 'my_table',
        'active',
        5,
        100
    )
);

// Single row
$row = $wpdb->get_row(
    $wpdb->prepare( "SELECT * FROM %i WHERE id = %d", $table, $id )
);

// Single value
$count = $wpdb->get_var(
    $wpdb->prepare( "SELECT COUNT(*) FROM %i WHERE status = %s", $table, 'active' )
);

// Single column
$ids = $wpdb->get_col(
    $wpdb->prepare( "SELECT id FROM %i WHERE status = %s", $table, 'active' )
);

// INSERT
$wpdb->insert(
    $table,
    array( 'name' => $name, 'count' => $count ),
    array( '%s', '%d' )
);
$new_id = $wpdb->insert_id;

// UPDATE
$wpdb->update(
    $table,
    array( 'name' => $new_name ),    // data
    array( 'id' => $id ),            // where
    array( '%s' ),                   // data format
    array( '%d' )                    // where format
);

// DELETE
$wpdb->delete( $table, array( 'id' => $id ), array( '%d' ) );
```

## Custom Table Creation with dbDelta

```php
function my_plugin_create_tables() {
    global $wpdb;

    $table_name      = $wpdb->prefix . 'my_plugin_data';
    $charset_collate = $wpdb->get_charset_collate();

    // dbDelta is VERY particular about formatting:
    // - TWO spaces after PRIMARY KEY
    // - KEY not INDEX for secondary indexes
    // - Each column on its own line
    // - No trailing comma before closing paren
    $sql = "CREATE TABLE $table_name (
        id bigint(20) unsigned NOT NULL AUTO_INCREMENT,
        user_id bigint(20) unsigned NOT NULL DEFAULT 0,
        name varchar(255) NOT NULL DEFAULT '',
        data longtext NOT NULL,
        status varchar(20) NOT NULL DEFAULT 'pending',
        created_at datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
        updated_at datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
        PRIMARY KEY  (id),
        KEY user_id (user_id),
        KEY status (status)
    ) $charset_collate;";

    require_once ABSPATH . 'wp-admin/includes/upgrade.php';
    dbDelta( $sql );
}
```

## Version-Tracked Schema Migrations

```php
define( 'MY_PLUGIN_DB_VERSION', '1.2.0' );

function my_plugin_check_db_version() {
    $installed_version = get_option( 'my_plugin_db_version', '0' );

    if ( version_compare( $installed_version, MY_PLUGIN_DB_VERSION, '<' ) ) {
        my_plugin_create_tables(); // dbDelta handles CREATE and ALTER
        my_plugin_run_migrations( $installed_version );
        update_option( 'my_plugin_db_version', MY_PLUGIN_DB_VERSION );
    }
}
add_action( 'plugins_loaded', 'my_plugin_check_db_version' );

function my_plugin_run_migrations( $from_version ) {
    global $wpdb;
    $table = $wpdb->prefix . 'my_plugin_data';

    // Run migrations incrementally
    if ( version_compare( $from_version, '1.1.0', '<' ) ) {
        // Migration: Add status column
        // dbDelta handles this via CREATE TABLE, but for data migrations:
        $wpdb->query(
            $wpdb->prepare(
                "UPDATE %i SET status = %s WHERE status = %s",
                $table, 'active', ''
            )
        );
    }

    if ( version_compare( $from_version, '1.2.0', '<' ) ) {
        // Migration: Backfill created_at
        $wpdb->query(
            $wpdb->prepare(
                "UPDATE %i SET created_at = %s WHERE created_at = %s",
                $table, current_time( 'mysql' ), '0000-00-00 00:00:00'
            )
        );
    }
}
```

## Activation and Uninstall

```php
// Activation: create tables
register_activation_hook( __FILE__, function() {
    my_plugin_create_tables();
    update_option( 'my_plugin_db_version', MY_PLUGIN_DB_VERSION );
});

// Uninstall: clean up (use uninstall.php or register_uninstall_hook)
// uninstall.php:
<?php
defined( 'WP_UNINSTALL_PLUGIN' ) || exit;

global $wpdb;
$wpdb->query( "DROP TABLE IF EXISTS {$wpdb->prefix}my_plugin_data" );
delete_option( 'my_plugin_db_version' );
delete_option( 'my_plugin_settings' );

// Clean up user meta
delete_metadata( 'user', 0, 'my_plugin_preference', '', true );
```

## Post Meta vs Custom Tables

### Use Post Meta When:
- Data is directly related to a post
- You need WordPress admin UI (custom fields)
- Data volume is moderate (< 10 meta keys per post)
- You need WP_Query meta_query support

### Use Custom Tables When:
- High volume data (logs, analytics, large datasets)
- Data has its own structure (not post-related)
- Complex queries that meta_query can't handle efficiently
- Data needs foreign keys or complex indexes
- Many-to-many relationships

## WP_Query vs get_posts vs $wpdb

| Method | Use When |
|--------|----------|
| `WP_Query` | Need pagination, template tags, full post objects |
| `get_posts()` | Simple queries, no pagination needed, returns array |
| `$wpdb` | Complex joins, aggregations, non-post data, custom tables |

## Options API

```php
// Add (won't overwrite existing)
add_option( 'my_plugin_version', '1.0.0' );

// Get
$value = get_option( 'my_plugin_setting', 'default_value' );

// Update (creates if doesn't exist)
update_option( 'my_plugin_setting', $new_value );

// Delete
delete_option( 'my_plugin_setting' );

// Autoload control (WordPress 6.6+)
update_option( 'my_plugin_large_data', $data, false ); // false = don't autoload
```
