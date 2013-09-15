-----------------------------------------------------------------------------------------
--
-- main.lua
--
-----------------------------------------------------------------------------------------

-- Libraries
local widget = require "widget"

-- local variables
local current_recording -- the current recording object to record to
local voice_recording_file = "voice_recording"
local is_playing = false
local platform_name = system.getInfo("platformName")-- Find platform type
local pitch_value = 1.0 -- 1.0 is normal, 2.0 is up one octave, 0.5 is down one octave
local scene = display.newGroup() -- display group to hold everything in scene
local button_width = 100
local button_height = 60
local slider_width = 200

-- Forward declarations
local record_button
local play_button
local sound_text

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
	is_playing = false
	sound_text.text = "Press 'record' then speak"
end

-- Play Sound
local function play_voice()
	--media.playSound(voice_recording_file, system.DocumentsDirectory, onCompleteSound)
	--print("played voice back")
	local mySound = audio.loadStream(voice_recording_file, system.DocumentsDirectory)
	local mychannel, mysource = audio.play(mySound, {onComplete=onCompleteSound})
	al.Source(mysource, al.PITCH, pitch_value);
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
	end
end

local function record_voice ( dataFileName )
	local filePath = system.pathForFile( dataFileName, system.DocumentsDirectory )
	current_recording = media.newRecording( filePath )
	current_recording:startRecording()
	print("started recording " .. dataFileName)
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
		sound_text.text = "Press 'stop' when finished"
	else
		event.target:setLabel( "Record" )  -- reset the label to "record"
		sound_text.text = "Adjust slider then press 'play'"
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

-- Slider event listener
local function sliderListener( event )
   local slider = event.target
   local value = event.value
   print( "Slider at " .. value .. "%" )
   pitch_value = (value / 100.0) + 0.5
end

--[[ UI ]]
-- Record Button
record_button = widget.newButton
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
play_button = widget.newButton
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
    onPress = onPlayButtonPressEvent
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

-- Text to display to user
sound_text = display.newText("Press 'record' then speak", 0, 0, nil, 14);
sound_text:setReferencePoint(display.CenterReferencePoint);
sound_text.x = display.contentWidth/2;
sound_text.y = display.contentHeight*0.25;
scene:insert(sound_text)