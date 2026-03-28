
// New number specified, unused in the original code.
// Both void and var can work here, but var has the advantage of returning results.
// Assuming it works similar to the UI_create_new_object2 intrinsic, the values are:
// 1 for success, 0 for failure, opposite many other earlier (non-2) functions.
// 2017-03-15 KC changed to set_item_frame_rot to preserve rotated shapes (barrier).

var createNewShape2 0x9CA (var shape, var frame, var pos_x, var pos_y, var pos_z)
{
	var new_shape = UI_create_new_object2(shape, [pos_x, pos_y, pos_z]);
	
	// Check that it was created
	if (new_shape)
	{
		// new_shape->set_lift(pos_z);
		new_shape->set_item_frame_rot(frame);
		// Not sure if this is required in Exult, but common in the original game:
		new_shape->clear_item_flag(TEMPORARY);
		return 1;
	}
	else
		return 0;
}

var createNewTempShape2 0x9D5  (var shape, var frame, var pos_x, var pos_y, var pos_z)
{
	var new_shape = UI_create_new_object2(shape, [pos_x, pos_y, pos_z]);
	
	// Check that it was created
	if (new_shape)
	{
		// new_shape->set_lift(pos_z);
		new_shape->set_item_frame_rot(frame);
		// Make this item disappear later.
		new_shape->set_item_flag(TEMPORARY);
		return 1;
	}
	else
		return 0;
}
