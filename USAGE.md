# TelnyxPhoneFillerPro Usage Guide

## Quick Start

1. **Launch the Application**
   - Double-click `TelnyxPhoneFillerPro.ahk`
   - The GUI window will appear

2. **Basic Controls**
   - **Start Button**: Begin the automated workflow
   - **Stop Button**: Immediately halt all operations
   - **Add Step**: Create a new workflow step
   - **Save/Load**: Manage workflow configurations

## Creating Workflows

### Step Types

#### 1. Text Input
- **Purpose**: Enter text into form fields
- **Configuration**: 
  - Set delay before action
  - Enter the text to input
  - Optionally add Tab key after input

#### 2. Click Actions
- **Purpose**: Click on screen elements
- **Configuration**:
  - Choose click position (use "Get Position" helper)
  - Set delay before click
  - Optional: Add multiple clicks

#### 3. Key Press
- **Purpose**: Send keyboard shortcuts
- **Configuration**:
  - Select key combination
  - Set delay before action
  - Common: Tab, Enter, Escape

#### 4. Wait/Delay
- **Purpose**: Pause between actions
- **Configuration**:
  - Set wait time in milliseconds
  - Useful for page loads

## Workflow Management

### Saving Workflows
1. Create your workflow steps
2. Click "Save Workflow"
3. Choose a descriptive name
4. File saved in `Workflows Saved` folder

### Loading Workflows
1. Click "Load Workflow"
2. Select from saved workflows
3. Steps will populate in the GUI
4. Modify if needed before running

### Editing Workflows
- Double-click any step to edit
- Use up/down arrows to reorder
- Delete button removes selected step

## Advanced Features

### Position Capture
1. Click "Get Position"
2. Move mouse to target location
3. Press Space to capture coordinates
4. Coordinates auto-fill in step configuration

### Loop Settings
- Set number of iterations
- Add delays between loops
- Useful for repetitive data entry

### Conditional Actions
- Skip steps based on conditions
- Useful for dynamic forms
- Configure in step settings

## Keyboard Shortcuts

- **F1**: Start workflow
- **F2**: Stop workflow
- **F3**: Pause/Resume
- **F4**: Open settings
- **Escape**: Emergency stop

## Tips and Best Practices

1. **Test First**: Always test workflows on sample data
2. **Add Delays**: Include appropriate delays for page loads
3. **Save Often**: Save working workflows for reuse
4. **Use Comments**: Add descriptions to complex steps
5. **Monitor Execution**: Watch the first run to ensure accuracy

## Troubleshooting

### Workflow Not Running
- Check if AutoHotkey v2 is installed
- Verify all steps have required fields filled
- Ensure target application is in focus

### Clicks Missing Target
- Recapture position if window moved
- Check screen resolution hasn't changed
- Add small delay before click actions

### Text Not Entering
- Verify field is active/focused
- Add click action before text input
- Check for special character restrictions

### Application Crashes
- Reduce action speed with longer delays
- Check for memory issues
- Restart both applications

## Common Workflows

### Data Entry
1. Click first field
2. Enter text
3. Tab to next field
4. Repeat for all fields
5. Click submit button

### Form Navigation
1. Wait for page load
2. Click dropdown
3. Select option
4. Tab through fields
5. Submit form

### Bulk Processing
1. Set loop count
2. Enter data
3. Submit
4. Wait for confirmation
5. Click "New Entry"
6. Loop repeats

## Support

For issues or questions:
- Check the troubleshooting section
- Review saved workflow examples
- Submit an issue on GitHub