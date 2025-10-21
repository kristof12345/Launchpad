# Widgets Feature

## Overview

The widgets feature allows users to add customizable, interactive widgets to their Launchpad pages. Widgets can be rearranged through drag-and-drop, just like apps and folders, and their layout persists across app restarts.

## Supported Widget Types

### Clock Widget
- **Size Options**: Small, Medium, Large
- **Features**: Displays current time and date
- **Updates**: Real-time, updates every second

### Calendar Widget (Coming Soon)
- **Size Options**: Small, Medium, Large
- **Features**: Displays current month and date

### Weather Widget (Coming Soon)
- **Size Options**: Small, Medium, Large
- **Features**: Shows current weather conditions

### Notes Widget (Coming Soon)
- **Size Options**: Small, Medium, Large
- **Features**: Quick notes display

## Widget Sizes

Widgets come in three sizes that determine how much grid space they occupy:

- **Small**: 1x1 grid cells
- **Medium**: 2x2 grid cells
- **Large**: 3x3 grid cells

## Adding Widgets

1. Open Launchpad Settings (CMD + ,)
2. Navigate to the "Widgets" tab
3. Select the widget type you want to add
4. Choose the desired size
5. Click "Add Widget"
6. The widget will be added to the first page

## Managing Widgets

### Rearranging Widgets
- Drag and drop widgets to move them between pages
- Widgets can be mixed with apps and folders
- Widgets cannot be added to folders

### Removing Widgets
- Right-click on a widget
- Select "Remove Widget" from the context menu

## Technical Implementation

### Architecture

The widgets feature is built on top of the existing grid item system:

1. **Widget Model** (`Widget.swift`): Defines widget properties including type, size, configuration
2. **AppGridItem Extension**: Widgets are a case in the `AppGridItem` enum alongside apps and folders
3. **WidgetView**: SwiftUI view component that renders different widget types
4. **Persistence**: Widgets are serialized and saved with the grid layout

### Drag and Drop Support

Widgets integrate seamlessly with the existing drag-and-drop system:
- Can be dragged to any position on any page
- Cannot be combined into folders
- Support page overflow handling

### Serialization Format

Widgets are serialized as JSON with the following structure:

```json
{
  "type": "widget",
  "id": "UUID-STRING",
  "name": "Widget Name",
  "widgetType": "clock",
  "size": "medium",
  "page": 0,
  "configuration": {
    "key": "value"
  }
}
```

## Future Enhancements

Potential future improvements:

1. **More Widget Types**: System monitor, calendar events, quick notes
2. **Widget Configuration**: Custom settings for each widget type
3. **Widget Interaction**: Interactive widgets with buttons and controls
4. **Live Data**: Integration with system APIs for real data
5. **Custom Widgets**: Plugin system for third-party widgets
