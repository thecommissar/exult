
var canLandAt(var destination, var avatar_z)
{
	var avatar_shape = UI_get_item_shape(AVATAR);
	var start_position = UI_get_object_position(AVATAR);
	var start_z = UI_get_lift(AVATAR);
	var dest_x = destination[X];
	var dest_y = destination[Y];

	const int LANDING_Z_TOLERANCE = 2;
	const int LANDING_SCAN_MIN = 0;
	const int LANDING_SCAN_MAX = 7;

	var candidate_z = avatar_z + LANDING_Z_TOLERANCE;
	var best_z = -1;

	while (candidate_z >= avatar_z - LANDING_Z_TOLERANCE)
	{
		if (candidate_z >= LANDING_SCAN_MIN && candidate_z <= LANDING_SCAN_MAX)
		{
			UI_move_object(AVATAR, [dest_x, dest_y, candidate_z], 0);
			var new_position = UI_get_object_position(AVATAR);
			var new_z = UI_get_lift(AVATAR);

			if (new_position[X] == dest_x && new_position[Y] == dest_y && new_z == candidate_z)
			{
				best_z = candidate_z;
				candidate_z = avatar_z - LANDING_Z_TOLERANCE - 1; //break
			}
		}
		candidate_z -= 1;
	}

	UI_move_object(AVATAR, [start_position[X], start_position[Y], start_z], 0);

	if (best_z == -1)
	{
		if (UI_is_water([destination]))
		{
			UI_error_message("No standable landing surface (water/liquid only)");
		}
		return false;
	}

	var z_delta = best_z - avatar_z;
	if (z_delta < 0)
		z_delta = 0 - z_delta;

	if (z_delta > LANDING_Z_TOLERANCE)
	{
		UI_error_message("Landing z delta too high: " + z_delta);
		return false;
	}

	destination[Z] = best_z;
	return true;
}

// Validate each forward jump step against the scripted jump arc profile.
var isPositionBlocked(var start_position, var destination, var direction)
{
	if (UI_is_pc_inside())
	{
		return true;
	}

	var avatar_shape = UI_get_item_shape(AVATAR);
	var start_x = start_position[X];
	var start_y = start_position[Y];
	var start_z = start_position[Z];
	var dx = 0;
	var dy = 0;
	var i = 0;
	var step_count = 6;
	var jump_profile = [1, 2, 3, 2, 1, 0];

	if (direction == EAST)
	{
		dx = 1;
		dy = 0;
	}
	else if (direction == WEST)
	{
		dx = -1;
		dy = 0;
	}
	else if (direction == NORTH)
	{
		dx = 0;
		dy = 1;
	}
	else if (direction == SOUTH)
	{
		dx = 0;
		dy = -1;
	}
	else
	{
		return true;
	}

	while (i < step_count)
	{
		var step_index = i + 1;
		var probe_x = start_x + (step_index * dx);
		var probe_y = start_y + (step_index * dy);
		var arc_z = start_z + jump_profile[i];

		// Body clearance at current jump arc z.
		if (!UI_is_not_blocked([probe_x, probe_y, arc_z], avatar_shape, FRAME_ANY))
		{
			return true;
		}

		// Near the end of the jump, also validate the tile can be landed on.
		if (i >= (step_count - 2))
		{
			var end_probe = [probe_x, probe_y, start_z];
			if (!canLandAt(end_probe, start_z))
			{
				return true;
			}
		}

		i += 1;
	}

	if (!canLandAt(destination, start_z))
	{
		return true;
	}

	return false;
}


void wand shape#(476) ()    
{
	var direction = getFacing(AVATAR);
	var position = UI_get_object_position(AVATAR);
	var destination; //get tile Avatar is going to land on:
	var desX = position[X];
	var desY = position[Y];
	var desZ = position[Z];
	var jump_steps = 6;
	if (direction == EAST)
		desX = position[X] + jump_steps;
	else if (direction == WEST)
		desX = position[X] - jump_steps;
	else if (direction == NORTH)
		desY = position[Y] + jump_steps;
	else if (direction == SOUTH)
		desY = position[Y] - jump_steps;
	else
		UI_error_message("Something went wrong - direction not found.");
	destination = [desX, desY, desZ];

	UI_close_gumps();
	
	// Determines if location can be jumped to with the scripted arc.
	var is_blocked = isPositionBlocked(position, destination, direction);
	
	if (!is_blocked)
	{
		script AVATAR
		{
			actor frame bowing; 
			actor frame standing; 
			rise;
			step direction;
			rise;
			step direction; 
			rise;
			step direction; 
			descent;
			step direction; 
			descent;
			step direction; 
			descent;
			step direction; 
		
			actor frame bowing; 
			actor frame standing; 
			
		}
	}
	else 
		delayedBark(AVATAR, "@I can't jump there.@", 1);
}
