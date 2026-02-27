# WordPress Test Patterns

Common patterns for testing WordPress plugins and themes.

## Testing Hooks

```php
class HookTest extends WP_UnitTestCase {

  public function test_action_is_registered() {
    // Verify a callback is hooked at the expected priority.
    $this->assertSame(
      10,
      has_action( 'init', 'myplugin_register_cpt' )
    );
  }

  public function test_filter_modifies_output() {
    // Apply the filter and check the result.
    $result = apply_filters( 'myplugin_title', 'Original' );
    $this->assertSame( 'Modified: Original', $result );
  }

  public function test_hook_callback_receives_arguments() {
    $received = null;
    add_action( 'myplugin_custom_action', function( $data ) use ( &$received ) {
      $received = $data;
    } );

    do_action( 'myplugin_custom_action', array( 'key' => 'value' ) );

    $this->assertSame( array( 'key' => 'value' ), $received );
  }
}
```

## Testing REST Endpoints

```php
class RestEndpointTest extends WP_UnitTestCase {

  public function test_endpoint_registered() {
    $routes = rest_get_server()->get_routes();
    $this->assertArrayHasKey( '/myplugin/v1/items', $routes );
  }

  public function test_get_items_returns_data() {
    // Create test data.
    self::factory()->post->create( array( 'post_type' => 'myplugin_item' ) );

    $request  = new WP_REST_Request( 'GET', '/myplugin/v1/items' );
    $response = rest_get_server()->dispatch( $request );

    $this->assertSame( 200, $response->get_status() );
    $this->assertNotEmpty( $response->get_data() );
  }

  public function test_create_item_requires_auth() {
    $request  = new WP_REST_Request( 'POST', '/myplugin/v1/items' );
    $request->set_body_params( array( 'title' => 'Test' ) );
    $response = rest_get_server()->dispatch( $request );

    $this->assertSame( 401, $response->get_status() );
  }

  public function test_create_item_with_auth() {
    $user_id = self::factory()->user->create( array( 'role' => 'administrator' ) );
    wp_set_current_user( $user_id );

    $request  = new WP_REST_Request( 'POST', '/myplugin/v1/items' );
    $request->set_body_params( array( 'title' => 'Test Item' ) );
    $response = rest_get_server()->dispatch( $request );

    $this->assertSame( 201, $response->get_status() );
  }
}
```

## Testing Custom Post Types

```php
class CptTest extends WP_UnitTestCase {

  public function test_cpt_is_registered() {
    $this->assertTrue( post_type_exists( 'myplugin_item' ) );
  }

  public function test_cpt_supports() {
    $supports = get_all_post_type_supports( 'myplugin_item' );
    $this->assertTrue( $supports['title'] );
    $this->assertTrue( $supports['editor'] );
    $this->assertFalse( isset( $supports['comments'] ) );
  }

  public function test_cpt_has_correct_labels() {
    $obj = get_post_type_object( 'myplugin_item' );
    $this->assertSame( 'Items', $obj->labels->name );
    $this->assertSame( 'Item', $obj->labels->singular_name );
  }
}
```

## Testing Post Meta

```php
class MetaTest extends WP_UnitTestCase {

  public function test_meta_is_registered() {
    $registered = get_registered_meta_keys( 'post', 'myplugin_item' );
    $this->assertArrayHasKey( '_myplugin_price', $registered );
  }

  public function test_meta_sanitization() {
    $post_id = self::factory()->post->create( array( 'post_type' => 'myplugin_item' ) );

    update_post_meta( $post_id, '_myplugin_price', '12.50' );
    $this->assertSame( '12.50', get_post_meta( $post_id, '_myplugin_price', true ) );

    // Test sanitization of invalid input.
    update_post_meta( $post_id, '_myplugin_price', '<script>alert(1)</script>' );
    $value = get_post_meta( $post_id, '_myplugin_price', true );
    $this->assertStringNotContainsString( '<script>', $value );
  }
}
```

## Testing Admin Pages

```php
class AdminPageTest extends WP_UnitTestCase {

  public function test_admin_menu_registered() {
    // Set up admin context.
    $user_id = self::factory()->user->create( array( 'role' => 'administrator' ) );
    wp_set_current_user( $user_id );

    do_action( 'admin_menu' );

    global $menu;
    $slugs = wp_list_pluck( $menu, 2 );
    $this->assertContains( 'myplugin-settings', $slugs );
  }

  public function test_settings_page_requires_capability() {
    $user_id = self::factory()->user->create( array( 'role' => 'subscriber' ) );
    wp_set_current_user( $user_id );

    $this->assertFalse( current_user_can( 'manage_options' ) );
  }
}
```

## Testing Options (Settings API)

```php
class OptionsTest extends WP_UnitTestCase {

  public function test_default_options() {
    $defaults = myplugin_get_default_options();
    $this->assertArrayHasKey( 'api_key', $defaults );
    $this->assertSame( '', $defaults['api_key'] );
  }

  public function test_save_settings_with_nonce() {
    $user_id = self::factory()->user->create( array( 'role' => 'administrator' ) );
    wp_set_current_user( $user_id );

    $_POST['myplugin_nonce'] = wp_create_nonce( 'myplugin_save_settings' );
    $_POST['myplugin_options'] = array( 'api_key' => 'test-key-123' );

    myplugin_save_settings();

    $options = get_option( 'myplugin_options' );
    $this->assertSame( 'test-key-123', $options['api_key'] );
  }

  public function test_save_settings_without_nonce_fails() {
    $user_id = self::factory()->user->create( array( 'role' => 'administrator' ) );
    wp_set_current_user( $user_id );

    $_POST['myplugin_options'] = array( 'api_key' => 'hacked' );

    // Should not save without nonce.
    myplugin_save_settings();

    $options = get_option( 'myplugin_options' );
    $this->assertNotSame( 'hacked', $options['api_key'] ?? '' );
  }
}
```

## Testing Shortcodes

```php
class ShortcodeTest extends WP_UnitTestCase {

  public function test_shortcode_registered() {
    $this->assertTrue( shortcode_exists( 'myplugin_widget' ) );
  }

  public function test_shortcode_output() {
    $output = do_shortcode( '[myplugin_widget title="Test"]' );
    $this->assertStringContainsString( 'Test', $output );
    $this->assertStringContainsString( '<div class="myplugin-widget">', $output );
  }
}
```

## Testing Blocks (Server-Side Rendering)

```php
class BlockTest extends WP_UnitTestCase {

  public function test_block_registered() {
    $registry = WP_Block_Type_Registry::get_instance();
    $this->assertTrue( $registry->is_registered( 'myplugin/featured-item' ) );
  }

  public function test_block_render_callback() {
    $block = WP_Block_Type_Registry::get_instance()->get_registered( 'myplugin/featured-item' );
    $output = $block->render( array( 'itemId' => 1 ), '' );

    $this->assertStringContainsString( '<div', $output );
  }
}
```

## Mocking Patterns

```php
class MockTest extends WP_UnitTestCase {

  public function test_with_mocked_http() {
    // Mock external HTTP requests.
    add_filter( 'pre_http_request', function( $preempt, $args, $url ) {
      if ( str_contains( $url, 'api.example.com' ) ) {
        return array(
          'response' => array( 'code' => 200 ),
          'body'     => wp_json_encode( array( 'status' => 'ok' ) ),
        );
      }
      return $preempt;
    }, 10, 3 );

    $result = myplugin_fetch_external_data();
    $this->assertSame( 'ok', $result['status'] );
  }
}
```
