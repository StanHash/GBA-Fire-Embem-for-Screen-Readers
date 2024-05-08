-- Any copyright is dedicated to the Public Domain.
-- https://creativecommons.org/publicdomain/zero/1.0/

-- Access dialogue status

local procs = require 'gbafe.procs'
local strings = require 'gbafe.strings'

local dialogue = {}

local addr_StringBuf = 0x202A6AC
local addr_TalkStatus = 0x0859133C

local addr_TalkProc = 0x08591358

local addr_PInfoTable = 0x08803D64

function IsTalkActive()
    return procs.IsProcRunning(addr_TalkProc)
end

--[[
function GetTalkString()
    local talk_status_addr = memory.readlong(addr_TalkStatus)
    local talk_string_addr = memory.readlong(talk_status_addr + 0x00)

    local addr = talk_string_addr

    local result = ""

    -- go backwards until we reach
    for i = 1, 1000 do
        addr = addr - 1

        -- if [addr - 2] = [LoadFace], this is inside a face constant
        -- if [addr - 1] = [0x80], this is an extended control code

        if addr == addr_TalkStatus then
        end
    end

    local offset = 0
    local talk = talk_raw

    talk = talk:gsub("\x10(..)", function(face_bytes)
        local lo = string.byte(face_bytes, 1)
        local hi = string.byte(face_bytes, 2)

        local fid = lo + (hi - 1) * 0x100

        return FindCharacterNameForFace(fid) .. " Enters"
    end)

    print(("%08X %08X"):format(addr_StringBuf, talk_string_addr))
end
]]

function dialogue.FindCharacterNameForFace(fid)
    for i = 1, 0x100 do
        local pinfo_addr = addr_PInfoTable + (i - 1) * 0x34 -- TODO: size is different per game
        local pfino_fid = memory.readshort(pinfo_addr + 0x06)

        if pfino_fid == fid then
            local pid_name_msg = memory.readshort(pinfo_addr + 0x00)
            return strings.GetString(pid_name_msg)
        end
    end

    return nil
end

function dialogue.GetTalkString()
    if not IsTalkActive() then
        return "Not during dialogue"
    end

    local talk_raw = strings.DecodeRawString(addr_StringBuf)

    local offset = 1
    local talk = ""

    -- for speaking for which we don't know a matching character
    local generic_speaker_counter = 1
    local generic_speaker_names = {}

    local active_face_slot = 0
    local active_speakers = {}

    local current_speaker = nil

    for i = 0, 0x1000 do
        if offset >= #talk_raw then
            break
        end

        local this_byte = talk_raw:byte(offset)

        if this_byte == 0 then
            break
        elseif this_byte >= 0x08 and this_byte <= 0x0F then
            -- [OpenXyz]
            active_face_slot = this_byte - 0x08

            offset = offset + 1
        elseif this_byte == 0x80 then
            local next_byte = talk_raw:byte(offset + 1)

            if next_byte >= 0x0A and next_byte <= 0x11 then
                -- [MoveXyz]
                local from_slot = active_face_slot
                local to_slot = next_byte - 0x0A

                local tmp = active_speakers[to_slot]
                active_speakers[to_slot] = active_speakers[from_slot]
                active_speakers[from_slot] = tmp

                active_face_slot = to_slot
            end

            offset = offset + 2
        elseif this_byte == 0x10 then
            -- [LoadFace]
            if active_speakers[active_face_slot] then
                talk = talk .. active_speakers[active_face_slot] .. " Exits. "
            end

            local lo, hi = talk_raw:byte(offset + 1, offset + 2)
            local fid = lo + (hi - 1) * 0x100

            if generic_speaker_names[fid] then
                active_speakers[active_face_slot] = generic_speaker_names[fid]
            end

            local speaker_name = dialogue.FindCharacterNameForFace(fid)

            if not speaker_name then
                speaker_name = "Unknown speaker " .. generic_speaker_counter
                generic_speaker_counter = generic_speaker_counter + 1
                generic_speaker_names[fid] = speaker_name
            end

            active_speakers[active_face_slot] = speaker_name
            talk = talk .. speaker_name .. " Enters. "

            offset = offset + 3
        elseif this_byte == 0x11 then
            -- [ClearFace]
            if active_speakers[active_face_slot] then
                talk = talk .. active_speakers[active_face_slot] .. " Exits. "
            end

            active_speakers[active_face_slot] = nil
            offset = offset + 1
        elseif this_byte < 0x20 then
            talk = talk .. " " -- spaces to prevent sticking periods to the next sentence and such
            offset = offset + 1
        else
            local print_chars = talk_raw:match("^([%g ]+)",
                offset)

            if not print_chars then
                -- fallback for now
                talk = talk .. " "
                offset = offset + 1
            else
                if #print_chars > 0 then
                    if current_speaker ~= active_speakers[active_face_slot] then
                        current_speaker = active_speakers[active_face_slot]
                        talk = talk .. (current_speaker or "Unknown") .. " Says: "
                    end
                end

                talk = talk .. print_chars
                offset = offset + #print_chars
            end
        end
    end

    return talk
end

return dialogue
