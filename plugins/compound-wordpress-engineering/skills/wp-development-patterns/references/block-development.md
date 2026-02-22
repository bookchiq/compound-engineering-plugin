# Block Development Quick Reference

## block.json Schema (Required Fields)

```json
{
  "$schema": "https://schemas.wp.org/trunk/block.json",
  "apiVersion": 3,
  "name": "my-plugin/my-block",
  "version": "1.0.0",
  "title": "My Block",
  "category": "widgets",
  "icon": "smiley",
  "description": "A custom block.",
  "textdomain": "my-plugin",
  "attributes": {},
  "supports": {
    "html": false,
    "color": { "background": true, "text": true },
    "spacing": { "margin": true, "padding": true },
    "typography": { "fontSize": true }
  },
  "editorScript": "file:./index.js",
  "editorStyle": "file:./index.css",
  "style": "file:./style-index.css",
  "viewScript": "file:./view.js",
  "render": "file:./render.php"
}
```

## Block Registration (PHP)

```php
add_action( 'init', function() {
    register_block_type( __DIR__ . '/build/my-block' );
});
```

## Block Registration (JS)

```javascript
import { registerBlockType } from '@wordpress/blocks';
import metadata from './block.json';
import Edit from './edit';
import save from './save';

registerBlockType( metadata, { edit: Edit, save } );
```

## Edit Component

```javascript
import { useBlockProps, RichText, InspectorControls } from '@wordpress/block-editor';
import { PanelBody, TextControl, ToggleControl } from '@wordpress/components';

export default function Edit( { attributes, setAttributes } ) {
    const blockProps = useBlockProps();
    return (
        <>
            <InspectorControls>
                <PanelBody title="Settings">
                    <ToggleControl
                        label="Show border"
                        checked={ attributes.showBorder }
                        onChange={ ( val ) => setAttributes( { showBorder: val } ) }
                    />
                </PanelBody>
            </InspectorControls>
            <div { ...blockProps }>
                <RichText
                    tagName="p"
                    value={ attributes.content }
                    onChange={ ( content ) => setAttributes( { content } ) }
                    placeholder="Enter text..."
                />
            </div>
        </>
    );
}
```

## Save Component

```javascript
import { useBlockProps, RichText } from '@wordpress/block-editor';

export default function save( { attributes } ) {
    const blockProps = useBlockProps.save();
    return (
        <div { ...blockProps }>
            <RichText.Content tagName="p" value={ attributes.content } />
        </div>
    );
}
```

## Dynamic Block (Server-Side Rendering)

```php
// render.php (referenced in block.json as "render": "file:./render.php")
<?php
$wrapper_attributes = get_block_wrapper_attributes();
?>
<div <?php echo $wrapper_attributes; ?>>
    <?php echo esc_html( $attributes['content'] ?? '' ); ?>
</div>
```

## Deprecations

```javascript
const deprecated = [
    {
        attributes: {
            content: { type: 'string', source: 'html', selector: 'p' },
            // OLD attribute schema
        },
        save( { attributes } ) {
            // Return the EXACT old save output
            return <p>{ attributes.content }</p>;
        },
        migrate( oldAttributes ) {
            return { ...oldAttributes, newAttribute: 'default' };
        },
    },
];
```

## InnerBlocks

```javascript
import { useBlockProps, useInnerBlocksProps } from '@wordpress/block-editor';

export default function Edit() {
    const blockProps = useBlockProps();
    const innerBlocksProps = useInnerBlocksProps( blockProps, {
        allowedBlocks: [ 'core/paragraph', 'core/heading', 'core/image' ],
        template: [ [ 'core/paragraph', { placeholder: 'Content...' } ] ],
        templateLock: false,
    });
    return <div { ...innerBlocksProps } />;
}
```

## Build Toolchain

```bash
# Install
npm install @wordpress/scripts --save-dev

# Development (with hot reload)
npx wp-scripts start

# Production build
npx wp-scripts build

# Lint
npx wp-scripts lint-js
npx wp-scripts lint-style
```

## Attribute Types

| Type | Source | Example |
|------|--------|---------|
| `string` | `html` | Rich text content |
| `string` | `attribute` | HTML attribute value |
| `string` | `text` | Plain text content |
| `boolean` | — | Toggle settings |
| `number` | — | Numeric values |
| `array` | — | Lists of items |
| `object` | — | Complex structured data |
