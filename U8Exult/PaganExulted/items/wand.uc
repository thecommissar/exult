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

var getForwardJumpDelta(var direction)
{
	var dx = 0;
	var dy = 0;

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
		return [false, 0, 0];
	}

	return [true, dx, dy];
}

var reportBlocked(var tx, var ty, var destination)
{
	return [false, destination, "Path blocked at [" + tx + ", " + ty + "]"];
}

var reportClearStep(var tx, var ty)
{
	return [true, tx, ty];
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
	var start_x = start_position[X];
	var start_y = start_position[Y];
	var step = 1;
	var direction_delta = getForwardJumpDelta(direction);

	if (!direction_delta[1])
	{
		return [false, destination, "Cannot jump that direction"];
	}

	var dx = direction_delta[2];
	var dy = direction_delta[3];

	if (UI_get_array_size(arc_profile) != range)
	{
		return [false, destination, "Invalid jump profile"];
	}

	while (step <= range)
	{
		var tx = start_x + (step * dx);
		var ty = start_y + (step * dy);
		var planned_node = [tx, ty, start_z + arc_profile[step]];

		if (!UI_is_not_blocked(planned_node, avatar_shape, FRAME_ANY))
		{
			return reportBlocked(tx, ty, destination);
		}
		reportClearStep(tx, ty);
		step += 1;
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
	var jump_steps = 6;
	var direction_delta = getForwardJumpDelta(direction);
	if (!direction_delta[1])
	{
		UI_error_message("Something went wrong - direction not found.");
		return;
	}
	var dx = direction_delta[2];
	var dy = direction_delta[3];
	destination = [
		position[X] + (jump_steps * dx),
		position[Y] + (jump_steps * dy),
		position[Z]
	];

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
