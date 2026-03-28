
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

//take Avatar's current location and destination to see if he can jump to it
var isPositionBlocked(var start_position, var destination, var direction)
{

	//if player is inside, automatically deny jumping:
	if (UI_is_pc_inside())
	{
		UI_error_message("Avatar is inside, abort jumping");
		return true;
	}	
	
	var start_x = start_position[X];
	var start_y = start_position[Y];
	var dx = 0;
	var dy = 0;
	var range = 0;
	var i = 1;
	const int SHAPE = 439; //CHIMNEY = z axis 2
	const int MAX_JUMP_HEIGHT = 0; //z level jump height, change as needed

	if (direction == EAST)
	{
		dx = 1;
		dy = 0;
		range = destination[X] - start_x;
	}
	else if (direction == WEST)
	{
		dx = -1;
		dy = 0;
		range = start_x - destination[X];
	}
	else if (direction == NORTH)
	{
		dx = 0;
		dy = 1;
		range = destination[Y] - start_y;
	}
	else if (direction == SOUTH)
	{
		dx = 0;
		dy = -1;
		range = start_y - destination[Y];
	}
	else
	{
		UI_error_message("Invalid jump direction");
		return true;
	}

	while (i <= range)
	{
		var probe_x = start_x + (i * dx);
		var probe_y = start_y + (i * dy);

		if (UI_is_not_blocked([probe_x, probe_y, MAX_JUMP_HEIGHT], SHAPE, FRAME_ANY))
		{
			UI_error_message("No impassible object located at " + probe_x + ", " + probe_y);
		}
		else //something is blocking the jump, no need to check the rest
		{
			UI_error_message("An impassible object located at " + probe_x + ", " + probe_y);
			return true;
		}
		i += 1;
	}

	if (!canLandAt(destination, start_position[Z]))
	{
		UI_error_message("Landing validation failed at " + destination[X] + ", " + destination[Y]);
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
	if (direction == EAST)
		desX = position[X] + 5;
	else if (direction == WEST)
		desX = position[X] - 5;
	else if (direction == NORTH)
		desY = position[Y] + 5;
	else if (direction == SOUTH)
		desY = position[Y] - 5;
	else
		UI_error_message("Something went wrong - direction not found.");
	destination = [desX, desY, desZ];
		
	UI_error_message("Destination x is " + destination[X] + ", " + destination[Y] + ", " + destination[Z]);
	UI_close_gumps();
	
	//determines if location can be jumped too (no obstacles higher than 2 z axis
	var is_blocked; 
	
	//check the destination Z levels up to 2 to see if it is "jumpable".  Increments Z up to 2
	while (desZ < 3)
	{
		is_blocked = isPositionBlocked(position, destination, direction);
		if (is_blocked)
			say("Landing position blocked at coordinates: " + destination[X] + ", " + destination[Y] + ", " + destination[Z]); 
		desZ += 1; 
		destination = [desX, desY, desZ];
	
	}
	
	if (!is_blocked)
	{
		var descend_Z = 3 - desZ;
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
			
			repeat descend_Z
			{
				descent;
				step direction; 
			};
		
			actor frame bowing; 
			actor frame standing; 
			
		}
	}
	else 
		delayedBark(AVATAR, "@I can't jump there.@", 1);
}
