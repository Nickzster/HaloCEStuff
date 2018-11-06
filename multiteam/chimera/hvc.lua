clua_version = 2.04;

set_callback("tick", "OnTick");
set_callback("command", "OnCommand");
set_callback("map load", "OnMapLoad");
--set_callback("","");

defaultSpeed = false;

player = nil;

playerTeamIndex = nil;

currentTeamIndex = 0;

velocityMultiplier = 1;

playerDefaultSpeed = nil;

biped = nil;

fp_hands_default_id = nil
fp_hands_default_class = nil
fp_hands_new_id = nil
fp_hands_new_class = nil

--redTeamHands = "halo reach\\objects\\characters\\spartans\\fp\\fp" --DEFAULTED to currently set hands in globals.
blueTeamHands = "cmt\\characters\\elite_v2\\fp\\minor" --Set the hands you want for blue team here.

fp_hands_default_id = nil
fp_hands_default_class = nil
fp_hands_new_id = nil
fp_hands_new_class = nil

function switchFpHands()
    local localPlayerObject = get_player()
        if localPlayerObject ~= nil then
            local globals_tag = read_u32(get_tag("matg", "globals\\globals") + 0x14) --read in globals file
            local fp_hands = read_u32(globals_tag + 0x17C + 4) --read in fp section of globals (which is spartan)

            if fp_hands_default_id == nil then --if the default fp hands have not been read in
                --then read them in
                fp_hands_default_id = read_u32(fp_hands + 0xC)
                fp_hands_default_class = read_u32(fp_hands);
                --as well as the other set of fp hands
                local fp_hands_new = get_tag("mod2", blueTeamHands)
                fp_hands_new_id = read_u32(fp_hands_new + 0xC)
                fp_hands_new_class = read_u32(fp_hands_new)
            end

            console_out("FP hands should be: ")
            if currentTeamIndex == 0 then --write spartan hands
                write_u32(fp_hands, fp_hands_default_class)
                write_u32(fp_hands + 0xC, fp_hands_default_id)
                console_out("human")
            else --write elite hands
                write_u32(fp_hands, fp_hands_new_class)
                write_u32(fp_hands + 0xC, fp_hands_new_id)
                console_out("elite")

            end

        else
            console_out("Can't find player object(called from switchfphands)")
        end
end

function OnTick() --called every tick... 30 times a second
	
	local object = get_player();
    if object ~= nil then
        playerTeamIndex = read_byte(object + 0x20);
        if playerTeamIndex ~= currentTeamIndex then
            console_out("Player has switched teams!")
            currentTeamIndex = playerTeamIndex
            switchFpHands()
        end
	else
		console_out("object is returning nil");
	end
    
--    if console_is_open() then
--        console_out("Console has opened!");
--    end
end

function OnCommand(command)
        
    if command.sub(command, 0, 5) == "spawn" then --If our command is "spawn arg", where arg is a value 
        execute_script("object_create_anew_containing "..command.sub(command,7,7));  
        return false;
    elseif command.sub(command,0,6) == "delete" then --if our command is "delete arg", where arg is a value
        execute_script("object_destroy_containing "..command.sub(command,8,8));
        return false;
    elseif command.sub(command, 0, 5) == "speed" then --if the command is speed
        velocityMult = tonumber(command.sub(command,9,9));
        local speedObject = get_player();
        write_float(speedObject + 0x6C, playerDefaultSpeed * velocityMult);
        return false;
    elseif command.sub(command, 0, 4) == "team" then --if the command is speed
        console_out(playerTeamIndex);
        console_out(currentTeamIndex);
        return false
    else
        return true;
    end
end