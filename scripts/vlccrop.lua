-- vlc style crop for mpv
-- uses hotey 'c', same as VLC
-- https://github.com/kism/mpvscripts

require "mp.msg"
require "mp.options"

local cropnumber = 0
local cropstring = string.format("%s-crop", mp.get_script_name())
local command_prefix = 'no-osd' --set this to null to debug

function gettargettar(inaspect)
    local result
    -- Handling the current crop status in this function since its scope needs to transcent this function
    cropnumber = cropnumber + 1

    if cropnumber == 1 then
        mp.osd_message("Crop: 16:10")
        result = 16 / 10
    elseif cropnumber == 2 then
        mp.osd_message("Crop: 16:9")
        result = 16 / 9
    elseif cropnumber == 3 then
        mp.osd_message("Crop: 4:3")
        result = 4 / 3
    elseif cropnumber == 4 then
        mp.osd_message("Crop: 1.85:1")
        result = 1.85 / 1
    elseif cropnumber == 5 then
        mp.osd_message("Crop: 2.21:1")
        result = 2.21 / 1
    elseif cropnumber == 6 then
        mp.osd_message("Crop: 2.35:1")
        result = 2.35 / 1
    elseif cropnumber == 7 then
        mp.osd_message("Crop: 2.39:1")
        result = 2.39 / 1
    elseif cropnumber == 8 then
        mp.osd_message("Crop: 5:3")
        result = 5 / 3
    elseif cropnumber == 9 then
        mp.osd_message("Crop: 5:4")
        result = 5 / 4
    elseif cropnumber == 10 then
        mp.osd_message("Crop: 1:1")
        result = 1 / 1
    elseif cropnumber == 11 then
        mp.osd_message("Crop: 9:16")
        result = 9 / 16
    else
        mp.osd_message("Crop: Default")
        cropnumber = 0
        result = inaspect
    end

    return result
end

function is_cropable()
    for _, track in pairs(mp.get_property_native('track-list')) do
        if track.type == 'video' and track.selected then
            return not track.albumart
        end
    end

    return false
end

function on_press()
    -- If it's not cropable, exit.
    if not is_cropable() then
        mp.msg.warn("autocrop only works for videos.")
        return
    end

    -- Get current video fields, this doesnt take into consideration pixel aspect ratio
    local width = mp.get_property_native("width")
    local height = mp.get_property_native("height")
    local aspect = mp.get_property_native("video-params/aspect")
    local par = mp.get_property_native("video-params/par")

    local neww
    local newh
    local newx
    local newy

    -- Get target aspect ratio
    targetar = gettargettar(aspect)
    mp.msg.info("Cropping Video, Target Aspect Ratio: " .. tostring(targetar))

    -- Compare target AR to current AR, crop height or width depending on what is needed
    -- The if statements
    if targetar < aspect * 0.99 then
        -- Reduce width
        neww = (height * targetar) / par -- New width is the width multiple by the aspect ratio, adjusted for the PAR (pixel aspect ratio) incase it's not 1:1
        newh = height                    -- Height stays the same since we only ever crop one axis in this script
        newx = (width - neww) / 2        -- Width - new width will equal the total space cropped, since its evenly cropped from both sides the offset needs to be halved
        newy = 0                         -- This along with the height being the video height means that it will crop zero pixels
    elseif targetar > aspect * 1.01 then
        -- Reduce height
        neww = width                            -- See newh above
        newh = (width * (1 / targetar)) * par   -- See neww above, need to adjust for PAR but it's in the reverse direction
        newx = 0                                -- See newy above
        newy = (height - newh) / 2              -- See newh above
    else
        -- So if the target aspect ratio is the same as the source (or within 1%), )
        -- mp.msg.info("\nTARGET ASPECT RATIO = SOURCE, removing filter\n")
        cleanup() -- remove the crop filter
        return    -- exit the function before we apply that crop
    end

    -- Apply crop
    mp.command(string.format("%s vf pre @%s:lavfi-crop=w=%s:h=%s:x=%s:y=%s",
                            command_prefix, cropstring, neww, newh, newx, newy))
end

function cleanup() -- This looks for applied filters that match the filter that we are using, then removes them
        local filters = mp.get_property_native("vf")
        for index, filter in pairs(filters) do
            mp.msg.info("Applied Crop : " .. tostring(filter["label"]) .. " | " .. tostring(index) )
            mp.msg.info("Removing Crop: " .. tostring(cropstring))

            if filter["label"] == cropstring then
                mp.command(string.format('%s vf remove @%s', command_prefix, cropstring))
                return true
            end
        end

        return false
end

mp.add_key_binding("c", "toggle_crop", on_press)
mp.register_event("file-loaded", cleanup)
