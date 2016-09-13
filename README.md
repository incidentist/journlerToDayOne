# README

These two scripts can import Journler entries into Day One (http://dayoneapp.com/). The first script is an Apple Automation script (written in JavaScript) that exports entry data into an XML file. The second is a PHP script that imports the XML file into Day One using the Day One command-line interface.

Requirements:

OS X Yosemite or later, for Javascript Automation.
Official Day One command line interface: http://help.dayoneapp.com/day-one-tools/ 
pandoc, for converting HTML to markdown: http://pandoc.org/

To run:

0. Backup Day One journal
1. Run exportJournlerJs.scpt
2. Run php importToDayOne.php