# Monitor Resolution Setup for Manjaro i3

This guide will help you fix monitor resolution issues in your Manjaro i3 setup.

## Current Issue
Your monitors are running at very low resolutions:
- DisplayPort-0: 640x480 (supports up to 4K 3840x2160)
- DisplayPort-1: 640x480 (appears to only support this resolution)

## Quick Fix

### Option 1: Run the Fix Script
```bash
cd ~/Work/Configs
./scripts/fix-resolution.sh
```

### Option 2: Manual Fix
Run these commands to immediately fix your primary monitor:
```bash
# Set primary monitor to 1920x1080
xrandr --output DisplayPort-0 --primary --mode 1920x1080 --pos 0x0 --rotate normal

# For 2K resolution (2560x1440)
xrandr --output DisplayPort-0 --primary --mode 2560x1440 --pos 0x0 --rotate normal

# For 4K resolution (3840x2160)
xrandr --output DisplayPort-0 --primary --mode 3840x2160 --pos 0x0 --rotate normal
```

## Making Changes Permanent

### Method 1: Using i3 Config (Recommended)
The monitor configuration is already included in your i3 config. To apply changes:

1. Copy the monitor config to your home directory:
   ```bash
   mkdir -p ~/.config/i3/monitor
   cp ~/Work/Configs/.config/i3/monitor/monitor.conf ~/.config/i3/monitor/
   ```

2. Reload i3: Press `Mod+Shift+R`

### Method 2: Edit the Monitor Config
Edit `~/.config/i3/monitor/monitor.conf` and uncomment your preferred resolution:

```bash
# For 1080p (default)
exec --no-startup-id xrandr --output DisplayPort-0 --primary --mode 1920x1080 --pos 0x0 --rotate normal

# For 2K
# exec --no-startup-id xrandr --output DisplayPort-0 --primary --mode 2560x1440 --pos 0x0 --rotate normal

# For 4K
# exec --no-startup-id xrandr --output DisplayPort-0 --primary --mode 3840x2160 --pos 0x0 --rotate normal
```

## Using the Display Setup Script

I've created an interactive script for easier configuration:

```bash
cd ~/Work/Configs
./scripts/display_setup.sh
```

This script provides:
1. List all available displays and resolutions
2. Quick fixes for common resolutions
3. Dual monitor setup options
4. Custom resolution configuration
5. Save current configuration to i3

## Troubleshooting

### If Resolution Resets After Reboot
1. Make sure the monitor config is in the correct location:
   ```bash
   ls ~/.config/i3/monitor/monitor.conf
   ```

2. Check that your i3 config includes it:
   ```bash
   grep "include.*monitor.conf" ~/.config/i3/config
   ```

3. If the include line is missing, add it to your i3 config:
   ```
   include ~/.config/i3/monitor/monitor.conf
   ```

### DisplayPort-1 Limited to 640x480
Your DisplayPort-1 seems to only support 640x480. This could be due to:
- Cable limitations (try a different cable)
- Monitor not properly detected
- GPU driver issues

You can disable it if not needed:
```bash
xrandr --output DisplayPort-1 --off
```

### DPI Scaling Issues
For 4K displays, you might need to adjust DPI:
```bash
# For 4K displays (144 DPI)
xrandr --dpi 144

# For 1080p/1440p displays (96 DPI)
xrandr --dpi 96
```

Add the DPI setting to your monitor.conf file to make it permanent.

## Available Resolutions for Your Setup

### DisplayPort-0 (Primary)
- 3840x2160 (4K) @ 60Hz
- 2560x1440 (2K) @ 75Hz
- 1920x1080 (Full HD) @ 60Hz
- 1680x1050 @ 60Hz
- 1600x900 @ 60Hz
- 1280x1024 @ 75Hz
- 1280x720 @ 60Hz

### DisplayPort-1
- 640x480 @ 60Hz (only available resolution)

## Additional Commands

### Check Current Configuration
```bash
xrandr --current
```

### List All Available Modes
```bash
xrandr
```

### Position Monitors
```bash
# Side by side (secondary on right)
xrandr --output DisplayPort-0 --primary --mode 1920x1080 --pos 0x0
xrandr --output DisplayPort-1 --mode 640x480 --pos 1920x0

# Secondary on left
xrandr --output DisplayPort-1 --mode 640x480 --pos 0x0
xrandr --output DisplayPort-0 --primary --mode 1920x1080 --pos 640x0
```

## Files Created

- `~/.config/i3/monitor/monitor.conf` - i3 monitor configuration
- `~/Work/Configs/scripts/fix-resolution.sh` - Quick fix script
- `~/Work/Configs/scripts/display_setup.sh` - Interactive setup script

Remember to reload i3 (`Mod+Shift+R`) after making configuration changes!
