


//To train in stats where an attribute is changed by a standard number with no other calculations (ex: str + 2)
//UI_set_npc_prop(object obj, int prop, int delta)
var trainStats(var npc, var stat_type, var change)
{
	var training_points = UI_get_npc_prop(npc, TRAINING);
	var npc_stat = UI_get_npc_prop(npc, stat_type);

   // Check if stat plus change exceeds 30
    if (npc_stat + change > 30) {
        var excess = npc_stat + change - 30; // Calculate excess points
        UI_set_npc_prop(npc, stat_type, 30 - npc_stat); // Increment stat to the maximum of 30
        UI_set_npc_prop(npc, TRAINING, training_points + excess); // Return unused training points
    } else {
        // Increment stat by the change if within limits
        UI_set_npc_prop(npc, stat_type, change); // Increment stat by `change`
        UI_set_npc_prop(npc, TRAINING, -change); // Decrement training points by `change`
    }
	

}


//use this if you want to train with the "rubber-band formula" for Combat. Subtracts NPC's Dex minus NPC combat, divides by 2 and adds 1

var trainCombat2(var npc)
{

	//determine how much Combat Avatar has. Adding it based on "rubber band" formula used in U7 for combat and magic:
	//(NPC's Dex - NPC's combat)+1) / 2.		
	
	//get Dex and combat skill, then calculate
	var npc_combat = UI_get_npc_prop(npc, COMBAT);
	var npc_dex = UI_get_npc_prop(npc, DEXTERITY);
	var combat_bonus = (npc_dex - npc_combat + 1) / 2;
	
	UI_set_npc_prop(npc, COMBAT, combat_bonus);
	
	//get new combat
	npc_combat = UI_get_npc_prop(npc, COMBAT);
	
	//subtract training points
	UI_set_npc_prop(npc, TRAINING, -1);
	UI_error_message("Combat points added to npo is  " + combat_bonus + " NPC's combat is now " + npc_combat);
	
	
}