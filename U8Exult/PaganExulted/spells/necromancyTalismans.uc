//necromancyTalismans.uc
//handle Necromancy Spell Talisman Double Clicks

void necromancyTalismans shape#(1087) ()

{
			UI_error_message("------------------------------------");

    if (event == DOUBLECLICK){
		UI_error_message("Attempted Double Click of Shape 1087");

		UI_error_message("Attempt to close gumps");
		UI_close_gumps();
		UI_error_message("Gumps should be closed");
		
		//get frame of necromancyTalismans
		var necromancyFrame = UI_get_item_frame(item);
		var outFrameMessage = "Shape 1087 Frame is " + necromancyFrame;

		UI_error_message(outFrameMessage);
		UI_error_message("Try to match desired frame");

		var caster = getOuterContainer(item);
		UI_error_message("caster variable getOuterContainer(item) content:" + caster); 		
		var curMana = caster->get_npc_prop(MANA);
		UI_error_message("curMana function eval using -caster->get_npc_prop(MANA)- eval before running proc: " + curMana); 

		if (necromancyFrame == 0)  //necromancyOpenGround
		{
			UI_error_message("Frame 0 Detected - Spell Execution Start");
			caster->necromancyOpenGround();
			UI_error_message("Spell Execution Finished");
		}
		
		else if (necromancyFrame == 1)  //necromancyCallQuake
		{
			UI_error_message("Frame 1 Detected - Spell Execution Start");
			caster->necromancyCallQuake();
			UI_error_message("Spell Execution Finished");
		}

		else if (necromancyFrame == 2)  //necromancyRockFlesh
		{
			UI_error_message("Frame 2 Detected - Spell Execution Start");
			caster->necromancyRockFlesh();
			UI_error_message("Spell Execution Finished");
		}

		else if (necromancyFrame == 3)  //necromancyCreateGolem
		{
			UI_error_message("Frame 3 Detected - Spell Execution Start");
			caster->necromancyCreateGolem();
			UI_error_message("Spell Execution Finished");
		}		

		else if (necromancyFrame == 4)  //necromancyDeathSpeak
		{
			UI_error_message("Frame 4 Detected - Spell Execution Start");
			caster->necromancyDeathSpeak();
			UI_error_message("Spell Execution Finished");
		}		

		else if (necromancyFrame == 5)  //necromancyMaskOfDeath
		{
			UI_error_message("Frame 5 Detected - Spell Execution Start");
			caster->necromancyMaskOfDeath();
			UI_error_message("Spell Execution Finished");
		}

		else if (necromancyFrame == 6)  //necromancySummonDead
		{
			UI_error_message("Frame 6 Detected - Spell Execution Start");
			caster->necromancySummonDead();
			UI_error_message("Spell Execution Finished");
		}

		else if (necromancyFrame == 7)  //necromancyWithstandDeath
		{
			UI_error_message("Frame 7 Detected - Spell Execution Start");
			caster->necromancyWithstandDeath();
			UI_error_message("Spell Execution Finished");
		}

		else if (necromancyFrame == 8)  //necromancyGrantPeace
		{
			UI_error_message("Frame 8 Detected - Spell Execution Start");
			caster->necromancyGrantPeace();
			UI_error_message("Spell Execution Finished");
		}



	}
			UI_error_message("------------------------------------");
}


