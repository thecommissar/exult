var evaluateLanding(var destination, var avatar_z)
{
	var start_position = UI_get_object_position(AVATAR);
	var start_z = UI_get_lift(AVATAR);
	var dest_x = destination[X];
	var dest_y = destination[Y];

	const int LANDING_Z_TOLERANCE = 2;
	const int LANDING_SCAN_MIN = 0;
	const int LANDING_SCAN_MAX = 7;

	var candidate_z = avatar_z + LANDING_Z_TOLERANCE;
	var best_z = -1;
	var failure_reason = "No landing space";

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
			failure_reason = "No standable landing (water)";
		}
		return [false, destination, failure_reason];
	}

	var z_delta = best_z - avatar_z;
	if (z_delta < 0)
		z_delta = 0 - z_delta;

	if (z_delta > LANDING_Z_TOLERANCE)
	{
		return [false, destination, "Landing height mismatch"];
	}

	destination[Z] = best_z;
	return [true, destination, ""];
}

// Build ordered jump nodes and their z-offset profile for a fixed-range jump.
var buildForwardJumpPathNodes(var start_position, var direction, var range, var arc_profile)
{
	if (range != 6 || UI_get_array_size(arc_profile) != 6)
	{
		return [[], []];
	}

	var dx = 0;
	var dy = 0;
	var start_x = start_position[X];
	var start_y = start_position[Y];
	var start_z = start_position[Z];

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
		return [[], []];
	}

	var ordered_tiles = [
		[start_x + dx, start_y + dy, start_z + arc_profile[1]],
		[start_x + (2 * dx), start_y + (2 * dy), start_z + arc_profile[2]],
		[start_x + (3 * dx), start_y + (3 * dy), start_z + arc_profile[3]],
		[start_x + (4 * dx), start_y + (4 * dy), start_z + arc_profile[4]],
		[start_x + (5 * dx), start_y + (5 * dy), start_z + arc_profile[5]],
		[start_x + (6 * dx), start_y + (6 * dy), start_z + arc_profile[6]]
	];

	var z_offsets = [
		arc_profile[1],
		arc_profile[2],
		arc_profile[3],
		arc_profile[4],
		arc_profile[5],
		arc_profile[6]
	];

	return [ordered_tiles, z_offsets];
}

// Validation phase: indoor check, path collision checks, and landing standability.
var validateForwardJump(var start_position, var destination, var direction, var range, var arc_profile)
{
	if (UI_is_pc_inside())
	{
		return [false, destination, "Not enough room indoors"];
	}

	var avatar_shape = UI_get_item_shape(AVATAR);
	var start_z = start_position[Z];
	var i = 0;
	var path_plan = buildForwardJumpPathNodes(start_position, direction, range, arc_profile);
	var ordered_tiles = path_plan[1];

	if (UI_get_array_size(ordered_tiles) != range)
	{
		return [false, destination, "Cannot jump that direction"];
	}

	while (i < UI_get_array_size(ordered_tiles))
	{
		var planned_node = ordered_tiles[i + 1];
		if (!UI_is_not_blocked(planned_node, avatar_shape, FRAME_ANY))
		{
			return [false, destination, "Path blocked"];
		}
		i += 1;
	}

	var landing_validation = evaluateLanding(destination, start_z);
	if (!landing_validation[1])
	{
		return [false, destination, landing_validation[3]];
	}

	return [true, landing_validation[2], ""];
}

var barkJumpFailure(var reason)
{
	delayedBark(AVATAR, "@Jump failed: " + reason + ".@", 1);
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
	
	var jump_range = 6;
	var jump_profile = [1, 2, 3, 2, 1, 0];
	var validation = validateForwardJump(position, destination, direction, jump_range, jump_profile);
	var can_jump = validation[1];

	if (can_jump)
	{
		destination = validation[2];
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
		barkJumpFailure(validation[3]);
}
