# PHPCS Configuration for WordPress

Templates and configuration options for `phpcs.xml.dist`.

## Plugin Template

```xml
<?xml version="1.0"?>
<ruleset name="My Plugin">
  <description>PHPCS configuration for My Plugin.</description>

  <!-- Scan these files -->
  <file>.</file>

  <!-- Exclude paths -->
  <exclude-pattern>/vendor/*</exclude-pattern>
  <exclude-pattern>/node_modules/*</exclude-pattern>
  <exclude-pattern>/tests/*</exclude-pattern>
  <exclude-pattern>/build/*</exclude-pattern>
  <exclude-pattern>/assets/*</exclude-pattern>

  <!-- Use WordPress Coding Standards -->
  <rule ref="WordPress"/>

  <!-- Set minimum supported WP version for deprecated function checks -->
  <config name="minimum_wp_version" value="6.0"/>

  <!-- Set text domain for i18n checks -->
  <rule ref="WordPress.WP.I18n">
    <properties>
      <property name="text_domain" type="array">
        <element value="my-plugin"/>
      </property>
    </properties>
  </rule>

  <!-- Set allowed prefixes -->
  <rule ref="WordPress.NamingConventions.PrefixAllGlobals">
    <properties>
      <property name="prefixes" type="array">
        <element value="my_plugin"/>
        <element value="MY_PLUGIN"/>
      </property>
    </properties>
  </rule>

  <!-- PHP compatibility -->
  <config name="testVersion" value="7.4-"/>
</ruleset>
```

## Theme Template

```xml
<?xml version="1.0"?>
<ruleset name="My Theme">
  <description>PHPCS configuration for My Theme.</description>

  <file>.</file>

  <exclude-pattern>/vendor/*</exclude-pattern>
  <exclude-pattern>/node_modules/*</exclude-pattern>
  <exclude-pattern>/build/*</exclude-pattern>

  <rule ref="WordPress"/>

  <config name="minimum_wp_version" value="6.0"/>

  <rule ref="WordPress.WP.I18n">
    <properties>
      <property name="text_domain" type="array">
        <element value="my-theme"/>
      </property>
    </properties>
  </rule>

  <!-- Themes use different prefixes -->
  <rule ref="WordPress.NamingConventions.PrefixAllGlobals">
    <properties>
      <property name="prefixes" type="array">
        <element value="my_theme"/>
        <element value="MY_THEME"/>
      </property>
    </properties>
  </rule>
</ruleset>
```

## Common Configuration Options

### Exclude Specific Sniffs

```xml
<!-- Allow short array syntax -->
<rule ref="WordPress">
  <exclude name="Generic.Arrays.DisallowShortArraySyntax"/>
</rule>

<!-- Allow file-level comments to be optional -->
<rule ref="Squiz.Commenting.FileComment">
  <exclude name="Squiz.Commenting.FileComment.Missing"/>
</rule>
```

### Adjust Severity

```xml
<!-- Treat specific warnings as errors -->
<rule ref="WordPress.Security.EscapeOutput">
  <type>error</type>
</rule>

<!-- Downgrade specific errors to warnings -->
<rule ref="WordPress.WP.I18n.MissingTranslatorsComment">
  <type>warning</type>
</rule>
```

### Line Length

```xml
<!-- Increase allowed line length -->
<rule ref="Generic.Files.LineLength">
  <properties>
    <property name="lineLimit" value="120"/>
    <property name="absoluteLineLimit" value="200"/>
  </properties>
</rule>
```

### Custom Paths

```xml
<!-- Only scan specific directories -->
<file>./includes</file>
<file>./admin</file>
<file>./public</file>
<file>./my-plugin.php</file>
```

## Running with Configuration

When `phpcs.xml.dist` exists in the project root, PHPCS uses it automatically:

```bash
# Uses phpcs.xml.dist automatically
vendor/bin/phpcs

# Override with a specific standard
vendor/bin/phpcs --standard=WordPress-Extra
```

## Available WordPress Standards

| Standard | Description |
|----------|-------------|
| `WordPress` | Full WordPress standards (recommended) |
| `WordPress-Core` | Core coding style only |
| `WordPress-Extra` | Core + additional best practices |
| `WordPress-Docs` | Documentation standards |
