-- Copyright 2008-present Studio Heys Limited
-- www.simonheys.com

property extension_list : {"tif", "tiff", "png", "pict", "pct", "pdf", "bmp", "eps", "psd"}

global quality
global this_image
global current_folder

--__________________________________________________________________________________________ drag and drop

on open these_items
	log "open"
	log these_items
	process(these_items)
end open

--__________________________________________________________________________________________ files

on process(these_items)
	initialise()
	log "process " & these_items
	repeat with i from 1 to the count of these_items
		set this_item to (item i of these_items)
		set the item_info to info for this_item
		if (alias of the item_info is false) and (the name extension of the item_info is in the extension_list) then
			process_item(this_item)
		end if
	end repeat
	finalise()
end process

--__________________________________________________________________________________________ folder

on process_folder(this_folder)
	initialise()
	set current_folder to this_folder
	log "process_folder " & this_folder
	set these_items to list folder this_folder without invisibles
	repeat with i from 1 to the count of these_items
		set this_item to alias ((this_folder as text) & (item i of these_items))
		set the item_info to info for this_item
		if (alias of the item_info is false) and (the name extension of the item_info is in the extension_list) then
			process_item(this_item)
		end if
	end repeat
	finalise()
end process_folder

on initialise()
	log "initialise"
	set quality to get_compression_quality_from_filename()
end initialise

on finalise()
	log "finalise"
end finalise

--__________________________________________________________________________________________ sips process

on process_item(item_alias)
	log "process_item: " & item_alias
	
	set this_path to (item_alias) as string
	set the newJPG_name to my add_extension(item_alias, "jpg")
	
	try
		set the_command to "sips --setProperty format jpeg --setProperty formatOptions " & quality & " " & quoted form of POSIX path of item_alias & " --out " & quoted form of newJPG_name
		log "the_command: " & the_command
		do shell script the_command
		
	on error error_message
		display dialog error_message
	end try
end process_item

--__________________________________________________________________________________________ default behaviour

try
	tell application "Finder"
		set the source_folder to choose folder with prompt "Pick a folder to process:"
	end tell
	process_folder(source_folder)
on error error_message
	display dialog error_message buttons {"OK"} default button 1
end try

--__________________________________________________________________________________________ file extension

on add_extension(item_alias, new_extension)
	log "add_extension"
	log item_alias
	set this_info to the info for item_alias
	--set this_name to the name of this_info
	--set this_name to (item_alias) as string
	set this_name to POSIX path of item_alias
	
	set this_extension to the name extension of this_info
	if this_extension is missing value then
		set the default_name to this_name
	else
		set the default_name to text 1 thru -((length of this_extension) + 2) of this_name
	end if
	return (the default_name & "." & the new_extension)
end add_extension

--__________________________________________________________________________________________ compession quality

on get_compression_quality_from_filename()
	set this_info to the info for (path to me)
	
	set this_name to the name of this_info
	set this_extension to the name extension of this_info
	
	if this_extension is missing value then
		set the default_name to this_name
	else
		set the default_name to text 1 thru -((length of this_extension) + 2) of this_name
	end if
	
	set originalDelimiters to AppleScript's text item delimiters
	set AppleScript's text item delimiters to {" "}
	set text_items to the text items of default_name
	
	set compression_quality to 100
	
	if (count of text_items) > 1 then
		set compression_quality to the last item of text_items
	end if
	
	set AppleScript's text item delimiters to {originalDelimiters}
	
	return compression_quality
end get_compression_quality_from_filename
