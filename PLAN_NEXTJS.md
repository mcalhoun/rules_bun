# Plan: Next.js Support for rules_bun

This document outlines the plan for extending `rules_bun` to provide first-class support for Next.js applications using Bun as the runtime and build tool.

## Overview

Next.js is a popular React framework that provides server-side rendering (SSR), static site generation (SSG), API routes, and optimized production builds. This plan extends `rules_bun` to support building, testing, and running Next.js applications with Bun, leveraging Bun's fast runtime and package manager.

## Goals

1. Support Next.js development server with Bun
2. Support Next.js production builds with Bun
3. Handle Next.js-specific features (pages, app directory, API routes, static assets)
4. Integrate with Bazel's build system for incremental builds and caching
5. Support both Pages Router and App Router (Next.js 13+)
6. Enable static exports and deployment configurations

## Architecture

### New Rules

#### nextjs_app
Main rule for defining a Next.js application. Handles the complete application lifecycle.

**Attributes:**
- `srcs`: Source files (pages, app, components, etc.)
- `deps`: Dependencies (npm packages, local modules)
- `next_config`: next.config.js file
- `package_json`: package.json file
- `public_dir`: Public directory for static assets
- `output_mode`: "standalone" | "export" | "default"
- `env`: Environment variables
- `base_path`: Base path for the application
- `asset_prefix`: Asset prefix for CDN deployment

**Outputs:**
- Development server executable
- Production build artifacts
- Static export (if configured)

#### nextjs_dev
Rule for running Next.js development server with Bun.

**Attributes:**
- `app`: Reference to nextjs_app target
- `port`: Development server port (default: 3000)
- `hostname`: Hostname to bind to
- `turbo`: Enable Turbopack (Next.js 13+)

#### nextjs_build
Rule for building Next.js application for production.

**Attributes:**
- `app`: Reference to nextjs_app target
- `output_mode`: Build output mode
- `standalone`: Generate standalone build
- `optimize`: Enable optimizations

**Outputs:**
- `.next/` directory with build artifacts
- Standalone server (if configured)
- Static export (if configured)

#### nextjs_start
Rule for running Next.js production server.

**Attributes:**
- `app`: Reference to nextjs_app target
- `port`: Server port
- `hostname`: Hostname to bind to

#### nextjs_export
Rule for static export of Next.js application.

**Attributes:**
- `app`: Reference to nextjs_app target
- `out_dir`: Output directory for static files

## Implementation Details

### File Structure Support

Next.js applications can use either the Pages Router or App Router:

**Pages Router:**
```
app/
├── pages/
│   ├── index.js
│   ├── about.js
│   └── api/
│       └── hello.js
├── components/
├── public/
├── next.config.js
└── package.json
```

**App Router (Next.js 13+):**
```
app/
├── app/
│   ├── page.js
│   ├── layout.js
│   └── api/
│       └── route.js
├── components/
├── public/
├── next.config.js
└── package.json
```

### Build Process

1. **Dependency Installation**
   - Use `bun_install` to install npm packages
   - Handle Next.js peer dependencies
   - Install React, React DOM, and Next.js

2. **Next.js Build**
   - Run `bun next build` for production builds
   - Run `bun next dev` for development
   - Handle static optimization
   - Process images, fonts, and other assets

3. **Output Generation**
   - Generate `.next/` directory with build artifacts
   - Create standalone server (if configured)
   - Generate static export (if configured)

### Integration with Existing Rules

- **bun_install**: Install Next.js and dependencies
- **bun_build**: Bundle Next.js components (if needed)
- **bun_test**: Run Next.js tests with Bun's test runner

### Next.js-Specific Features

#### Pages Router Support
- Automatic route detection from `pages/` directory
- API routes from `pages/api/`
- Dynamic routes (`[id].js`, `[...slug].js`)
- Middleware support

#### App Router Support (Next.js 13+)
- Route handlers from `app/` directory
- Server Components and Client Components
- Layouts and templates
- Streaming SSR

#### Static Assets
- Public directory handling
- Image optimization (next/image)
- Font optimization
- Static file serving

#### API Routes
- Serverless function generation
- Edge runtime support
- Middleware execution

## File Structure

```
bun/
├── internal/
│   ├── nextjs_app.bzl          # Main Next.js app rule
│   ├── nextjs_dev.bzl          # Development server rule
│   ├── nextjs_build.bzl        # Production build rule
│   ├── nextjs_start.bzl        # Production server rule
│   ├── nextjs_export.bzl       # Static export rule
│   └── nextjs_utils.bzl        # Helper functions
└── bun.bzl                     # Updated public API
```

## Examples

### Basic Next.js App

```starlark
load("@rules_bun//bun:bun.bzl", "nextjs_app", "nextjs_dev", "nextjs_build")

nextjs_app(
    name = "app",
    srcs = glob([
        "pages/**/*.js",
        "pages/**/*.jsx",
        "components/**/*.js",
        "components/**/*.jsx",
    ]),
    package_json = "package.json",
    next_config = "next.config.js",
    public_dir = "public",
    deps = [
        "//:node_modules",
    ],
)

nextjs_dev(
    name = "dev",
    app = ":app",
    port = 3000,
)

nextjs_build(
    name = "build",
    app = ":app",
    output_mode = "standalone",
)
```

### App Router Example

```starlark
nextjs_app(
    name = "app",
    srcs = glob([
        "app/**/*.js",
        "app/**/*.jsx",
        "app/**/*.ts",
        "app/**/*.tsx",
        "components/**/*.js",
        "components/**/*.jsx",
    ]),
    package_json = "package.json",
    next_config = "next.config.js",
    public_dir = "public",
)
```

### Static Export

```starlark
nextjs_app(
    name = "app",
    # ... app configuration
    output_mode = "export",
)

nextjs_export(
    name = "export",
    app = ":app",
    out_dir = "out",
)
```

## Testing Strategy

### Unit Tests
- Test Next.js app rule implementation
- Test build process
- Test route detection
- Test asset handling

### Integration Tests
- Full Next.js app build and run
- Pages Router example
- App Router example
- API routes testing
- Static export testing
- Development server testing

### Example Projects
- `examples/nextjs/pages-router/`: Pages Router example
- `examples/nextjs/app-router/`: App Router example
- `examples/nextjs/api-routes/`: API routes example
- `examples/nextjs/static-export/`: Static export example
- `examples/nextjs/full-app/`: Complete Next.js application

## Dependencies

### Required npm Packages
- `next`: Next.js framework
- `react`: React library
- `react-dom`: React DOM library

### Optional Dependencies
- `@next/bundle-analyzer`: Bundle analysis
- `next-pwa`: PWA support
- `@next/env`: Environment variable handling

## Configuration Files

### next.config.js Support
- Handle Next.js configuration
- Support for custom webpack config (if needed)
- Support for experimental features
- Image optimization settings
- Output configuration

### package.json Integration
- Scripts for dev, build, start, export
- Dependencies management
- Peer dependencies handling

## Build Modes

### Development Mode
- Fast refresh
- Source maps
- Development optimizations
- Hot module replacement

### Production Mode
- Code splitting
- Tree shaking
- Minification
- Static optimization
- Image optimization

### Standalone Mode
- Self-contained server
- Minimal dependencies
- Docker-friendly output

### Static Export Mode
- Static HTML generation
- No server required
- CDN deployment ready

## Performance Considerations

1. **Incremental Builds**
   - Leverage Bazel's caching for unchanged files
   - Only rebuild changed pages/routes
   - Cache Next.js build artifacts

2. **Parallel Execution**
   - Build pages in parallel
   - Process assets concurrently
   - Optimize dependency resolution

3. **Bun Performance**
   - Fast package installation
   - Quick runtime execution
   - Efficient bundling

## Migration Path

### From rules_nodejs
1. Replace `nodejs_binary` with `bun_binary`
2. Update package installation to use `bun_install`
3. Replace Next.js build commands with `nextjs_build`

### From Standard Next.js
1. Add Bazel BUILD files
2. Configure `nextjs_app` rule
3. Update build scripts to use Bazel

## Documentation

### User Guide
- Getting started with Next.js and rules_bun
- Configuration options
- Build modes explanation
- Deployment strategies

### API Reference
- Rule attributes documentation
- Configuration examples
- Troubleshooting guide

## Implementation Phases

### Phase 1: Core Rules
- [ ] Implement `nextjs_app` rule
- [ ] Implement `nextjs_build` rule
- [ ] Basic Pages Router support
- [ ] Basic static asset handling

### Phase 2: Development & Production
- [ ] Implement `nextjs_dev` rule
- [ ] Implement `nextjs_start` rule
- [ ] Production build optimizations
- [ ] Standalone build support

### Phase 3: Advanced Features
- [ ] App Router support
- [ ] API routes support
- [ ] Static export support
- [ ] Image optimization

### Phase 4: Testing & Examples
- [ ] Unit tests for all rules
- [ ] Integration tests
- [ ] Example projects
- [ ] Documentation

## Success Criteria

1. ✅ Can build a Next.js app with Bazel
2. ✅ Can run Next.js dev server with Bun
3. ✅ Can build production Next.js app
4. ✅ Supports both Pages Router and App Router
5. ✅ Handles static assets correctly
6. ✅ Supports API routes
7. ✅ Can generate static exports
8. ✅ Integrates with Bazel's caching and incremental builds
9. ✅ Has comprehensive examples and documentation

## Future Enhancements

- Turbopack support (Next.js 13+)
- Edge runtime optimization
- Middleware support
- ISR (Incremental Static Regeneration) support
- Custom server support
- Docker image generation
- Kubernetes deployment configs

