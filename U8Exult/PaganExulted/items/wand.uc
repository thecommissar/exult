
//take Avatar's current location and destination to see if he can jump to it
var isPositionBlocked(var start_position, var destination, var direction)
{

	//if player is inside, automatically deny jumping:
	if (UI_is_pc_inside())
	{
		UI_error_message("Avatar is inside, abort jumping");
		return true;
	}	
	//if destination tile is water, automatically deny jumping:
	if (UI_is_water([destination]))
	{
		UI_error_message("Destination tile is water, abort jumping");	
		return true;
	}	
	
	var start_x = start_position[X];
	var start_y = start_position[Y];
	const int SHAPE = 439; //CHIMNEY = z axis 2
	const int MAX_JUMP_HEIGHT = 0; //z level jump height, change as needed


	
	if (start_x < destination[X])
		start_x = start_x + 1;
	else if (start_y < destination[Y])	
		start_y = start_y - 1;
	else if (start_x > destination[X])
		start_x = start_x - 1;
	else // if (start_y > destination[Y])	
		start_y = start_y + 1;
	
	
	if (start_x < destination[X])
	{
		while (start_x < destination[X])
		{
			if (UI_is_not_blocked([start_x, start_y, MAX_JUMP_HEIGHT], SHAPE, FRAME_ANY))
			{
				UI_error_message("No impassible object located at " + start_x + ", " + start_y);
				
				
			}	
			else //something is blocking the jump, no need to check the rest
			{
				UI_error_message("An impassible object located at " + start_x + ", " + start_y);	
				return true;
			}	
			start_x += 1;
		}
	
	
	}
	else if (start_x > destination[X])
	{
		while (start_x > destination[X])
		{
			if (UI_is_not_blocked([start_x, start_y, MAX_JUMP_HEIGHT], SHAPE, FRAME_ANY))
			{
				UI_error_message("No impassible object located at " + start_x + ", " + start_y);
				
				
			}	
			else //something is blocking the jump, no need to check the rest
			{
				UI_error_message("An impassible object located at " + start_x + ", " + start_y);	
				return true;
			}	
			start_x -= 1;
		}
	
	
	}
	else if (start_y < destination[Y])
	{
		while (start_y < destination[Y])
		{
			if (UI_is_not_blocked([start_x, start_y, MAX_JUMP_HEIGHT], SHAPE, FRAME_ANY))
			{
				UI_error_message("No impassible object located at " + start_x + ", " + start_y);
				
				
			}	
			else //something is blocking the jump, no need to check the rest
			{
				UI_error_message("An impassible object located at " + start_x + ", " + start_y);	
				return true;
			}	
			start_y += 1;
		}
	
	
	}	
	else if (start_y > destination[Y])
	{
		while (start_y > destination[Y])
		{
			if (UI_is_not_blocked([start_x, start_y, MAX_JUMP_HEIGHT], SHAPE, FRAME_ANY))
			{
				UI_error_message("No impassible object located at " + start_x + ", " + start_y);
				
				
			}	
			else //something is blocking the jump, no need to check the rest
			{
				UI_error_message("An impassible object located at " + start_x + ", " + start_y);	
				return true;
			}	
			start_y -= 1;
		}
	
	
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
		desY = position[Y];
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