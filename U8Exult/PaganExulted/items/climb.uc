/*
 * Animated Climbing Script (Mantling)
 * 
 * Usage:
 * Assign this function to shape# 0x208.
 * Double-click to climb.
 */
void Climb object#(0x208) ()
{
    var avatar = UI_get_avatar_ref();
    var pos = UI_get_object_position(avatar);
    var start_x = pos[1];
    var start_y = pos[2];
    var start_z = UI_get_lift(avatar);
    
    var frame = UI_get_item_frame(avatar);
    var dir = (frame % 32) / 4; 
    
    // Calculate Target X,Y (1 tile in front)
    var tx = start_x;
    var ty = start_y;
    
    if (dir == 0) { ty = ty + 1; }           // South
    else if (dir == 1) { tx = tx - 1; ty = ty + 1; }  // Southwest
    else if (dir == 2) { tx = tx - 1; }          // West
    else if (dir == 3) { tx = tx - 1; ty = ty - 1; } // Northwest
    else if (dir == 4) { ty = ty - 1; }          // North
    else if (dir == 5) { tx = tx + 1; ty = ty - 1; }  // Northeast
    else if (dir == 6) { tx = tx + 1; }           // East
    else if (dir == 7) { tx = tx + 1; ty = ty + 1; }   // Southeast
    
    UI_item_say(avatar, "Checking...");
    
    // --- 1. Check Climb UP (Z+1 to Z+4) ---
    var z_offset = 1;
    var found_z = -1;
    
    while (z_offset <= 4)
    {
        var check_z = start_z + z_offset;
        
        // Brute Force Check: Can we stand there?
        UI_move_object(avatar, [tx, ty, check_z], 0);
        var new_pos = UI_get_object_position(avatar);
        var new_z = UI_get_lift(avatar);
        
        if (new_pos[1] == tx && new_pos[2] == ty && new_z == check_z)
        {
            // Valid spot found!
            found_z = check_z;
            // Move back immediately to start animation
            UI_move_object(avatar, [start_x, start_y, start_z], 0);
            z_offset = 10; // Break
        }
        else
        {
            // Failed to move, or moved to wrong Z (gravity?)
            // Ensure we are back at start just in case
            UI_move_object(avatar, [start_x, start_y, start_z], 0);
        }
        z_offset = z_offset + 1;
    }
    
    if (found_z != -1)
    {
        // CLIMB UP ANIMATION
        var diff = found_z - start_z;
        UI_item_say(avatar, "Climbing Up!");
        
        if (diff == 1)
        {
            script avatar { actor frame 16; wait 1; actor frame 12; wait 1; rise; actor frame 12; }
        }
        else if (diff == 2)
        {
            script avatar { 
                actor frame 16; wait 1; actor frame 12; wait 1; rise;
                actor frame 16; wait 1; actor frame 12; wait 1; rise;
                actor frame 12; 
            }
        }
        else if (diff == 3)
        {
            script avatar { 
                actor frame 16; wait 1; actor frame 12; wait 1; rise;
                actor frame 16; wait 1; actor frame 12; wait 1; rise;
                actor frame 16; wait 1; actor frame 12; wait 1; rise;
                actor frame 12; 
            }
        }
        else if (diff >= 4)
        {
            script avatar { 
                actor frame 16; wait 1; actor frame 12; wait 1; rise;
                actor frame 16; wait 1; actor frame 12; wait 1; rise;
                actor frame 16; wait 1; actor frame 12; wait 1; rise;
                actor frame 16; wait 1; actor frame 12; wait 1; rise;
                actor frame 12; 
            }
        }
        
        // Move forward to the ledge
        // Note: 'rise' changes Z, so we just need to update X,Y
        UI_move_object(avatar, [tx, ty, found_z], 0);
        return;
    }
    
    // --- 2. Check Climb DOWN (Z-1 to Z-4) ---
    z_offset = 1;
    found_z = -1;
    
    while (z_offset <= 4)
    {
        var check_z = start_z - z_offset;
        if (check_z < 0) { check_z = 0; } // Safety
        
        // Brute Force Check
        UI_move_object(avatar, [tx, ty, check_z], 0);
        var new_pos = UI_get_object_position(avatar);
        var new_z = UI_get_lift(avatar);
        
        if (new_pos[1] == tx && new_pos[2] == ty && new_z == check_z)
        {
            // Valid spot found!
            found_z = check_z;
            UI_move_object(avatar, [start_x, start_y, start_z], 0);
            z_offset = 10; // Break
        }
        else
        {
            UI_move_object(avatar, [start_x, start_y, start_z], 0);
        }
        z_offset = z_offset + 1;
    }
    
    if (found_z != -1)
    {
        // CLIMB DOWN ANIMATION
        var diff = start_z - found_z;
        UI_item_say(avatar, "Climbing Down!");
        
        // Move forward into the air first
        UI_move_object(avatar, [tx, ty, start_z], 0);
        
        if (diff == 1)
        {
            script avatar { actor frame 16; wait 1; actor frame 12; wait 1; descent; actor frame 12; }
        }
        else if (diff == 2)
        {
            script avatar { 
                actor frame 16; wait 1; actor frame 12; wait 1; descent;
                actor frame 16; wait 1; actor frame 12; wait 1; descent;
                actor frame 12; 
            }
        }
        else if (diff == 3)
        {
            script avatar { 
                actor frame 16; wait 1; actor frame 12; wait 1; descent;
                actor frame 16; wait 1; actor frame 12; wait 1; descent;
                actor frame 16; wait 1; actor frame 12; wait 1; descent;
                actor frame 12; 
            }
        }
        else if (diff >= 4)
        {
            script avatar { 
                actor frame 16; wait 1; actor frame 12; wait 1; descent;
                actor frame 16; wait 1; actor frame 12; wait 1; descent;
                actor frame 16; wait 1; actor frame 12; wait 1; descent;
                actor frame 16; wait 1; actor frame 12; wait 1; descent;
                actor frame 12; 
            }
        }
        
        // Ensure final position
        UI_move_object(avatar, [tx, ty, found_z], 0);
        return;
    }
    
    UI_item_say(avatar, "Blocked.");
}