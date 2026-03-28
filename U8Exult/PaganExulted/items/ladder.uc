void ladder shape#(1100) ()    
{
	var direction = getFacing(AVATAR);
	var position = UI_get_object_position(AVATAR);
	UI_close_gumps();
	if (event == DOUBLECLICK)
	{
		//ascend the ladder
		if (position[Z] < 5)
		{
			script AVATAR
			{
				actor frame USE;
				actor frame STAND;
				rise;
				actor frame USE;
				actor frame STAND;
				rise;
				actor frame USE;
				actor frame STAND;
				rise;
				actor frame USE;
				actor frame STAND;
				rise;
				actor frame USE;
				actor frame STAND;
				rise;
				actor frame bowing; 
				actor frame standing; 
				
			}
		
		}
		else //desend the ladder
		{
			script AVATAR
			{
				actor frame USE;
				actor frame STAND;
				descent;
				actor frame USE;
				actor frame STAND;
				descent;
				actor frame USE;
				actor frame STAND;
				descent;
				actor frame USE;
				actor frame STAND;
				descent;
				actor frame USE;
				actor frame STAND;
				descent;
				actor frame bowing; 
				actor frame standing; 
				
			}

		}	
	}	

}