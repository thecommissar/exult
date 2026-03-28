/*
 *
 *  Copyright (C) 2006  Alun Bestor/The Exult Team
 *
 *  This program is free software; you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation; either version 2 of the License, or
 *  (at your option) any later version.
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with this program; if not, write to the Free Software
 *  Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.
 *
 *
 *	This header file defines generic helper functions added to the original.
 *
 *	Author: Alun Bestor (exult@washboardabs.net)
 *	Modified by Exult Team
 *	Last modified: 2006-03-19
 */

//Generic functions
//-----------------
extern var canTalk 0x937(var npc);
//extern var getAvatarName 0x0908();
extern var getNPCName 0x90F (var npc);
//extern var getNPCStat 0x910 (var npc, var stat);  //REMOVED FOR CONFLICT
extern void trainStrength 0x914 (var npc, var delta);
//extern void trainDexterity 0x915 (var npc, var delta); //REMOVED FOR CONFLICT
//extern void trainIntelligence 0x916 (var npc, var delta); //REMOVED FOR CONFLICT
extern void trainCombat 0x917 (var npc, var delta);
//extern void trainMagic 0x918 (var npc, var delta); //REMOVED FOR CONFLICT
extern var selectWhoTrains 0x920 ();
extern var checkCanTrain 0x922 (var statArray, var goldCost, var npc, var numTraining);
extern var getPoliteTitle 0x909();	//returns "milord" or "milady", depending on the gender of the Avatar



//returns a random entry from an array
var randomIndex(var array)
{
	var size = UI_get_array_size(array);
	var rand = UI_get_random(size);
	return array[rand];
}

var getSixth(var array)
{
	return array[6];

}





//checks to see if anyone in the party is poisoned 
var getPoisoned()
{
	var partymember;
	var party = partymember->get_party_list();
	var npc;
	var poisoned_party;
	var npcname;
	var npc_num;
	var party_member;
	var party_number;
	
	
	
	for (partymember in party with index)
	{
		
		UI_error_message("npc num is: " + npc_num);	
	//	UI_error_message("poisoned party is: " + npc);	
		if (UI_get_item_flag(npc, POISONED))
		{
			
			poisoned_party = npc->get_npc_object();
			return poisoned_party;
		}
		else
			return poisoned_party;
		UI_error_message("poisoned party is: " + npc);	
	}
	UI_error_message("Poisoned party member is: " + poisoned_party);
	
}





//NPC-related functions
//---------------------

//Returns true if the specified object is the avatar, false otherwise.
var isAvatar(var object)	{ return (object->get_npc_object() == UI_get_avatar_ref()); }

//Check if the player has met the specified person (i.e. whether their Met flag has been set).
//Can take either an NPC constant or an object reference.
var hasMet(var npc)		{ return npc->get_item_flag(MET); }

//Returns true if the specified NPC is in the party, false otherwise
//There should be an intrinsic for this, but it doesn't appear to be defined
//Can take an NPC constant or an object reference.
var inParty(var npc)		{ npc = npc->get_npc_object(); return (npc in UI_get_party_list()); }

//quick bark/say functions, useful for testing. See also randomPartySay() and randomPartyBark() (original functions)
var avatarBark(var line)	{ if (canTalk(AVATAR)) AVATAR->item_say(line); }
var avatarSay(var line)		{ if (canTalk(AVATAR)) AVATAR.say(line); }


//Moving-stuff-around functions
//-----------------------------



//Opposite of moveToContainer: tries to place the item at the specified location, or returns it to its previous location/container if that couldn't be done.
var moveToLocation(var object, var pos)
{
	var orig_pos;
	var orig_container;
	
	//record the previous container
	orig_container = object->get_container();
	//object was in the world - record its last position
	if (!orig_container) orig_pos = object->get_object_position();

	//could not remove the item (protected?)
	if (!object->set_last_created()) return false;

	//try to shift the item
	if (UI_update_last_created(pos)) return true;

	//if it couldn't be moved, just put it back in the original container/location along with a mouse warning
	else
	{
		if (orig_container) { orig_container->give_last_created(); }
		else { UI_update_last_created(orig_pos); }
		
		UI_flash_mouse(CURSOR_WONT_FIT);
		return false;
	}
}










//returns true if obj is contained by target, or false otherwise
var containedBy (var obj, var target)
{
	var container;

	container = obj->get_container();
	while (container)
	{
		if (container == target) return true;
		container = container->get_container();
	}
	return false;
}


//Animation functions
//-------------------






//Simple function to reverse a direction (NORTH becomes SOUTH, etc.)
var invertDirection (var direction)	{ return (direction + 4) % 8; }

//Gold-related functions (for streamlining shopping)
//--------------------------------------------------

//returns the total amount of gold the party has
var countGold (var amount)	{ return PARTY->count_objects(SHAPE_GOLD_COIN, QUALITY_ANY, FRAME_ANY); }

//returns true if the party has <amount> gold, false otherwise
var hasGold (var amount)
{
	var num_gold = PARTY->count_objects(SHAPE_GOLD_COIN, QUALITY_ANY, FRAME_ANY);
	return (num_gold >= amount);
}

//tries to deduct <amount> from the party's gold: returns true if they had the cash, or false if they can't afford it
var chargeGold (var amount)
{
	if (hasGold(amount)) return UI_remove_party_items(amount, SHAPE_GOLD_COIN, QUALITY_ANY, FRAME_ANY, true);
	else return false;
}

//give <amount> gold to the party: returns true if successful, false otherwise
var giveGold (var amount)	{ return UI_add_party_items(amount, SHAPE_GOLD_COIN, QUALITY_ANY, FRAME_ANY, true); }



//Script-related functions (used in script{} blocks)
//--------------------------------------------------
//Note that these functions cannot be passed any arguments, which is why they perform a specific action upon <item>.

//use during script sequences, to prevent the actor from moving according to schedule or player input
//IMPORTANT: Use nohalt; in these script sequences, otherwise the actor may remain frozen forever if the script is interrupted!
void GenericFreeze object#() ()	{ set_item_flag(DONT_MOVE); }
void GenericUnfreeze object#() ()	{ clear_item_flag(DONT_MOVE); }





var daypart(var part_of_day)
{
	
	var hour = UI_game_hour();
	
	if ((hour >= 6) && (hour < 12)) //'good morning'
	{
		return "morning";
		//return time_of_day;
	} 
	else if ((hour >= 12) && (hour < 18)) //'good afternoon'
	{
		part_of_day = "afternoon";
		return "afternoon";
	}
	else
		part_of_day = "evening";
	return part_of_day;
	
}




