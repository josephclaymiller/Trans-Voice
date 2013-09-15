-----------------------------------------------------------------------------------------
--
-- main.lua
--
-----------------------------------------------------------------------------------------

-- Libraries
local widget = require "widget"

-- local variables
local button_width = 100
local button_height = 60
local slider_width = 200
local scene = display.newGroup()
--local recording_num = 1
--local recordings = {}
local current_recording
local voice_recording_file = "voice_recording"
local is_recording = false
local is_playing = false
local platform_name = system.getInfo("platformName")-- Find platform type

-- Set up file
local function get_sound_file_name()
	voice_recording_file = "voice_recording"
	if platform_name == "iPhone OS" then
		voice_recording_file = voice_recording_file .. ".aif"
	end
	if platform_name == "Android" then
		voice_recording_file = voice_recording_file .. ".3gp"
	end
	return voice_recording_file
end
voice_recording_file = get_sound_file_name() -- set file name (once) for current device

-- Sound Events
local function onCompleteSound(event)
	print("Finished play back")
end

-- Play Sound
local function play_voice()
	media.playSound(voice_recording_file, system.DocumentsDirectory, onCompleteSound)
	--print("played voice back")
end

local function stop_playing_voice()
	-- stop playing voice recording
	media.pauseSound()
end

-- Record Sound
local function stop_recording_voice()
	if current_recording:isRecording() then
		current_recording:stopRecording()
		print("stopped recording")
		--is_recording = false
	end
end

local function record_voice ( dataFileName )
	local filePath = system.pathForFile( dataFileName, system.DocumentsDirectory )
	current_recording = media.newRecording( filePath )
	--table.insert( recordings, current_recording )
	current_recording:startRecording()
	print("started recording " .. dataFileName)
	--recording_num = recording_num + 1
	--is_recording = true
end

-- Button Event listeners
local function onButtonPressEvent( event )
	local target = event.target
	--print ("pressed " .. target.id)
	if current_recording and current_recording:isRecording() then
		-- stop recording
		stop_recording_voice()
	else
		-- start recording
		record_voice( voice_recording_file )
	end
	return true
end

local function onButtonReleaseEvent ( event )
	if current_recording and current_recording:isRecording () then
		event.target:setLabel( "Stop" )  -- set label to "stop"
	else
		event.target:setLabel( "Record" )  -- reset the label to "record"
	end
end

local function onPlayButtonPressEvent ( event )
	--print ("pressed " .. event.target.id) -- play button pressed
	if is_playing then
		print ("stoping play back")
		stop_playing_voice()
		is_playing = false
	else
		print ("playing recording")
		play_voice()
		is_playing = true
	end
end

local function onPlayButtonReleaseEvent( event )
	-- released play button
	if is_playing then
		event.target:setLabel( "Pause" )  -- set label to "pause"
	else
		event.target:setLabel( "Play" )  -- reset the label to "play"
	end
end

-- Slider event listener
local function sliderListener( event )
   local slider = event.target
   local value = event.value
   print( "Slider at " .. value .. "%" )
end

--[[ UI ]]
-- Record Button
local record_button = widget.newButton
{
	button_size = 80,
	id = "record button",
	label = "Record",
	width = button_width,
	height = button_height,
	left = (display.contentWidth - button_width)/2,
	top = (display.contentHeight - button_height)*0.4,
    labelColor = {
    	default = { 255, 255, 255, 90 },
    	over = { 255, 0, 0, 255 },
	},
    onPress = onButtonPressEvent,
    onRelease = onButtonReleaseEvent
}
scene:insert(record_button)

-- Play Button
local play_button = widget.newButton
{
	button_size = 80,
	id = "play button",
	label = "Play",
	width = button_width,
	height = button_height,
	left = (display.contentWidth - button_width)/2,
	top = (display.contentHeight - button_height)*0.6,
	labelColor = {
    	default = { 255, 255, 255, 90 },
    	over = { 0, 255, 0, 255 },
	},
    onPress = onPlayButtonPressEvent,
    onRelease = onPlayButtonReleaseEvent
}
scene:insert(play_button)

-- Pitch Slider
local pitch_slider = widget.newSlider
{
   orientation = "horizontal",
   width = slider_width,
   left = (display.contentWidth - slider_width)/2,
   top = (display.contentHeight)*0.75,
   listener = sliderListener
}
scene:insert(pitch_slider)