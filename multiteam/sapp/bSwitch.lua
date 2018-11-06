-- Custom Bipeds by 002, custom made for King
-- Configuration

-- Use lowercase ["key"], only. The ["key"] is what you enter with the /armor command.
-- ["key"] = "tag", (surround with commas)
BIPEDS = {
    [0] = "bourrin\\halo reach\\spartan\\male\\mp masterchief",
	[1] = "cmt\\characters\\elite_v2\\player\\elite_v2_mp",
}

-- End of Configuration

api_version = "1.11.1.0"

BIPED_IDS = {}
CHOSEN_BIPEDS = {}
DEFAULT_BIPED = nil


function OnScriptLoad()
    register_callback(cb['EVENT_TEAM_SWITCH'], "OnTeamSwitch")
    register_callback(cb['EVENT_OBJECT_SPAWN'],"OnObjectSpawn")
    register_callback(cb['EVENT_GAME_END'],"OnGameEnd")
    register_callback(cb['EVENT_COMMAND'],"OnCommand")
    register_callback(cb['EVENT_JOIN'], "OnJoin")
end

function OnError(Message)
    print(debug.traceback())
end

function OnScriptUnload()
    BIPED_IDS = {}
    DEFAULT_BIPED = nil
end

function OnJoin(PlayerIndex)
    CHOSEN_BIPEDS[get_var(PlayerIndex, "$hash")] = BIPEDS[get_var(PlayerIndex, "$team")]
end

function OnTeamSwitch(PlayerIndex)
    CHOSEN_BIPEDS[get_var(PlayerIndex, "$hash")] = BIPEDS[get_var(PlayerIndex, "$team")]
end

function FindBipedTag(TagName)
    local tag_array = read_dword(0x40440000)
    for i=0,read_word(0x4044000C)-1 do
        local tag = tag_array + i * 0x20
        if(read_dword(tag) == 1651077220 and read_string(read_dword(tag + 0x10)) == TagName) then
            return read_dword(tag + 0xC)
        end
    end
end

function OnObjectSpawn(PlayerIndex, MapID, ParentID, ObjectID)
    if(player_present(PlayerIndex) == false) then return true end --if player does not exist, do not execute. otherwise, proceed.
    if(DEFAULT_BIPED == nil) then --if the default biped is nil, then read into the globals, and grab it out of the globals.
        local tag_array = read_dword(0x40440000)
        for i=0,read_word(0x4044000C)-1 do
            local tag = tag_array + i * 0x20
            if(read_dword(tag) == 1835103335 and read_string(read_dword(tag + 0x10)) == "globals\\globals") then
                local tag_data = read_dword(tag + 0x14)
                local mp_info = read_dword(tag_data + 0x164 + 4)
                for j=0,read_dword(tag_data + 0x164)-1 do
                    DEFAULT_BIPED = read_dword(mp_info + j * 160 + 0x10 + 0xC)
                end
            end
        end
    end
    local hash = get_var(PlayerIndex,"$hash") --retrieves the player indexes CD hash to use it as an index in the CHOSEN_BIPEDS table.
    if(MapID == DEFAULT_BIPED and CHOSEN_BIPEDS[hash]) then --if the Tag ID matches the default biped, and the chosen biped matches the hash.
        for key,value in pairs(BIPEDS) do --(note: key and value represent "i"). Find the biped tag.
            if(BIPED_IDS[key] == nil) then --if it is found, overwrite.
                BIPED_IDS[key] = FindBipedTag(BIPEDS[key])
            end
        end
        return true,BIPED_IDS[CHOSEN_BIPEDS[hash]] --and return it. (in case it is not found, it does not get over-written.)
    end
    return true
end

OnGameEnd = OnScriptUnload