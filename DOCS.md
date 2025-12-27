# RaptrAI Documentation

This guide explains how to work on the RaptrAI documentation site.

## Documentation Repository

The documentation lives in a separate repository:
- **Repo**: [github.com/aliarain/raptrai-docs](https://github.com/aliarain/raptrai-docs)
- **Live Site**: [raptrai.raptrx.com](https://raptrai.raptrx.com) (once deployed)

## Tech Stack

- **Framework**: [Mintlify](https://mintlify.com) v4
- **Content**: MDX (Markdown + JSX)
- **Deployment**: Vercel
- **Theme**: Custom blue theme matching RaptrAI branding

## Getting Started

### Prerequisites

- Node.js 18-24 (Mintlify doesn't support Node 25+)
- npm or yarn

### Clone and Setup

```bash
# Clone the docs repo
git clone https://github.com/aliarain/raptrai-docs.git
cd raptrai-docs

# Use Node LTS if you have nvm
nvm use --lts

# Install dependencies
npm install

# Start dev server
npm run dev
```

The docs will be available at http://localhost:3000

## Project Structure

```
raptrai-docs/
├── docs.json              # Mintlify configuration
├── package.json           # npm scripts
├── vercel.json            # Vercel deployment config
├── introduction.mdx       # Home page
├── quickstart.mdx         # Quick start guide
├── installation.mdx       # Installation instructions
├── essentials/            # Core concepts
│   ├── providers.mdx      # AI Provider integration
│   ├── conversation.mdx   # Conversation management
│   ├── tools.mdx          # Tool/Function calling
│   ├── persistence.mdx    # Storage layer
│   └── theming.mdx        # Theme customization
├── components/            # UI Components
│   ├── overview.mdx       # Components overview
│   ├── raptrai-chat.mdx   # RaptrAIChat widget
│   ├── thread.mdx         # Thread components
│   ├── composer.mdx       # Composer components
│   ├── message.mdx        # Message components
│   └── tool-ui.mdx        # Tool UI components
├── features/              # Features
│   ├── usage-tracking.mdx # Usage & cost tracking
│   ├── analytics.mdx      # Analytics integration
│   └── offline-support.mdx# Offline-first support
├── api-reference/         # API Reference
│   ├── introduction.mdx   # API overview
│   ├── providers.mdx      # Provider classes
│   ├── conversation.mdx   # Conversation classes
│   ├── storage.mdx        # Storage classes
│   └── widgets.mdx        # Widget classes
├── logo/                  # Logo assets
│   ├── dark.svg
│   └── light.svg
├── images/                # Documentation images
└── favicon.svg            # Favicon
```

## Configuration

### docs.json

The main configuration file for Mintlify:

```json
{
  "name": "RaptrAI",
  "colors": {
    "primary": "#3B82F6",
    "light": "#60A5FA",
    "dark": "#1D4ED8"
  },
  "navigation": {
    "tabs": [...],
    "global": {
      "anchors": [...]
    }
  },
  "footer": {
    "socials": {
      "x": "https://x.com/realaliarain",
      "github": "https://github.com/aliarain/raptrai"
    }
  }
}
```

## Writing Documentation

### MDX Format

Each page is an MDX file with frontmatter:

```mdx
---
title: 'Page Title'
description: 'Brief description for SEO'
icon: 'icon-name'
---

# Content here

Use markdown with optional JSX components.
```

### Code Examples

Use fenced code blocks with language:

````mdx
```dart
final provider = RaptrAIOpenAI(apiKey: 'sk-...');
```
````

### Callouts

```mdx
<Note>This is a note</Note>
<Warning>This is a warning</Warning>
<Info>This is info</Info>
<Tip>This is a tip</Tip>
```

### Cards

```mdx
<CardGroup cols={2}>
  <Card title="Card 1" icon="icon-name" href="/link">
    Description
  </Card>
  <Card title="Card 2" icon="icon-name" href="/link">
    Description
  </Card>
</CardGroup>
```

## Adding New Pages

1. Create a new `.mdx` file in the appropriate folder
2. Add frontmatter with title and description
3. Add the page path to `docs.json` navigation
4. Write content using MDX

Example:

```bash
# Create new page
touch essentials/new-feature.mdx
```

```mdx
---
title: 'New Feature'
description: 'Learn about the new feature'
---

# New Feature

Content here...
```

Update `docs.json`:
```json
{
  "group": "Essentials",
  "pages": [
    "essentials/providers",
    "essentials/new-feature"  // Add here
  ]
}
```

## Deployment

### Vercel (Recommended)

1. Push changes to GitHub
2. Connect repo to Vercel
3. Vercel auto-deploys on push

The `vercel.json` is pre-configured:
```json
{
  "buildCommand": "npx mintlify build",
  "outputDirectory": ".mintlify",
  "installCommand": "npm install"
}
```

### Manual Build

```bash
npm run build
```

Output will be in `.mintlify/` directory.

## Current Status

### Completed Pages

- [x] Introduction
- [x] Quickstart
- [x] Installation
- [x] Essentials (5 pages)
- [x] Components (6 pages)
- [x] Features (3 pages)
- [x] API Reference (5 pages)

### TODO / Improvements

- [ ] Add more code examples to each page
- [ ] Add screenshots/GIFs of components
- [ ] Create interactive examples
- [ ] Add migration guide from other libraries
- [ ] Add troubleshooting section
- [ ] Add FAQ page
- [ ] Improve API reference with full method signatures
- [ ] Add search functionality testing
- [ ] Create changelog page synced with package

## Contributing

1. Fork the docs repo
2. Create a feature branch
3. Make changes
4. Test locally with `npm run dev`
5. Submit a PR

## Resources

- [Mintlify Documentation](https://mintlify.com/docs)
- [MDX Documentation](https://mdxjs.com/)
- [RaptrAI Package](https://github.com/aliarain/raptrai)
- [Vercel Deployment](https://vercel.com/docs)

## Contact

- Twitter: [@realaliarain](https://x.com/realaliarain)
- GitHub: [aliarain/raptrai](https://github.com/aliarain/raptrai)
