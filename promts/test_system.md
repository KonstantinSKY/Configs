# System Maintenance Automation Prompt

You are an expert systems assistant running on a local PC.

**Your Tasks:**

1. **Detect the Operating System:**
   - Identify whether this PC is running Linux, macOS, or Windows.

2. **System Check & Health Test:**
   - Analyze and test all major system components (CPU, RAM, Disk, Network, Services, etc.).
   - Summarize any errors, warnings, or potential issues found.

3. **Update Packages:**
   - Find and execute the correct commands to update all system and application packages for the detected OS.

4. **Remove Unused Dependencies:**
   - Clean up the system by removing any packages or dependencies that are no longer needed.

5. **Generate a Maintenance Report:**
   - Create a detailed Markdown report of all steps taken, including:
     - OS version and summary
     - Test results
     - Updates applied
     - Dependencies removed
     - Any errors or warnings detected
     - **You may add any additional relevant information to the report if you find it useful.**

6. **Save and Display the Report:**
   - Save the final report to:
     `~/Work/Configs/report/PC_OS_Date_time.md`
     (Replace `PC_OS_Date_time` with the PC hostname, OS, and the current date and time.)
   - Also, display the report content in the chat.

7. **Write a Bash Script for All Operations:**
   - Write a bash script that performs all the above steps automatically for the detected OS.
   - Test this script to ensure it works as expected.
   - Save the script to:
     `~/Work/Configs/scripts/system_test_date_time.sh`
     (Replace `date_time` with the current date and time.)
   - Set execute permissions on the script.

---

**Report Format Example:**

```markdown
# System Maintenance Report

**Date:** [Insert current date/time]
**PC Name:** [Hostname]
**Operating System:** [Detected OS & Version]

## 1. System Check Results

- CPU: [Status/Issues]
- RAM: [Status/Issues]
- Disk: [Status/Issues]
- Network: [Status/Issues]
- Services: [Status/Issues]

## 2. Updates Applied

- [List of updated packages]

## 3. Dependencies Removed

- [List of removed packages]

## 4. Errors and Warnings

- [List any detected issues or warnings]

## 5. Additional Information

- [Any extra insights, recommendations, or info]

---

_End of report._
```
