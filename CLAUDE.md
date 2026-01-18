# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

FileBrowser is a Swift Package Manager library that provides a cross-platform (iOS, macOS, watchOS) file browsing interface built with SwiftUI. It allows developers to embed a native file browser into their apps with customizable options and file handling capabilities.

## Build Commands

```bash
# Build the package
swift build

# Run tests
swift test

# Build for release
swift build -c release
```

## Architecture

### Core Components

**FileBrowserScreen** (`FileBrowserScreen.swift`) - The main entry point and container view
- Generic over `FileHandlerView` to allow custom file handling UI
- Supports single or multiple root directories via `FileBrowserDirectory` protocol
- Uses `NavigationStack` with `NavigationPath` for directory traversal
- Environment-based configuration system using `FileBrowserViewOption` and custom environment keys

**FileBrowserDirectory Struct** (`FileBrowserDirectory.swift`) - Concrete type for directory representation
- Simple struct wrapping URL with optional custom title
- Replaces previous protocol-based approach to eliminate type erasure overhead
- URL extension provides `.asDirectory` convenience property

**DirectoryView** (`FileBrowserScreen.DirectoryView.swift`) - Displays directory contents
- Loads directory items asynchronously using `Task.detached`
- Handles file deletion with error collection
- Sorts items with hidden files (starting with ".") at the bottom
- Shows appropriate states: loading, empty directory, error list

**FileDetailsView** (`FileBrowserScreen.FileDetailsView.swift`) - File detail view with tabs
- Three built-in tabs: Metadata, Contents, and Data
- Extensible via `FileBrowserFileFormat` protocol for custom file type viewers
- Tab selection persisted via `@AppStorage`

**DirectoryTabs** (`DirectoryTabs.swift`) - Tab switcher for multiple root directories
- Only displayed when multiple roots are provided to `FileBrowserScreen`
- Manages selection between different root directories

### File Format Extension System

The library supports custom file viewers through the `FileBrowserFileFormat` protocol:
- Register custom formatters with `registerFileBrowserView(format:)`
- Implement `init(url:)` and `contentView` property
- Formatters are looked up by file extension

### Environment-Based Configuration

Uses SwiftUI environment system for passing configuration down the view hierarchy:
- `fileBrowserOptions` - `FileBrowserViewOption` OptionSet for features like deletion, sharing, hidden files
- `fileHandlerForFile` - Closure to provide custom UI for specific files
- `dismissParent` - Closure to dismiss the entire file browser

### File Handling Options

`FileBrowserViewOption` (`FileBrowser.Options.swift`):
- `.allowFileDeletion` - Enable swipe-to-delete in lists
- `.allowFileSharing` - Show share buttons
- `.showClearDirectoryButton` - Show toolbar button to clear entire directory
- `.showHiddenFiles` - Display hidden files (starting with ".")
- `.allowFileViewing` - Show view buttons for files

### Custom File Handler Pattern

`FileBrowserScreen` accepts an optional `@ViewBuilder fileHandler` closure:
```swift
FileBrowserScreen(rootURL: url) { directory, placement in
    // Custom view for specific files
    // directory is a FileBrowserDirectory
    // placement is either .list or .details
}
```

When `FileHandlerView == EmptyView`, convenience initializers are provided without the fileHandler parameter:
```swift
// Simple usage with URL
FileBrowserScreen(rootURL: someURL)

// With custom title
FileBrowserScreen(root: FileBrowserDirectory(url: someURL, title: "Custom Title"))

// Multiple roots
FileBrowserScreen(rootURLs: [url1, url2])
```

## Dependencies

- **Suite** (ios-tooling/Suite) - Utility extensions and helpers
- **CrossPlatformKit** (ios-tooling/CrossPlatformKit) - Cross-platform abstraction layer
- Both dependencies use semantic versioning

## File Structure

```
Sources/FileBrowser/
├── FileBrowserScreen.swift                      # Main container view
├── FileBrowserDirectory.swift                   # Directory protocol
├── FileBrowser.Options.swift                    # Configuration options
├── DirectoryTabs.swift                          # Multi-root tab switcher
├── FileBrowserScreen.DirectoryView.swift        # Directory listing
├── FileBrowserScreen.DirectoryView.DirectoryRow.swift
├── FileBrowserScreen.DirectoryView.FileRow.swift
├── FileBrowserScreen.FileDetailsView.swift      # File detail tabs
├── FileBrowser.FileDetailsView.MetadataView.swift
├── FileBrowser.FileDetailsView.ContentsView.swift
├── FileBrowser.FileDetailsView.DataView.swift
├── FileBrowserScreen.FileFormat.swift           # File format protocol
├── MovieViewer.swift                            # Video file viewer
├── ShareFileButton.swift                        # Share functionality
└── ViewFileButton.swift                         # Quick Look integration
```

## Platform Support

- macOS 13+
- iOS 16+
- watchOS 8+

All UI code uses SwiftUI with platform-specific modifiers wrapped in `#if os()` conditionals where needed.

## Recent Architectural Changes

**Type Erasure Removal (January 2026)**: The codebase was refactored to replace the `FileBrowserDirectory` protocol with a concrete struct. This change:
- Eliminated all existential type overhead (`any FileBrowserDirectory`)
- Removed the dangerous global `==` operator
- Improved performance by removing heap allocations and dynamic dispatch
- Simplified the codebase and improved NavigationPath integration

See `TYPE_ERASURE_MIGRATION.md` for detailed migration guide and rationale.
