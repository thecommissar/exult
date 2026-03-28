//testWater.uc

void testWater object#(0x3bb)()
{
    UI_error_message("testWater called");
    
    // Select a target tile
    UI_error_message("Click on a tile to check if it's water!");
    var target = UI_click_on_item(); // Doc: [obj, x, y, z] - 4 elements
    
    // Skip element 1 based on debug output: [obj, ?, x, y, z]
    var target_obj = target[0]; // obj
    var target_x = target[2];   // x
    var target_y = target[3];   // y
    var target_z = target[4];   // z
    
    // Get shape details
    var shape;
    if (target_obj)
    {
        shape = UI_get_item_shape(target_obj);
        UI_error_message("Object shape: " + shape);
    }
    else
    {
        shape = "flat (unknown shape)";
        UI_error_message("Flat shape: " + shape);
    }
    
    UI_error_message("Selected coordinates: x=" + target_x + ", y=" + target_y + ", z=" + target_z + ", obj=" + target_obj);
    
    // Check if the tile is water using UI_is_water intrinsic (like in wand.uc)
    var is_water_result = UI_is_water([target_x, target_y, target_z]);
    UI_error_message("UI_is_water result: " + is_water_result);
    
    // Bark result
    if (is_water_result)
    {
        UI_error_message("Tile is water - delayed bark 'Water Flag Found'");
        delayedBark(AVATAR, "@Water Flag Found@", 3);
    }
    else
    {
        UI_error_message("Tile is not water - delayed bark 'Not Water'");
        delayedBark(AVATAR, "@Not Water@", 3);
    }
}