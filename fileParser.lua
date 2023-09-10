--BeatFever fileparser module
--Contains ".osu" file parsing functions
local moduleName = "[FileParser]"
noteCount = 1
local fileLines =  {} --Where we'll hold the current osu file data.
parser = {}
local fileLoaded = nil
local ObjectTypes = {HitCircle = 1, Slider = 2, NewCombo = 4, Spinner = 8}



function parser.loadOsuFile(file)
	fileLoaded = file
	fileLines = {}
	--debugLog("Processando arquivo '" .. file .. "'...", 1, moduleName)
	if love.filesystem.getInfo(file,"file") then 
		for line in love.filesystem.lines(file) do
			table.insert(fileLines, line)		--Needs to check if the file really exists or not, otherwise, wild crashes may occur.
		end
		--debugLog("Arquivo " .. file .. " carregado", 1, moduleName)
		return true
	else
		--debugLog("Falha ao carregar arquivo, saindo", 2, moduleName)
		return false
	end
end


-- Commence insane string splitting funcs

function parser.getAudioFileName()
	for key, line in ipairs(fileLines) do
		if #line>0 then
			if string.find(line, "AudioFilename:") ~= nil then
				audioFile = string.split(line, ': ')
			end
		end
	end
	--debugLog("AudioFile is: "..audioFile[2], 1, moduleName)
	return audioFile[2]
end

function parser.getAudioLeadIn()
	for key, line in ipairs(fileLines) do
		if #line>0 then
			if string.find(line, "AudioLeadIn:") ~= nil then
				audioLead = string.split(line, ': ')
			end
		end
	end
	return audioLead[2]
end

function parser.getPreviewTime()
	for key, line in ipairs(fileLines) do
		if #line>0 then
			if string.find(line, "PreviewTime:") ~= nil then
				previewTime = string.split(line, ': ');
			end
		end
	end
	--debugLog("Preview time is "..previewTime[2], 1, moduleName)
	return tonumber(previewTime[2]);
end

function parser.getTimingPoints()
	local timingpointstring = {}
	local timingpoint = {}
	local save = false
	
	for key1, line in ipairs(fileLines) do
		if #line > 2 then
			if save then
				table.insert(timingpointstring, line) --inserts a value in a given table
			end
		else
			save = false
		end
		
		if string.find(line, '%[TimingPoints%]') ~= nil then
			save = true
		end
	end -- closes "for" loop
		
	for key2, point in ipairs(timingpointstring) do
		--thankfully this is static! which means it never changes... I hope.
		parameters = string.split(point, ",")
		newpoint = {offset = tonumber(parameters[1]), mpb = tonumber(parameters[2]), meter = tonumber(parameters[3]), sampleType = tonumber(parameters[4]),
		sampleSet = tonumber(parameters[5]), volume = tonumber(parameters[6]), inherited = tonumber(parameters[7]), kiai = tonumber(parameters[8])}
		--Offset, Milliseconds per Beat, Meter, Sample Type, Sample Set, Volume, Inherited, Kiai Mode
		table.insert(timingpoint, newpoint)
	end
	
	--debugLog("Parsed timing points for osu file!", 1, moduleName)
	return timingpoint
end

function parser.getFilteredTimingPoints()
	local timingPoints = parser.getTimingPoints()
	local timingPointsInherited = {}
	local timingPointsBPM = {}
	
	--Inherited == 0 means the timing point IS inherited.
	for i, value in ipairs(timingPoints) do
		if tonumber(value.inherited) == 0 then
			table.insert(timingPointsInherited, value)
		else
			table.insert(timingPointsBPM, value)
		end
	end
	--for j, v in ipairs(timingPointsInherited) do print(v.offset, v.mpb) end
	--print("------")
	return timingPointsBPM, timingPointsInherited
end

function parser.getSongTitle()
	for key, line in ipairs(fileLines) do
		if #line>0 then
			if string.find(line, "Title:") ~= nil then
				songName = string.split(line, ':')
			end
		end
	end
	--debugLog("Song name: "..songName[2], 1, moduleName)
	return songName[2]
end

function parser.getSongVersion()
	for key, line in ipairs(fileLines) do
		if #line>0 then
			if string.find(line, "Version:") ~= nil then
				songVer = string.split(line, ':')
			end
		end
	end
	--debugLog("Song difficulty: "..songName[2], 1, moduleName)
	return songVer[2]
end

function parser.getArtist()
	for key, line in ipairs(fileLines) do
		if #line>0 then
		
			if string.find(line, "Artist:") ~= nil then
				artist = string.split(line, ':')
			end
		end
	end
	--debugLog("Artist name: "..artist[2], 1, moduleName)
	return artist[2]
end

function parser.getBMCreator()
	for key, line in ipairs(fileLines) do
		if #line>0 then
			if string.find(line, "Creator:") ~= nil then
				creator = string.split(line, ':')
			end
		end
	end
	--debugLog("Creator: "..creator[2], 1, moduleName)
	return creator[2]
end

function parser.getComboColors()
	local colorstring = {}
	local colors = {}
	local save = false
	
	for key1, line in ipairs(fileLines) do
		if #line > 2 then
			if save then
				table.insert(colorstring, line) --inserts a value in a given table
			end
		else
			save = false
		end
		
		if string.find(line, '%[Colours%]') ~= nil then
			save = true
		end
	end -- closes "for" loop
	
	for key2, color in ipairs(colorstring) do
		parameters = string.split(color, " : ")
		comboColour = string.split(parameters[2], ",")
		newComboColour = {comboColour[1], comboColour[2], comboColour[3]}
		--R, G, B
		table.insert(colors, newComboColour)
	end
	
	--What if the beatmap has no colour setting?
	if colors[1] == nil then
		debugLog("No colors could be found in beatmap! Returning default values..", 2, moduleName)
		newComboColour = {255, 255, 255}
		--R, G, B
		table.insert(colors, newComboColour)
	end
	
	return colors
end

function parser.getSliderMultiplier()
	for key, line in ipairs(fileLines) do
		if #line>0 then
			if string.find(line, "SliderMultiplier:") ~= nil then
				multiplier = string.split(line, ':')
			end
		end
	end
	--debugLog("Slider multiplier: "..multiplier[2], 1, moduleName)
	return multiplier[2]
end

function parser.getCurrentLoadedFile()
	debugLog("Currently, the file "..fileLoaded.." is loaded on the parser.", 1, moduleName)
	return fileLoaded
end

function parser.getBreakPeriods()
	debugLog("In function parser.getBreakPeriods()", 3, moduleName)
	debugLog("This function is not working correctly yet! Refer to implementation notes in source.", 3, moduleName)
	--Simples, vou explicar:
	--Você não possui o endTime de um break period na verdade. Você só possui startTimes.
	--O tempo final de um break é determinado pelo proximo hitObject apos o tempo do breakStart.
	--Ou seja, precisamos mexer nessa função!
	
	
	local breakpstring = {}
	local breakpoints = {}
	local save = false
	
	for key1, line in ipairs(fileLines) do
		if string.find(line, "%/%/") == nil then
			if save then
				table.insert(breakpstring, line)
			end
		else
			save = false
		end
		
		if string.find(line, "%/%/Break Periods") ~= nil then
			save = true
		end
	end
	
	for key2, value in ipairs(breakpstring) do
		params = string.split(value, ",")
		breakpoint = {tonumber(params[1]), tonumber(params[2])} --startTime and endTime
		table.insert(breakpoints, breakpoint)
	end
	--debugLog("Loaded song breakpoints!", 1, moduleName)
	return breakpoints
end

function parser.getBGFile()
	local breakpstring = {}
	local breakpoints = {}
	local save = false
	
	for key1, line in ipairs(fileLines) do
		if string.find(line, "%/%/") == nil then
			if save then
				table.insert(breakpstring, line)
			end
		else
			save = false
		end
		
		if string.find(line, "%/%/Background and Video events") ~= nil then
			save = true
		end
	end
	
	for key2, value in ipairs(breakpstring) do
		params = string.split(value, ",")
		for key, value in ipairs(params) do
			if (string.find(value, ".jpg") or string.find(value, ".png") or string.find(value, ".bmp")) ~= nil then
				BG = params[key]
			end
		end
	end
	
	if BG ~= nil then
		BG = BG:gsub('"', "") --GODAMNIT TOOK ME SO LONG TO MAKE THIS WORK I CAN FINALLY SLEEP
		return BG
	else
		debugLog("FAILED TO PARSE BG! Falling back to standard background", 3, moduleName)
		return "error"
	end
end

function parser.getHitObjects(hitCircleImage, sliderTickImage)
	--Sets up graphics to be used in the ingame
	objectParser.setNoteGraphics(hitCircleImage, sliderTickImage)
	
	local noteList = {}
	local splitLines = {}
	local foundSection = false
	timingPointList = parser.getTimingPoints()
	
	
	for key1, line in ipairs(fileLines) do
		if #line > 0 then
		
			if foundSection then				--Splits file in many lines, read each one	
				table.insert(splitLines, line)	--looking for section, copy everything after section marker.
			end
		
			if string.find(line, "%[HitObjects%]") ~= nil then
				foundSection = true
			end
		end
	end
	
	for key2, line in ipairs(splitLines) do
		if #line > 3 then
			note = parser.parseHitObject(line)
			for i, v in ipairs(note) do
				table.insert(noteList, v)
			end
		end
	end
	
	return noteList
end

function parser.parseHitObject(str)
	--Local vars for type
	local HitCircle = false
	local Spinner = false
	local Slider = false
	local newCombo = false
	
	--Get note type from string
	local params = string.split(str, ",")
	local objType = tonumber(params[4]) 
	
	--Checks new combo
	if (bit.band(objType, 4) > 0) then
		newCombo = true
	else
		newCombo = false
	end
	
	--Determines note type based on splitted value
	if (bit.band(objType, 1) > 0) then
		--Hit circle
		note = objectParser.parseHitCircle(str, newCombo)
	end
	
	if (bit.band(objType, 2) > 0) then
		--Slider
		note = objectParser.parseSlider(str, newCombo)
	end
	
	
	if (bit.band(objType, 8) > 0) then 
		--Spinner
		note = objectParser.parseHitCircle(str, newCombo)
	end
	--At this point, we just effin hope we have no sliding spinners or something

	--Return to the user the object processed (table)
	assert(note, "Returned note is nil!")
	return note
end
