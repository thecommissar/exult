/*
 * Forward Jump Wand (usecode-only)
 *
 * Design goals:
 * - Non-targeted jump: always jump forward in facing direction.
 * - Basic collision checks: don't jump through blocked tiles.
 * - Landing checks: allow platforms above water; deny water-only landing.
 * - No engine changes required.
 */

var getForwardJumpDelta(var direction)
{
	if (direction == EAST)
		return [true, 1, 0];
	else if (direction == WEST)
		return [true, -1, 0];
	else if (direction == NORTH)
		return [true, 0, 1];
	else if (direction == SOUTH)
		return [true, 0, -1];

	return [false, 0, 0];
}

var getJumpPathProfile()
{
	// 6 forward steps; relative z offset for collision probes.
	return [1, 2, 3, 2, 1, 0];
}

var probeStandableAt(var avatar, var x, var y, var check_z)
{
	var start_pos = UI_get_object_position(avatar);
	var start_z = UI_get_lift(avatar);

	UI_move_object(avatar, [x, y, check_z], 0);
	var moved = UI_get_object_position(avatar);
	var moved_z = UI_get_lift(avatar);

	var ok = (moved[X] == x && moved[Y] == y && moved_z == check_z);

	// Always restore avatar position after probe.
	UI_move_object(avatar, [start_pos[X], start_pos[Y], start_z], 0);

	return ok;
}

var evaluateLanding(var avatar, var destination, var start_z)
{
	var dest_x = destination[X];
	var dest_y = destination[Y];

	const int UP_TOL = 2;
	const int DOWN_TOL = 3;
	const int MIN_Z = 0;
	const int MAX_Z = 7;

	var z = start_z + UP_TOL;
	while (z >= start_z - DOWN_TOL)
	{
		if (z >= MIN_Z && z <= MAX_Z)
		{
			if (probeStandableAt(avatar, dest_x, dest_y, z))
			{
				destination[Z] = z;
				return [true, destination, ""];
			}
		}
		z -= 1;
	}

	// Water denial only when no standable surface was found.
	if (UI_is_water([dest_x, dest_y, start_z]))
		return [false, destination, "No standable landing (water)"];

	return [false, destination, "No standable landing"];
}

var validateForwardJump(var avatar, var start_pos, var direction, var destination)
{
	if (UI_is_pc_inside())
		return [false, destination, "Not enough room indoors"];

	var dir_delta = getForwardJumpDelta(direction);
	if (!dir_delta[1])
		return [false, destination, "Invalid facing direction"];

	var dx = dir_delta[2];
	var dy = dir_delta[3];
	var start_x = start_pos[X];
	var start_y = start_pos[Y];
	var start_z = UI_get_lift(avatar);
	var shape = UI_get_item_shape(avatar);
	var profile = getJumpPathProfile();
	var steps = UI_get_array_size(profile);

	var i = 1;
	while (i <= steps)
	{
		var tx = start_x + (dx * i);
		var ty = start_y + (dy * i);
		var probe_z = start_z + profile[i];
		if (probe_z < 0)
			probe_z = 0;

		// If any tile in the arc is blocked, cancel jump.
		if (!UI_is_not_blocked([tx, ty, probe_z], shape, FRAME_ANY))
			return [false, destination, "Path blocked at [" + tx + ", " + ty + "]"];

		i += 1;
	}

	return evaluateLanding(avatar, destination, start_z);
}

var barkJumpFailure(var reason)
{
	delayedBark(AVATAR, "@I can't jump there. " + reason + ".@", 1);
}

void wand shape#(476) ()
{
	var avatar = AVATAR;
	var direction = getFacing(avatar);
	var start_pos = UI_get_object_position(avatar);
	var dir_delta = getForwardJumpDelta(direction);

	if (!dir_delta[1])
	{
		UI_error_message("Jump failed: invalid facing direction.");
		return;
	}

	var dx = dir_delta[2];
	var dy = dir_delta[3];
	var jump_distance = 6;

	var destination = [
		start_pos[X] + (dx * jump_distance),
		start_pos[Y] + (dy * jump_distance),
		UI_get_lift(avatar)
	];

	UI_close_gumps();

	var validation = validateForwardJump(avatar, start_pos, direction, destination);
	if (!validation[1])
	{
		barkJumpFailure(validation[3]);
		return;
	}

	destination = validation[2];

	script avatar
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
