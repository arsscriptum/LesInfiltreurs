# Windows Event Thread Suspender with Automatic Privileges Escalation

This is basically the same general idea that was explained in the the project [Phant0m](https://github.com/hlldz/Phant0m),
except that in phantom, the code doesn't work and it tries to f^ck a fly with an elephant's d (overcomplicated/kill).

## Service Failure Actions Properties

A service Failure Operation allows you to set failure actions for a service which is experiencing errors.

In my code , call this:

    system("sc failure EventLog reset= 86400 actions= //15000//30000//1000");

This set the service to take no actions on failures.
<p align="center"><img src="https://github.com/arsscriptum/WinEventBlocker/blob/main/data/recovery.png" alt="Bug" width="200"></p>



# USEFULL TOOL

Thread Status Monitor is a software tool that monitors the status of each thread in your software, reporting information about each thread as it executes.

Thread Status Monitor is a non-invasive tool, causing no side effects while monitoring your software. Because Thread Status Monitor is non-invasive Thread Status Monitor can only report status information and cannot report callstacks f

https://www.softwareverify.com/dl/a55e563fd6e994767c4b3861d8d71e4bLD1ZHw/ThreadStatusSetup_x64x86.exe
https://www.softwareverify.com/dl/a55e563fd6e994767c4b3861d8d71e4bLD1ZHw/ThreadStatusSetup_x64x86.zip

# REFERENCES

### Remember that SUSPENDING THREADS will HANG PROCESSES that wants to log events.

Note that while the system won't log any events, any piece of code that actually tries to log some stuff will hang when they try to add an event. This is not an issue most of the time, but it is noticeable when the user SHUTs the computer OFF, because the OS logs that. So the shutdown procedure is very long. That's why I added a RESUME parameter that can be called before the user lgs out.

<p align="center"><img src="https://github.com/arsscriptum/WinEventBlocker/blob/main/data/Anim.gif" alt="Poc" width="800"></p>


# Notes on Phantom

[Notes on Phantom](https://github.com/arsscriptum/WinEventBlocker/blob/main/NOTES.md) 
