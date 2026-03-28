void testFocus shape# (0x43f)()
{
	var quality = UI_get_item_quality(item);
	var frame = UI_get_item_frame(item);



	if (event == DOUBLECLICK)
	{
		UI_close_gumps();
				
		if (frame == 0)
			UI_item_say(AVATAR, "Frame clicked is 0");
		else if (frame == 1)
			UI_item_say(AVATAR, "Frame clicked is 1");
		else if (frame == 2)
			UI_item_say(AVATAR, "Frame clicked is 2");		
		else if (frame == 3)
			UI_item_say(AVATAR, "Frame clicked is 3");	
		else if (frame == 4)
			UI_item_say(AVATAR, "Frame clicked is 4");		
		else if (frame == 5)
			UI_item_say(AVATAR, "Frame clicked is 5");	
		else if (frame == 6)
			UI_item_say(AVATAR, "Frame clicked is 6");		
		else
			UI_item_say(AVATAR, "Frame clicked is " + frame);
			
		
	}
	
}	