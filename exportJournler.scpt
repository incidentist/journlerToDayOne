JsOsaDAS1.001.00bplist00�Vscript_// Based on https://github.com/michaelcaruso/journler-to-evernote// Licensed according to the terms of the GPL version 3, see // below for more details or visit // http://www.gnu.org/licenses/gpl.txt// This program is free software: you can redistribute it and/or modify// it under the terms of the GNU General Public License as published by// the Free Software Foundation, either version 3 of the License, or// (at your option) any later version.// This program is distributed in the hope that it will be useful,// but WITHOUT ANY WARRANTY; without even the implied warranty of// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the// GNU General Public License for more details.// You should have received a copy of the GNU General Public License// along with this program.  If not, see <http://www.gnu.org/licenses/>.

// This script collects entries from Journler and outputs relevant data
// to an XML file in /tmp.

'use strict';

// Encode XML entities during output.
if (!String.prototype.encodeHTML) {
  String.prototype.encodeHTML = function () {
    return this.replace(/&/g, '&amp;')
               .replace(/</g, '&lt;')
               .replace(/>/g, '&gt;')
               .replace(/"/g, '&quot;')
               .replace(/'/g, '&apos;');
  };
}

var outFile, newline;
var app = Application.currentApplication()
app.includeStandardAdditions = true

var outFilePath = Path('/tmp/journlerExport.xml');

// Assemble the XML document to write.
var outStr = '<?xml version="1.0" encoding="UTF-8"?>' + "\n"
outStr += "<entries>\n"


var journler = Application('Journler')

for (var i = 0; i < journler.entries().length; i++) {
	var entry = journler.entries[i]
	var title = entry.name().encodeHTML()
	var date = entry.dateCreated()
	var tags = entry.tags()
	var category = entry.category()
	var richTextPath = entry.richTextPath()
	var imagePath = ""
	
	// Add category to tags
	if (category.length > 0) {
		tags.push(category.toLowerCase())
	}
	
	// Find lead image by extracting the first image resource.
	var resources = entry.resources.whose(
		{'_and':
			[
				{'_match': [ObjectSpecifier().type, "media"]},
				{'uti': { _beginsWith: "public"}}
			]
		}
	)
	
	if (resources().length > 0) {
		console.log(resources[0].originalPath())
		imagePath = resources[0].originalPath()
	}

	outStr += "	<entry>\n"
	outStr += "		<title>" + title + "</title>\n"
	outStr += "		<date>" + date.toISOString() + "</date>\n"
	outStr += "		<tags>" + tags.join(', ').encodeHTML() + "</tags>\n"
	outStr += "		<richTextPath>" + richTextPath + "</richTextPath>\n"
	outStr += "		<imagePath>" + imagePath + "</imagePath>\n"

	outStr += "	</entry>\n"
}

outStr += "</entries>"

// Write the file atomically
var str = $.NSString.alloc.initWithUTF8String(outStr)
str.writeToFileAtomically(outFilePath.toString(), true)


                              % jscr  ��ޭ