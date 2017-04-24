Windows OIT Check
=================
Revision 0.1 2017-04-24

author: Gareth Darby
contact: garethdarby@gmail.com
blog post: 

DESCRIPTION
===========
This tool enables an administrator to verify an ObserveIT agent installation on windows, similar to the ObserveIT linux tool oitcheck.  Currently, as of version 6.6.2 a windows diagnostic tool is not provided by ObserveIT and therefore I decided to create my own to aid rollouts and/or installations by users who do not have access to the Webconsole GUI.

USAGE
=====
``` 
./winoitcheck.ps1
```

TROUBLESHOOTING
===============
n/a

LIMITATIONS
===========

Currently, this tool has only been confirmed wokring on Windows 2012 Server Standard running Powershell 4.0 using default ObserveIT settings.
 

LICENSE
=======

 This program is free software: you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation, either version 3 of the License, or
 (at your option) any later version.

 This program is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.

 You should have received a copy of the GNU General Public License
 along with this program.  If not, see <http://www.gnu.org/licenses/>.   

CHANGELOG
=========

v0.1 - Initial Release
