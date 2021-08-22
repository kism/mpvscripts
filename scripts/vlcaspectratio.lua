-- vlc style aspect ratio stretch for mpv
-- uses hotey 'a', same as VLC
-- https://github.com/kism/mpvscripts

require "mp.msg"
require "mp.options"

local ar_option = 0

function has_video()
    for _, track in pairs(mp.get_property_native('track-list')) do
        if track.type == 'video' and track.selected then
            return not track.albumart
        end
    end

    return false
end

function on_press()
    -- If there is no video to stretch the AR of
    if not has_video() then
        mp.msg.warn("autocrop only works for videos.")
        return
    end    
    
    local ar
    local ar_text

    ar_option = ar_option + 1

    if ar_option == 1 then
        ar = "16:9"
    elseif ar_option == 2 then
        ar = "4:3"
    elseif ar_option == 3 then
        ar = "1:1"
    elseif ar_option == 4 then
        ar = "16:10"
    elseif ar_option == 5 then
        ar = "2.21:1"
    elseif ar_option == 6 then
        ar = "2.35:1"
    elseif ar_option == 7 then
        ar = "2.39:1"
    elseif ar_option == 8 then
        ar = "5:4"
    elseif ar_option == 9 then
        ar = 0
    elseif ar_option == 10 then
        ar = -1
        ar_option = 0
    end

    if type(ar) == "number" then
        if ar == 0 then
            ar_text = "Force PAR 1:1"
        elseif ar == -1 then
            ar_text = "Default"
        end
    else
        ar_text = tostring(ar)
    end

    mp.msg.info("Aspect Ratio: " .. ar_text)
    mp.osd_message("Aspect Ratio: " .. ar_text)
    mp.set_property("video-aspect-override", ar)
end

function cleanup()
    mp.msg.verbose("Cleanup")
    mp.set_property("video-aspect-override", -1)
    return true
end

mp.add_key_binding("a", "toggle_stretch", on_press)
mp.register_event("file-loaded", cleanup)
