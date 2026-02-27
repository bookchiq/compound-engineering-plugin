# Red-Green-Refactor TDD for WordPress

Test-Driven Development adapted for WordPress plugin and theme development.

## The Cycle

```
1. RED    — Write a failing test that describes desired behavior
2. GREEN  — Write the minimum code to make the test pass
3. REFACTOR — Clean up code while keeping tests green
```

## Example: TDD a REST Endpoint

### Step 1: RED — Write the Failing Test

```php
class ItemsEndpointTest extends WP_UnitTestCase {

  public function test_endpoint_exists() {
    $routes = rest_get_server()->get_routes();
    $this->assertArrayHasKey( '/myplugin/v1/items', $routes );
  }

  public function test_get_items_returns_200() {
    $request  = new WP_REST_Request( 'GET', '/myplugin/v1/items' );
    $response = rest_get_server()->dispatch( $request );
    $this->assertSame( 200, $response->get_status() );
  }

  public function test_get_items_returns_array() {
    $request  = new WP_REST_Request( 'GET', '/myplugin/v1/items' );
    $response = rest_get_server()->dispatch( $request );
    $this->assertIsArray( $response->get_data() );
  }
}
```

Run: `vendor/bin/phpunit --filter ItemsEndpoint` — all 3 tests fail (RED).

### Step 2: GREEN — Minimum Implementation

```php
add_action( 'rest_api_init', function() {
  register_rest_route( 'myplugin/v1', '/items', array(
    'methods'             => 'GET',
    'callback'            => function() {
      return array();
    },
    'permission_callback' => '__return_true',
  ) );
} );
```

Run: `vendor/bin/phpunit --filter ItemsEndpoint` — all 3 tests pass (GREEN).

### Step 3: REFACTOR — Extract to Class

```php
class MyPlugin_REST_Items_Controller {

  public function register_routes() {
    register_rest_route( 'myplugin/v1', '/items', array(
      'methods'             => 'GET',
      'callback'            => array( $this, 'get_items' ),
      'permission_callback' => '__return_true',
    ) );
  }

  public function get_items( $request ) {
    return rest_ensure_response( array() );
  }
}

add_action( 'rest_api_init', function() {
  $controller = new MyPlugin_REST_Items_Controller();
  $controller->register_routes();
} );
```

Run: `vendor/bin/phpunit --filter ItemsEndpoint` — all 3 tests still pass (REFACTOR complete).

### Step 4: Continue the Cycle

Now add more tests and repeat:

```php
public function test_get_items_returns_posts() {
  self::factory()->post->create( array(
    'post_type'  => 'myplugin_item',
    'post_title' => 'Test Item',
  ) );

  $request  = new WP_REST_Request( 'GET', '/myplugin/v1/items' );
  $response = rest_get_server()->dispatch( $request );
  $data     = $response->get_data();

  $this->assertCount( 1, $data );
  $this->assertSame( 'Test Item', $data[0]['title'] );
}
```

RED → implement `get_items()` to query posts → GREEN → REFACTOR.

## Example: TDD a Settings Handler

### RED

```php
class SettingsTest extends WP_UnitTestCase {

  public function test_save_valid_settings() {
    $user_id = self::factory()->user->create( array( 'role' => 'administrator' ) );
    wp_set_current_user( $user_id );

    $_POST['_wpnonce'] = wp_create_nonce( 'myplugin_settings' );
    $_POST['myplugin_api_key'] = 'valid-key-123';

    myplugin_handle_settings_save();

    $this->assertSame( 'valid-key-123', get_option( 'myplugin_api_key' ) );
  }

  public function test_reject_without_nonce() {
    wp_set_current_user( 1 );
    $_POST['myplugin_api_key'] = 'hacked-key';

    myplugin_handle_settings_save();

    $this->assertNotSame( 'hacked-key', get_option( 'myplugin_api_key' ) );
  }

  public function test_reject_without_capability() {
    $user_id = self::factory()->user->create( array( 'role' => 'subscriber' ) );
    wp_set_current_user( $user_id );

    $_POST['_wpnonce'] = wp_create_nonce( 'myplugin_settings' );
    $_POST['myplugin_api_key'] = 'unauthorized-key';

    myplugin_handle_settings_save();

    $this->assertNotSame( 'unauthorized-key', get_option( 'myplugin_api_key' ) );
  }
}
```

### GREEN

```php
function myplugin_handle_settings_save() {
  if ( ! isset( $_POST['_wpnonce'] ) || ! wp_verify_nonce( $_POST['_wpnonce'], 'myplugin_settings' ) ) {
    return;
  }

  if ( ! current_user_can( 'manage_options' ) ) {
    return;
  }

  if ( isset( $_POST['myplugin_api_key'] ) ) {
    update_option( 'myplugin_api_key', sanitize_text_field( wp_unslash( $_POST['myplugin_api_key'] ) ) );
  }
}
```

## When to Skip TDD

TDD adds the most value for:
- REST endpoints (complex request/response)
- Settings handlers (security paths)
- Data processing logic
- Custom queries and filters

Skip TDD for:
- Config-only changes (phpcs.xml, composer.json)
- UI-only changes (CSS, templates)
- Simple one-line fixes with obvious correctness
- Documentation updates
