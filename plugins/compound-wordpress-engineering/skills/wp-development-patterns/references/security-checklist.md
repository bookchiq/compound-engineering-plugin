# WordPress Security Checklist

## Input Handling

### Nonce Verification
```php
// Forms: add nonce field
wp_nonce_field( 'my_plugin_action', 'my_plugin_nonce' );

// Processing: verify nonce
if ( ! isset( $_POST['my_plugin_nonce'] ) ||
     ! wp_verify_nonce( sanitize_text_field( wp_unslash( $_POST['my_plugin_nonce'] ) ), 'my_plugin_action' ) ) {
    wp_die( esc_html__( 'Security check failed.', 'my-plugin' ) );
}

// AJAX: verify nonce
check_ajax_referer( 'my_plugin_action', 'nonce' );
```

### Capability Checks
```php
if ( ! current_user_can( 'manage_options' ) ) {
    wp_die( esc_html__( 'Unauthorized.', 'my-plugin' ) );
}
```

Common capabilities:
- `manage_options` — Site settings
- `edit_posts` — Edit own posts
- `edit_others_posts` — Edit others' posts
- `publish_posts` — Publish posts
- `upload_files` — Media uploads
- `manage_categories` — Taxonomy management
- `activate_plugins` — Plugin management

### Data Sanitization
```php
// Text
$title = sanitize_text_field( wp_unslash( $_POST['title'] ) );

// HTML content
$content = wp_kses_post( wp_unslash( $_POST['content'] ) );

// Email
$email = sanitize_email( $_POST['email'] );

// Integer
$count = absint( $_POST['count'] );

// URL
$url = esc_url_raw( $_POST['url'] );

// Filename
$file = sanitize_file_name( $_POST['file'] );

// Key (lowercase alphanumeric + dashes + underscores)
$key = sanitize_key( $_POST['key'] );
```

### Output Escaping (Late Escaping)
```php
echo esc_html( $text );           // HTML content
echo esc_attr( $attribute );       // HTML attributes
echo esc_url( $url );             // URLs
echo esc_textarea( $text );       // Textarea content
echo wp_kses( $html, $allowed );  // Limited HTML
echo wp_kses_post( $html );       // Post-allowed HTML
```

## SQL Safety

```php
global $wpdb;

// Always use prepare() with variables
$results = $wpdb->get_results(
    $wpdb->prepare(
        "SELECT * FROM %i WHERE user_id = %d AND status = %s",
        $wpdb->prefix . 'my_table',
        $user_id,
        $status
    )
);

// LIKE queries need esc_like()
$like = '%' . $wpdb->esc_like( $search_term ) . '%';
$wpdb->prepare( "SELECT * FROM %i WHERE name LIKE %s", $table, $like );
```

Placeholders: `%d` (integer), `%s` (string), `%f` (float), `%i` (identifier/table name)

## REST API Security

```php
register_rest_route( 'my-plugin/v1', '/data', array(
    'methods'             => 'GET',
    'callback'            => 'my_plugin_get_data',
    'permission_callback' => function() {
        return current_user_can( 'edit_posts' );
    },
    'args'                => array(
        'id' => array(
            'required'          => true,
            'validate_callback' => function( $param ) {
                return is_numeric( $param );
            },
            'sanitize_callback' => 'absint',
        ),
    ),
) );
```

## File Security

- Every PHP file: `defined( 'ABSPATH' ) || exit;`
- Never use `extract()` on user data
- Never use `eval()` on user data
- Never use `unserialize()` on untrusted data (use `json_decode()`)
- Validate file types on upload: `wp_check_filetype()`
- Use `wp_handle_upload()` for file uploads

## Common Vulnerabilities

| Vulnerability | Prevention |
|---------------|------------|
| XSS | Escape all output: `esc_html()`, `esc_attr()`, `wp_kses()` |
| SQL Injection | Always use `$wpdb->prepare()` |
| CSRF | Nonce on all forms and AJAX |
| Privilege Escalation | `current_user_can()` on all actions |
| Path Traversal | `sanitize_file_name()`, never user-controlled includes |
| Object Injection | Never `unserialize()` user data |
| Open Redirect | `wp_safe_redirect()` not `wp_redirect()` for user input |
