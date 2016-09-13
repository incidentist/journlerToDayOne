<?php

// Convert an XML file containing Journler data to Day One using the
// Day One command line utils:

define('INPUT_FILE', '/tmp/journlerExport.xml');

$entries = simplexml_load_file(INPUT_FILE);

$count = 0;

foreach ($entries as $entry) {

	$date = $entry->date;
	$entryText = textForEntry($entry);
	file_put_contents('/tmp/entry.txt', $entryText);

	$cmd = [];
	$cmd[] = '/usr/local/bin/dayone';
	$cmd[] = sprintf('-d="%s"', $date);

	if (!empty($entry->imagePath)) {
		$cmd[] = sprintf('-p="%s"', $entry->imagePath);
	}

	$cmd[] = 'new';
	$cmd[] = '<';
	$cmd[] = escapeshellarg('/tmp/entry.txt');

	$cmd = implode(' ', $cmd);
	$output = shell_exec($cmd);
	echo $cmd . "\n";
	echo $output;

	$count++;
	// if ($count > 20) {
	// 	break;
	// }
}

// Delete files
unlink(INPUT_FILE);
unlink('/tmp/entry.txt');

// Get the entry text.
// @see http://stackoverflow.com/questions/1043768/quickly-convert-rtf-doc-files-to-markdown-syntax-with-php#7492071
// @return string
function textForEntry($entry) {
	$ret = $entry->title . "\n\n";

	// Add tags
	if (!empty($entry->tags)) {
		$tags = explode(', ', $entry->tags);
		$tags = array_map(function($tag) {
			return '#' . preg_replace_callback('|\s(\w)|', function($matches) {
				return strtoupper($matches[1]);
			}, $tag);
		}, $tags);
		$tags = 'Tags: ' . implode(' ', $tags);
		$ret .= $tags . "\n\n";
	}

	// Convert RTF to HTML and then HTML to Markdown
	$cmd = [];
	$cmd[] = 'textutil';
	$cmd[] = '-convert';
	$cmd[] = 'html';
	$cmd[] = escapeshellarg($entry->richTextPath);
	$cmd[] = '-stdout';
	$cmd[] = '|';
	$cmd[] = '/usr/local/bin/pandoc';
	$cmd[] = '--from=html';
	$cmd[] = '--to=markdown_strict';
	$cmd[] = '--wrap=none';

	$cmd = implode(" ", $cmd);
	// echo $cmd . "\n";

	$output = shell_exec($cmd);
	// Process output a bit
	$output = preg_replace("|\n\n\s*\n|", "\n\n", $output);
	$output = preg_replace('|<span class="Apple-converted-space">.*</span>|', " ", $output);
	$output = preg_replace('|<span class="Apple-tab-span">\s*</span>|', "\t", $output);
	// pandoc escapes lists we'd like to keep. Turn '\*' into '*'
	// Six slashes is a personal record for me.
	$output = preg_replace("|^\\\\\\* |m", "* ", $output);
	$output = strip_tags($output);

	$ret .= $output;

	return $ret;
}