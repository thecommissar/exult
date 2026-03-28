var isEquipped(var npc, var itemtocheck)
{
	var spot;
	var equipped = false;
	var spots = [BG_WEAPON_HAND, BG_OFF_HAND, BG_BACKPACK, BG_CLOAK, BG_AMULET, BG_HEAD, BG_GLOVES,
			 BG_RIGHT_RING, BG_LEFT_RING, BG_QUIVER, BG_BELT, BG_TORSO, BG_FEET,
			 BG_LEGS, BG_BACK_SHIELD, BG_BACK_2H];

	for (spot in spots)
	{
		if (UI_is_readied(npc, spot, itemtocheck, FRAME_ANY))
		{
			UI_error_message("Item " + itemtocheck + " is readied in " + spot + ".");
			equipped = true;
				
		}	
		else
		{
			UI_error_message("Item " + itemtocheck + " is not readied in " + spot + ".");
			

		}	


	}
	return equipped;


}