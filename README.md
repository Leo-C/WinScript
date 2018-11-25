## **WinScript**


### Introduction

**WinScript** is a simple tool to execute some commands with parameters, using a minimal GUI.  
The GUI is only costituted by a dropdown list with description of commands, a textbox with parameters (a parameter per line) and a button to execute desired command.  
GUI is customizable by ini file (dimensions, labels)


### Installation

*WinScript* must only be copied in destination directory, with relative .ini file


### Configuration

In same directory of executable, a .ini file with same name is required.  
  
* [Global] section lists appearance parameters (see comments in ini file)
* Each line of [Commands] section is command description (key) and a batch command (value)
* command is interpolated with parameters (placeholders are '%n', substituted in order)
* for debug: executed commands are printed on stdout (redirected to file toread it)
