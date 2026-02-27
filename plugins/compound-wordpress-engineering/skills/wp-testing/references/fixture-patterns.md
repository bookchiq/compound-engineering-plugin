# Test Fixture Patterns for WordPress

Patterns for creating and managing test data in WordPress PHPUnit tests.

## Built-in Factories

WordPress `WP_UnitTestCase` provides factory methods for common data:

```php
// Create a post
$post_id = self::factory()->post->create();

// Create with specific attributes
$post_id = self::factory()->post->create( array(
  'post_title'  => 'Test Post',
  'post_status' => 'publish',
  'post_type'   => 'page',
  'post_author' => $user_id,
) );

// Create and get the object
$post = self::factory()->post->create_and_get( array(
  'post_title' => 'Test Post',
) );

// Create multiple posts
$post_ids = self::factory()->post->create_many( 5, array(
  'post_status' => 'publish',
) );
```

### Available Factories

```php
self::factory()->post->create();          // WP_Post
self::factory()->attachment->create();    // Attachment
self::factory()->comment->create();       // WP_Comment
self::factory()->user->create();          // WP_User
self::factory()->term->create();          // WP_Term
self::factory()->category->create();      // Category term
self::factory()->tag->create();           // Tag term
self::factory()->blog->create();          // Multisite blog
self::factory()->network->create();       // Multisite network
```

## Custom Factories

Create reusable factories for custom post types:

```php
class MyPlugin_Item_Factory extends WP_UnitTest_Factory_For_Post {

  public function __construct( $factory = null ) {
    parent::__construct( $factory );
    $this->default_generation_definitions = array(
      'post_type'   => 'myplugin_item',
      'post_status' => 'publish',
      'post_title'  => new WP_UnitTest_Generator_Sequence( 'Item %s' ),
    );
  }
}
```

Register in bootstrap.php or setUp():

```php
class ItemTest extends WP_UnitTestCase {

  protected static function wpSetUpBeforeClass( WP_UnitTest_Factory $factory ) {
    $factory->myplugin_item = new MyPlugin_Item_Factory( $factory );
  }

  public function test_items() {
    $item_id = self::factory()->myplugin_item->create( array(
      'post_title' => 'Special Item',
    ) );
    $this->assertSame( 'myplugin_item', get_post_type( $item_id ) );
  }
}
```

## Database Transaction Rollback

WordPress test framework automatically rolls back database changes after each test:

```php
class DatabaseTest extends WP_UnitTestCase {

  public function test_creates_data() {
    // This post is automatically deleted after the test.
    $post_id = self::factory()->post->create();
    $this->assertGreaterThan( 0, $post_id );
  }

  public function test_no_leftover_data() {
    // Previous test's data is gone.
    $posts = get_posts( array( 'post_type' => 'post', 'numberposts' => -1 ) );
    // Only default content exists.
  }
}
```

## JSON Fixtures

For complex test data, use JSON fixture files:

```
tests/
└── fixtures/
    ├── api-response.json
    ├── product-data.json
    └── import-data.json
```

Load in tests:

```php
class ImportTest extends WP_UnitTestCase {

  private function load_fixture( $name ) {
    $path = __DIR__ . '/../fixtures/' . $name;
    return json_decode( file_get_contents( $path ), true );
  }

  public function test_import_products() {
    $data = $this->load_fixture( 'product-data.json' );
    $result = myplugin_import_products( $data );
    $this->assertSame( count( $data ), $result['imported'] );
  }
}
```

## setUp / tearDown

Use for per-test setup and cleanup:

```php
class MyTest extends WP_UnitTestCase {

  private $admin_id;

  public function set_up() {
    parent::set_up();
    $this->admin_id = self::factory()->user->create( array( 'role' => 'administrator' ) );
    wp_set_current_user( $this->admin_id );
  }

  public function tear_down() {
    wp_set_current_user( 0 );
    parent::tear_down();
  }
}
```

## wpSetUpBeforeClass / wpTearDownAfterClass

Use for expensive setup shared across all tests in a class:

```php
class ExpensiveTest extends WP_UnitTestCase {

  protected static $post_ids;

  public static function wpSetUpBeforeClass( WP_UnitTest_Factory $factory ) {
    // Created once, shared by all tests.
    self::$post_ids = $factory->post->create_many( 50, array(
      'post_type'   => 'myplugin_item',
      'post_status' => 'publish',
    ) );
  }

  public function test_query_items() {
    $query = new WP_Query( array( 'post_type' => 'myplugin_item' ) );
    $this->assertSame( 50, $query->found_posts );
  }
}
```

## Blueprint-Based Seeding

For integration tests that use WP Playground, seed via blueprint:

```json
{
  "steps": [
    {
      "step": "runPHP",
      "code": "<?php require '/wordpress/wp-load.php'; for ($i = 0; $i < 10; $i++) { wp_insert_post(array('post_title' => 'Test ' . $i, 'post_status' => 'publish')); } ?>"
    }
  ]
}
```

Or use WXR import for complex content structures (see wp-playground skill).
