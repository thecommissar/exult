
void guardArrest()
{
	var counter = 0;
	var npc;
	var party = UI_get_party_list();
	var loot_pos;
	

	var cellpos= [0679, 0582, 0];
	// fade to black
	UI_fade_palette(3, 0, false); 
	
	UI_set_item_flag(PRIDGARM, SI_ZOMBIE); //set on Pridgarm so he'll offer the key out. 
	
	//teleport party to the slammer
	UI_move_object(PARTY, cellpos, true);
	
	//to add: confiscate gold to pay for fine
	var partyGold = countGold(PARTY);
	var confiscated_gold = partyGold / 3;
	UI_error_message("Avatar arrested. Party gold is: " + partyGold + " and confiscated gold is: " + confiscated_gold);
	
	if (partyGold < 1)
		confiscated_gold = 0;
	
	//take gold for fine	
	chargeGold(confiscated_gold);
	
	//karma hit
	subtractKarma(15);
	
	
	//remove goods from party
	for (npc in party with index to max)
		{
			if (counter == 0)
				loot_pos = [0688, 0585, 02];
			if (counter == 1)
				loot_pos = [0691, 0585, 02];
			if (counter == 3)
				loot_pos = [0688, 0587, 02];			
			if (counter == 4)
				loot_pos = [0699, 0585, 02];	
			if (counter == 5)
				loot_pos = [0702, 0585, 02];
			if (counter == 6)
				loot_pos = [0688, 0585, 02];	
			if (counter == 7)
				loot_pos = [0699, 0587, 02];		
			if (counter == 8)
				loot_pos = [0702, 0587, 02];			
				
			dropAllItems(npc, loot_pos);
				counter += 1;
		
		}
	
	script AVATAR after 30 ticks
	{
		call GenericUnfade;
	}
	
	
}
