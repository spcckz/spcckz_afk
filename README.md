# vojtik_afk
Afk player status for fivem servers

## Installation ##
1) Download resource using Clone or anything else (does not matter as long as it's working)
2) Start the resource in server.cfg
3) Start/Restart your server

## Thread link with preview ##
[Click me!](https://forum.cfx.re/t/standalone-vojtik-afk-afk-on-server-with-style/3438848?u=vjota2)


### Features for the forked version of the AFK Detection Script
This fork enhances the AFK script with several improvements:

**1. Customizable AFK Timeout:**  
- The AFK timeout is set to **5 minutes**.  
- You can easily adjust this to suit your server's needs.

**2. Accurate AFK Timer Display:**  
- The displayed AFK timer now includes the **initial timeout period**, showing the total time the player has been inactive.  

**3. Improved Visual Indicators:**  
- The text and marker displays are enhanced for **clearer readability** and easier recognition of AFK status.

**4. Reliable AFK State Management:**  
- The AFK start time is only set **once** when a player becomes AFK, preventing unnecessary resets.  

**5. Optimized Thread Management:**  
- Tasks like detecting player movement, updating AFK status, and displaying text/markers are now handled by separate threads for better performance.

These updates ensure the AFK detection system is more accurate, efficient, and user-friendly.

