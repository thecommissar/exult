/*
 * Forward jump wand.
 *
 * Shape 476 is bound to SPACE in patch/patchkeys.txt.  This stays pure usecode:
 * no engine helpers, no new data files, and no mouse target.
 */

var u8eGetFacingDelta(var direction)
{
	if (direction == EAST)
		return [1, 0];
	else if (direction == WEST)
		return [-1, 0];
	else if (direction == NORTH)
		return [0, -1];
	else if (direction == SOUTH)
		return [0, 1];

	return [0, 0];
}

var u8eCanLandAvatar(var x, var y, var z)
{
	/*
	 * Use the canonical Avatar shape for collision dimensions.  The redirected
	 * U8 avatar visuals may not carry reliable TFA collision data, while the SI
	 * male/female Avatar shapes are both 1x1x4.
	 */
	const int AVATAR_COLLISION_SHAPE = SHAPE_MALE_AVATAR;

	if (z == 0 && UI_is_water([x, y, z]))
		return false;

	return UI_is_not_blocked([x, y, z], AVATAR_COLLISION_SHAPE, 0);
}

var u8eFindJumpLanding(var avatar, var start_pos, var direction)
{
	var delta = u8eGetFacingDelta(direction);
	var dx = delta[1];
	var dy = delta[2];

	if (dx == 0 && dy == 0)
		return [0, start_pos, "I can't jump that way"];

	var start_x = start_pos[X];
	var start_y = start_pos[Y];
	var start_z = UI_get_lift(avatar);

	var min_z = start_z - 3;
	if (min_z < 0)
		min_z = 0;

	var distance = 3;
	while (distance >= 1)
	{
		var landing_x = start_x + (dx * distance);
		var landing_y = start_y + (dy * distance);
		var z = start_z + 3;

		while (z >= min_z)
		{
			if (u8eCanLandAvatar(landing_x, landing_y, z))
				return [1, [landing_x, landing_y, z], ""];

			z -= 1;
		}

		distance -= 1;
	}

	return [0, start_pos, "I can't jump there"];
}

var u8eCreateJumpMarker(var landing_pos)
{
	const int JUMP_MARKER_SHAPE = 247;
	const int SI_DONT_RENDER = 22;

	var marker = UI_create_new_object(JUMP_MARKER_SHAPE);
	if (!marker)
		return false;

	marker->set_item_flag(SI_DONT_RENDER);
	marker->set_item_flag(TEMPORARY);
	UI_update_last_created(landing_pos);

	return marker;
}

void u8ePinAvatarToMarker object#() ()
{
	var avatar = UI_get_avatar_ref();
	var pos = UI_get_object_position(item);
	UI_move_object(avatar, [pos[X], pos[Y], pos[Z]], 0);
	UI_remove_item(item);
	UI_set_camera(avatar);
	UI_center_view(avatar);
}

var u8eBarkJumpFailure(var reason)
{
	delayedBark(AVATAR, "@" + reason + ".@", 1);
}

void u8eJumpForward(var avatar)
{
	var direction = getFacing(avatar);
	var start_pos = UI_get_object_position(avatar);
	var landing = u8eFindJumpLanding(avatar, start_pos, direction);

	UI_close_gumps();

	if (!landing[1])
	{
		u8eBarkJumpFailure(landing[3]);
		return;
	}

	var landing_pos = landing[2];
	var marker = u8eCreateJumpMarker(landing_pos);
	if (!marker)
	{
		u8eBarkJumpFailure("I can't jump there");
		return;
	}

	script avatar
	{
		actor frame bowing;
		actor frame standing;
		rise;
		step direction;
		rise;
		step direction;
		descent;
		step direction;
		descent;
		actor frame bowing;
		actor frame standing;
	}

	script marker after 8 ticks call u8ePinAvatarToMarker;
}

void wand shape#(476) ()
{
	u8eJumpForward(UI_get_avatar_ref());
}
