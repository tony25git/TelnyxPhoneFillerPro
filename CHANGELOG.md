# Phone Filler Pro - Changelog

## Latest Updates (Session Resumed)

### Version 2.3.0 - Background Mode Always On

#### Major Update: Background Mode is Now Always Enabled
- **Permanent Background Mode**: Automation always runs in background without user intervention
  - Removed checkbox - background mode is now the default and only mode
  - No window activation or focus stealing ever occurs
  - Users can always use mouse/keyboard freely during automation
  - Clear UI indicator: "✓ Background Mode: Always ON - Use mouse/keyboard freely"

### Version 2.2.0 - True Background Mode Implementation

#### Major Feature: True Background Automation
- **Background Mode**: Application can now run completely in the background without interrupting mouse/keyboard
  - Uses Windows API PostMessage and ControlClick for background operation
  - Allows users to continue working while automation runs
  - No window focus stealing or mouse/keyboard hijacking

#### Implementation Details
- Added `BackgroundClick()` function using ControlClick and PostMessage for clicks
- Added `BackgroundSendText()` function for text input without focus
- Added `BackgroundSendKey()` function for keyboard shortcuts
- Updated EdgeJavaWorkflow to support background execution
- Updated ChromeLSRWorkflow to support background execution
- Window handles are captured and used for background messaging
- Fallback to regular automation if background methods fail

### Version 2.1.0 - Improvements & Bug Fixes

#### New Features
- **Smart Image Recognition Workflow (Beta)**: Added experimental third workflow type that captures and recognizes UI elements using image matching
  - Captures screenshots of clicked elements during recording
  - Attempts to find elements on screen during playback using image recognition
  - Falls back to original coordinates if image recognition fails
  - Added to workflow dropdown as "Smart Image Recognition (Beta)"

#### Bug Fixes
- **Fixed Image Capture Functions**: Replaced undefined GDI+ functions with PowerShell-based screenshot implementation
  - Removed dependency on external GDI+ library
  - Implemented reliable cross-system screenshot capture
  - Added proper error handling for capture failures

#### Improvements
- **Enhanced Error Handling**: 
  - Added try-catch blocks around critical workflow execution points
  - Workflow continues execution even if individual actions fail
  - Better error messages displayed in status text
  
- **Workflow Validation**: 
  - Added `ValidateWorkflow()` function that checks workflows before playback
  - Validates presence of phone number actions
  - Checks if target windows exist before starting playback
  - Prompts user to continue if validation issues are found

- **Image Search Improvements**:
  - Added variation tolerance levels (0, 10, 20, 30, 50) for image matching
  - More flexible image recognition to handle slight UI changes
  - Fallback mechanism ensures workflow continues even if images aren't found

#### Technical Changes
- Updated `CaptureScreenRegion()` to use PowerShell for reliable screenshot capture
- Enhanced `FindElementByImage()` with multiple variation tolerance attempts
- Added proper path escaping in PowerShell commands
- Improved error recovery in `PlayNextAction()` function

#### Known Issues
- Smart Image Recognition workflow is still experimental and may not work reliably on all systems
- Image matching may be affected by:
  - Screen resolution differences
  - Display scaling settings
  - Theme/color scheme changes
  - Anti-aliasing differences

#### Recommendations
- For production use, continue using Edge/Java Sites or Chrome LSR Sites workflows
- Smart Image Recognition workflow should be tested thoroughly before deployment
- Re-record workflows on target machines for best results

---

## Previous Version History

### Version 2.0.0
- Chrome mode with intelligent row progression
- Automatic field detection and navigation
- Support for Verizon LSI interface

### Version 1.5.0
- Custom phone number formats
- Range support for consecutive numbers
- Format preview functionality

### Version 1.0.0
- Initial release with Edge/Java automation support
- Basic recording and playback functionality
- Phone number formatting options