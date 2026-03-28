/*
 *	Copyright 2019 AgentOrangeGuy 
 *
 *	This program is free software: you can redistribute it and/or modify it under the terms
 *	of the GNU General Public License as published by the Free Software Foundation,
 *	either version 2 of the License, or (at your option) any later version.
 *
 *	This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
 *	without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 *	See the GNU General Public License for more details.
 *
 *	You should have received a copy of the GNU General Public License along with this program.
 *	If not, see <http://www.gnu.org/licenses/>.
 *
 *  Healer Script
 */
 
 var healScript(var npc, var healer, var price)
 {
	var npc_num = npc->get_npc_number();
	var npc_name = npc->get_npc_name();
	var avatar = UI_get_avatar_ref();
	var max_health = npc->get_npc_prop(STRENGTH); 
	var current_health = npc->get_npc_prop(HEALTH);
	var AvatarKarma = getKarma();
	
	//healer prices
	const int SASHA_HEAL_PRICE = 40;
	const int SASHA_CURE_PRICE = 15;
	const int SASHA_REZ_PRICE = 400;
	
	if (npc == AVATAR)
	{
		max_health = avatar->get_npc_prop(STRENGTH); 
		current_health = avatar->get_npc_prop(HEALTH);
		UI_error_message("Avatar number is: " + npc_num);
		UI_error_message("Avatar current health is: " + current_health);
	}
	
	UI_error_message("-----------------------");
	UI_error_message("NPC number is: " + npc_num);
	UI_error_message("NPC current health is: " + current_health);
	
	//for npc healer convos. Leave for default.
	var giveprice = "@Healing is " + price + " gold. Agreeable?@";
	var success = "" + healer + " successfuly binds " + npc_name + "'s wounds.";
	var cant_afford = "@I'm sorry but you cannot afford this.@";
	var declined_help = "@Come back later if thou dost need help.@";
	var not_hurt = "@You look fine to me.@";
	
	//Change individual healer scripts as needed for different text
	if (healer == DEZANA)
	{
		giveprice = "@I see thy injury, " + npc_name + ". It will cost you 30 gold, interested?";
		success = "Dezana approaches " + npc_name + " and binds their wounds.";
		cant_afford = "@You must pay before I can heal you.@";
		declined_help = "@Very well.@";
	}
	else if (healer == SASHA)
	{
		giveprice = "@I see thy injury, " + npc_name + ". Wilt thou make an offering of " + SASHA_HEAL_PRICE + " gold?";
		success = "Sasha approaches " + npc_name + " and binds their wounds.";
		cant_afford = "@If thou wilt not pay, I cannot heal thee.@";
		declined_help = "@Is there aught else I can do for thee?@";
		not_hurt = "@Don't waste my time! You are not wounded! 'Tis hard enough tending to those truly sick. Begone!@";
	}
	else if (healer == STEPHANIE)
	{
		giveprice = "@I sense thy injury, " + npc_name + ". Wilt thou make an offering of 25 gold?@";
		success = "She closes her eyes, puts a delicate hand on " + npc_name + "'s brow and chants softly. " + npc_name + " feels much better.";
		cant_afford = "@I'm sorry. Without an offering I cannot heal you.@";
		declined_help = "Her blue eyes pierce you. @What else can I do for you?@";
		not_hurt = "She feels each brow and holds her ear close to your mouths. @None of you are sick!@";
	}
	
	else if (healer == TOBATHA)
	{
		giveprice = "@Aye, I see thy wound, " + npc_name + " Wilt thou make an offering of 30 gold?@";
		success = "Laying hands upon " + npc_name + ", Tobatha mends the wounds.";
		cant_afford = "@Well, if thou wilt not pay, why should I heal thee?@";
		declined_help = "@Well, if thou wilt not pay, why should I heal thee?@";
		not_hurt = "@What do you mean, heal? None of you are wounded!@";
	}	
	
	//Start of heal script. 	
	if (npc)
	{
		if  (current_health <  max_health)
		{
			say(giveprice);
			if (askYesNo())
			{
				if (hasGold(price))
				{
					say(success);
					chargeGold(price);
					
					//First, zero out health to avoid going over or under
					UI_set_npc_prop(npc, HEALTH, -current_health); 
		
					//set health back to max
					UI_set_npc_prop(npc, HEALTH, max_health);
				}
				else if (healer == STEPHANIE && AvatarKarma > 40) //for freebies based on karma
				{
					say("@I sense your hesitation is based on your empty pockets. I also sense your cause is a just one.@");
					say("She closes her eyes, puts a delicate hand on " + npc_name + "'s brow and chants softly. " + npc_name + " feels much better.@");
    					
					//First, zero out health to avoid going over or under
					UI_set_npc_prop(npc, HEALTH, -current_health); 
		
					//set health back to max
					UI_set_npc_prop(npc, HEALTH, max_health);
				
				}
				else if (healer == TOBATHA)
				{
					if (AvatarKarma >= 40)
					{
						say("@Thou art not too bad, for a youngster. All right, I'll heal ye.@ Laying hands upon " + npc_name + ", Tobatha mends the wounds.@");
						//First, zero out health to avoid going over or under
						UI_set_npc_prop(npc, HEALTH, -current_health); 
			
						//set health back to max
						UI_set_npc_prop(npc, HEALTH, max_health);
					}
					else
						say("@You youngsters think everything should be free!@");
				
				}
				else
					say(cant_afford);
			}
			else say(declined_help);
		}
		else say(not_hurt);
	}
	else say(declined_help);
}
 
 var cureScript(var npc, var healer, var price)
 {
 	var npc_num = npc->get_npc_number();
	var npc_name = npc->get_npc_name();
	
	var isPoisoned = UI_get_item_flag(npc, POISONED);
	
	var AvatarKarma = getKarma();
	
	UI_error_message("-----------------------");
	UI_error_message("NPC number is: " + npc_num);
	
	
	//for npc healer convos. Leave for default.
	var giveprice = "@To cure poison is " + price + " gold. Agreeable?@";
	var success = "" + healer + " successfuly cures " + npc_name + " of poison.";
	var cant_afford = "@I'm sorry but you cannot afford this.@";
	var declined_help = "@Come back later if thou dost need help.@";
	var not_hurt = "@You don't look poisoned to me.@";
	
	//Change individual healer scripts as needed for different text
	if (healer == DEZANA)
	{
		giveprice = "@You look poisoned to me.@ She nods at " + npc_name + ". It'll cost you 10 gold, interested?";
		success = "Dezana grabs a vial and pours it down " + npc_name + "'s throat. " + npc_name + " feels much better.";
		cant_afford = "@You must pay before I can cure you.@";
		declined_help = "@As you wish.@";
		not_hurt  	= "@Perhaps you have a hangover, 'cause you aren't poisoned.@";
	}
	if (healer == SASHA)
	{
		giveprice = "@I sense thou art poisoned, " + npc_name + ". Wilt thou make an offering of " + 40 + " gold?";
		success = "Sasha grabs a vial and pours it down " + npc_name + "'s throat. " +npc_name + " feels much better.";
		cant_afford = "@If thou wilt not pay, I cannot cure thee.@";
		declined_help = "@Is there aught else I can do for thee?@";
		var not_hurt = "@Don't waste my time! You are not poisoned! 'Tis hard enough tending to those truly sick. Begone!@";
	
	}
	if (healer == STEPHANIE)
	{
		giveprice = "@I sense thou art poisoned, " + npc_name + ". Wilt thou make an offering of " + 5 + " gold?";
		success = "@Placing " + npc_name + "'s hand over her heart, she closes her eyes and whispers something. The fever leaves " + npc_name + "'s brow.";
		cant_afford = "@I cannot cure you if you won't tithe.@";
		declined_help = "Her blue eyes pierce you. @What else can I do for you?@";
		var not_hurt = "@Holding " + npc_name + "'s hand against her lips she states @You are not poisoned.@";
	
	}
	
	if (healer == TOBATHA)
	{
	
		giveprice = "@Aye, " + npc_name + ", I can tell that thou art poisoned. Wilt thou make an offering of 10 gold?@";
		success = "Laying hands upon " + npc_name + ", Tobatha removes the poison.";
		cant_afford = "@Well if thou won't pay, thou won't get cured!@";
		declined_help = "@What else ya want?@";
		var not_hurt = "@What do you mean, cure? Thou art not poisoned!@";
	
	
	}
	
	//Start of cure script. 	
	if (npc)
	{
		if (isPoisoned)
		{
			say(giveprice);
			if (askYesNo())
			{
				if (hasGold(price))
				{
					say(success);
					chargeGold(price);
					UI_clear_item_flag(npc, POISONED);
				}
				else if (healer == STEPHANIE && AvatarKarma > 40) //for freebies based on karma
				{
					say("A tear comes to her eyes. @I should have known you would not ask unless you were in grave need.@");
					say("@Come, put your hand on my heart.@ Placing  " + npc_name + "'s hand over her heart, she closes her eyes and whispers something.");
					say("The fever leaves " + npc_name + "'s brow.@");
    					
					UI_clear_item_flag(npc, POISONED);
				}
				else if (healer == TOBATHA)
				{
					if (AvatarKarma >= 40)
					{
						say("@Thou art not too bad, for a youngster. All right, I'll cure ye.@ Laying hands upon " + npc_name + ", Tobatha removes the poison.@");
						UI_clear_item_flag(npc, POISONED);
					}
					else
						say("@You youngsters think everything should be free!@");
				
				}
				else
					say(cant_afford);
			}
			else say(declined_help);
		}
		else say(not_hurt);
	}
	else say(declined_help);
 
 
 }
 
 var resurrectScript(var healer, var price)
 {
	var party = UI_get_party_list();
	var body;
	var body_ground = findBody(healer); //finds bodies on the ground
	var body_carrying = getBody(party); //finds bodies that are carried
	
	var valid_body_ground = body_ground->get_body_npc(); //ref to valid npc body on ground
	var valid_body_carrying = body_carrying->get_body_npc(); //ref to valid npc body in party
	var partyGold = UI_count_objects(PARTY, SHAPE_GOLD_COIN, QUALITY_ANY, FRAME_ANY);
	var remainder = (price - partyGold);

//	UI_error_message("npcbody var is: " + npcbody);

  	//for npc healer convos. Leave for default.
	var giveprice = "@Resurrection costs 400 gold, interested?@";
	var success = "@And the dead live again!@";
	var cant_afford = "@I'm sorry but you cannot afford this.@";
	var declined_help = "@Come back later if thou dost need help.@";
	var not_hurt = "@You don't look poisoned to me.@";
	var body_nearby;
	if (body_ground > 0 || body_carrying > 0)
		body_nearby = "@I sense that someone has met a terrible fate. Will you make an offering of 350 gold?@";
	
	//Change individual healer scripts as needed for different text
	if (healer == DEZANA)
	{
		success = "Dezana lays hands upon the corpse...@Doman...thixus...anretu! And the dead live again!@";
		cant_afford = "@You don't have enough gold. You might think about a proper burial.@";
		declined_help = "@As you wish.@";
		not_hurt = "@I don't see a body that can be resurrected.@";
	}
	
	if (healer == SASHA)
	{
		success = "Dezana lays hands upon the corpse...@Doman...thixus...anretu! And the dead live again!@";
		cant_afford = "@You don't have enough gold. You might think about a proper burial.@";
		declined_help = "@As you wish.@";
		not_hurt = "@I don't see a body that can be resurrected.@";
	}	
	
	if (healer == STEPHANIE)
	{
		success = "Stephanie lays hands upon the corpse...@Doman...thixus...anretu! And the dead live again!@";
		cant_afford = "@You haven't enough gold. I'm sorry, all I can do is grieve with you.@";
		declined_help = "@As you wish.@";
		not_hurt = "@I don't see a body that can be resurrected.@";
	}	
	if (healer == TOBATHA)
	{
		giveprice = "@Wilt thou make an offering of 400 gold?@";
		success = "Tobatha lays hands upon the corpse...@Doman...thixus...anretu! And the dead live again!@";
		cant_afford = "@That ain't enough money. Thou art " + remainder + " gold pieces short. Go see a gravedigger. I'll reckon his price'll be lower.@";
     	declined_help = "@Then go see a gravedigger. I'll reckon his price'll be lower.@";
		not_hurt = "@Eh? What foolishness is this? There ain't no dead person here!@";
	}	
	
	
	
	
	//Start of res script. 

	if (body_ground)
	{
		say(body_nearby); //I see a body, it will cost you X gold
		say(giveprice);
		if (askYesNo())
		{
			if (hasGold(price))
			{
				say(success);
				chargeGold(price);
				body = findBody(healer);
				body->resurrect();
				//UI_resurrect(valid_body_ground);
				
				//body = body_ground[0];
				//body->resurrect();
				
				//after rez, looks for another body you are carrying
				body_carrying = getBody(party); //finds bodies that are carried
				if (body_carrying)
					say("@I see that you carry another departed friend. Place them upon the ground so they can be resurrected.@");
			}
			else say(cant_afford);
		}
		else say(declined_help);
	}		
	else if (body_carrying) //
	{
		say("@I see that you carry a departed friend. Place them upon the ground so they can be resurrected.@");
	}
	else say(not_hurt);
	
	
 }