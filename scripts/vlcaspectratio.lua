-- vlc style aspect ratio stretch for mpv
-- uses hotey 'a', same as VLC
-- https://github.com/kism/mpvscripts

require "mp.msg"
require "mp.options"

local stretchnumber = 0

function on_press()
    local ar
    local artext

    stretchnumber = stretchnumber + 1

    if stretchnumber == 1 then
        ar = "16:9"
    elseif stretchnumber == 2 then
        ar = "4:3"
    elseif stretchnumber == 3 then
        ar = "1:1"
    elseif stretchnumber == 4 then
        ar = "16:10"
    elseif stretchnumber == 5 then
        ar = "2.21:1"
    elseif stretchnumber == 6 then
        ar = "2.35:1"
    elseif stretchnumber == 7 then
        ar = "2.39:1"
    elseif stretchnumber == 8 then
        ar = "5:4"
    elseif stretchnumber == 9 then
        ar = 0
    elseif stretchnumber == 10 then
        ar = -1
        stretchnumber = 0
    end

    if type(ar) == "number" then
        if ar == 0 then
            artext = "Force PAR 1:1"
        elseif ar == -1 then
            artext = "Default"
        end
    else
        artext = tostring(ar)
    end

    mp.osd_message("Aspect Ratio: " .. artext)
    mp.set_property("video-aspect-override", ar)

end

function cleanup()
    mp.set_property("video-aspect-override", -1)
    return true
end

mp.add_key_binding("a", "toggle_stretch", on_press)
mp.register_event("file-loaded", cleanup)
