# IoCFinder
Introducing “IoC Finder” - A Simple Script to Find Files Matching IoC Values

Available as a PowerShell or Bash script.

# What is an “Indicator of Compromise” (IoC)?

An IoC is esentially an attribute of a file (such as a hash, file name or string) that matches a known malicious file.

IoC Finder isn't just useful for threat hunting though! When you search for ‘strings’, you extract readable text within files and binaries. If, for example, you have a file containing the word “password” lost somewhere in a folder, this tool can help you locate the file.

# Abstraction

You might know how to recursively search a directory for a file hash and print matching files to the terminal, but what if you need to search for a different attribute? The interactive nature of this tool saves you time by elimating the need to retype commands, and allowing you to easily return to any part of the search logic.

# Reactive vs Proactive Threat Hunting

Tools such as YARA are typically used for proactive threat hunting, where you don’t know the exact indicators you're looking for. Instead, you compare directories against predefined YARA rule sets containing IoCs. In contrast, **IoC Finder** can work great when you need to perform quick **reactive** threat hunting, and you already know the specific attribute you’re looking for.

# Search Options

1) MD5 Hash
2) SHA-1 Hash
3) SHA-256 Hash
4) File Size (in bytes)
5) File Name
6) Strings search
7) File Extension search
   
![iocFinder](https://github.com/user-attachments/assets/fc387ab5-f72f-4047-a177-ca39f08c1cd8)

![iocFinder2](https://github.com/user-attachments/assets/3490989e-1b63-4627-80f3-860f448130e9)
