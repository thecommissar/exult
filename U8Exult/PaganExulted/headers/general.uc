//Aliases for original functions
//------------------------------

//IMPORTANT NOTE: The original functions appear to have their arguments in the exact opposite order you would expect. This may be a quirk of the decompiler, or of the extern assignment.

extern checkIfItemStolen 0x8FA(var object);		//Checks whether the item used belonged to someone else.
												//This does not actually return a value - it executes the stolen-item behaviour (guards showing up, NPCs leaving etc.)
extern subtractItemQuantity 0x925(var object);	//Remove 1 item from the item's quantity stack (for Quantity items)

//npc says a line with a delay - use delayedBark instead, which has the arguments the right way round
extern oldDelayedBark 0x933(var delay, var line, var npc);

extern randomPartyBark 0x08FE(var line);	//Get a random nearby party member to say the line as a bark
extern randomPartySay 0x08FF(var line);		//Get a random nearby party member to say the line in conversation form

extern var npcCanTalk 0x937(var npc);		//Conjecture

//return a random party member who is nearby, or the avatar if none can be found
//(this is used by both of the above functions)
extern getRandomPartyMember 0x900();

extern var getAvatarName 0x0908();	//As it says, returns the name of the Avatar

//try to pathfind to the target object.
//offsetx, offsety and offsetz define a cubic perimeter of points around the object, and it will pathfind to the nearest point on that perimeter. offsetx and offsety are usually specified as arrays.
//if the player can get there, then they will walk there immediately. When they arrive in the region, func will be called with obj_context as the item and eventid as the event.
//if the player cannot get there, it displays the X cursor and no movement occurs.
//Note: This has been overridden by gotoObject, which just flips the order of the arguments to how they should be. Use that instead.
extern oldGotoObject 0x828(var eventid, var obj_context, var func, var rangez, var rangey, var rangex, var target);

//returns true if the object is carried by the avatar, false otherwise. Supports recursive containers.
extern var containedByAvatar 0x944(var obj);

//returns an itemref for the outermost container of an object. Used for when an object is contained several levels deep.
extern var getOuterContainer 0x945(var obj);

//returns the cardinal direction the object lies to, relative to the avatar
extern var directionFromAvatar 0x92D(var obj);

//Put specified object in the player's inventory 
extern giveToAvatar 0x692(var object);

extern giveExperience 0x911(var exp);		//gives the specified amount of experience points to every party member



//All-new functions
//-----------------

//returns a random entry from an array
var randomIndex 0xA00(var array)
{
	var size = UI_get_array_size(array);
	var rand = UI_get_random(size);
	return array[rand];
}

//returns true if the specified NPC is in the party, false otherwise
//There should be an intrinsic for this, but it doesn't appear to be defined
NPCInParty 0xA01(npc)	{ npc = UI_get_npc_object(npc); return (npc in UI_get_party_list()); }

avatarBark 0xA03(var line)
{ 
	var avatar = UI_get_avatar_ref();
	if (npcCanTalk(avatar)) UI_item_say(avatar, line);
}

avatarSay 0xA04(var line)
{
	var avatar = UI_get_avatar_ref();
	if (npcCanTalk(avatar)) avatar->say(line);
}

//Shift an object into a container (can be from another container or the world)
moveToContainer 0xA05(var object, var container, var dont_check_ownership)
{
	var orig_pos;
	var orig_container;
	
	//record the previous container
	orig_container = UI_get_container(object);
	//object was in the world - record its last position
	if (!orig_container) orig_pos = UI_get_object_position(object);

	//could not remove the item (protected?)
	if (!UI_set_last_created(object)) return false;

	//try to put the item into the new container
	if (UI_give_last_created(container))
	{
		//check if the item was stolen, unless overridden
		if (!dont_check_ownership) checkIfItemStolen(object);
		return true;
	}
	//if it couldn't be put into the new container, just put it back in the original container along with a mouse warning
	else
	{
		if (orig_container) { UI_give_last_created(orig_container); }
		else { UI_update_last_created(orig_pos); }
		
		//UI_flash_mouse(4);
		return false;
	}
}

//Opposite of moveToContainer: tries to place the item at the specified location, or returns it to its previous location/container if that couldn't be done
moveToLocation 0xA12(var object, var pos)
{
	var orig_pos;
	var orig_container;
	
	//record the previous container
	orig_container = UI_get_container(object);
	//object was in the world - record its last position
	if (!orig_container) orig_pos = UI_get_object_position(object);

	//could not remove the item (protected?)
	if (!UI_set_last_created(object)) return false;

	//try to shift the item
	if (UI_update_last_created(pos)) return true;

	//if it couldn't be moved, just put it back in the original container/location along with a mouse warning
	else
	{
		if (orig_container) { UI_give_last_created(orig_container); }
		else { UI_update_last_created(orig_pos); }
		
		//UI_flash_mouse(4);
		return false;
	}
}

//rewritten version of oldGotoObject() so that the calls are in their original orders
//todo: work out why this is happening in the first place
gotoObject 0xA06(var target, var rangex, var rangey, var rangez, var func, var obj_context, var eventid)
{
	oldGotoObject(eventid, obj_context, func, rangez, rangey, rangex, target);
}

//go to the target item, then call the specified pickup function when you get there (the pickup function should call pickUpItem, along with the actual target function you want)
//this is pretty much identical to gotoObject, only with fixed offsets. It is commonly used for item interactions.
gotoAndGet 0xA07(var target, var func, var obj_context, var eventid)
{
	var offsetx;
	var offsety;

	UI_close_gumps();

	//item is contained by someone/thing - march the avatar over to the container and pick it up
	//I have no idea what these positional offsets will look like - they're from the original game
	if (UI_get_container(target))
	{
		target = getOuterContainer(target);
		//avatar is the container - well I'll be. Call the pickup function directly.
		if (target == UI_get_avatar_ref())
		{
			UI_execute_usecode_array(obj_context, [0x27, eventid, 0x55, func]);
			return;
		}
		else
		{
			offsetx = [0, 1, -1, 1];
			offsety = [2, 1, 2, 0];
		}
	}
	//item was lying on the ground
	else
	{
		offsetx = [0, 1, 1, 1, -1, -1, 0, -1];
		offsety = [1, 1, 0, -1, 1, 0, -1, -1];
	}

	//go to item and call result function
	gotoObject(target, offsetx, offsety, -3, func, obj_context, eventid);
}

//generic get-item-from-container/world script, used by item interactions. It is used at the end of a march-to-container script, to play an appropriate animation and transfer the item into the player's inventory.
//once the item has been picked up, func is called with obj_context as the item and eventid as the event.

//Note: currently target is used in place of obj_context in most cases. This needs correcting.
pickUpItem 0xA08(var target, var func, var obj_context, var eventid)
{
	var container = getOuterContainer(target);
	var direction = directionFromAvatar(container);

	//the avatar is already carrying the item, call the target function and leave it at that
	if (container == UI_get_avatar_ref())
	{
		UI_execute_usecode_array(obj_context, [0x27, eventid, 0x55, func]);
		return;
	}

	//container is an NPC, animate the avatar frobbing the target
	else if (UI_is_npc(container)) UI_execute_usecode_array(UI_get_avatar_ref(), [0x59, direction, 0x64, 0x27, 3, 0x61]);

	//container is a regular object or just the world, animate the avatar leaning down
	else UI_execute_usecode_array(UI_get_avatar_ref(), [0x59, direction, 0x6C, 0x27, 3, 0x61]);

	//Hands the item to the avatar, and calls the intended function
	UI_execute_usecode_array(target, [0x27, 3, 0x55, 0x0692, 0x27, eventid, 0x55, func]);
}

//Get the appropriate rotated frame for an NPC animation, based on the direction they should face
getFrame 0xA09(var framenum, var direction)
{
	//use front-facing frame set
	if (direction >= EAST && direction <= SOUTHWEST) framenum = framenum + 16;

	return framenum;
}

//returns true if the specified object is the avatar, false otherwise
isAvatar 0xA0A(var object)	{ return (object == UI_get_avatar_ref()); }

//Check if the player has met the specified person (i.e. whether their Met flag has been set)
//This can accept either an object reference or an NPC number/constant
hasMet 0xA0B(var npc)	{ npc = UI_get_npc_object(npc); return UI_get_item_flag(npc, MET); }

//A reimplementation of oldDelayedBark, with arguments in the correct order
delayedBark 0xA0C(var npc, var line, var delay)	{ oldDelayedBark(delay, line, npc); }

//returns the direction (N/S/W/E) that the NPC is facing, based on their current frame
getFacing 0xA0D(var npc)
{
	var direction;
	var framenum;
	
	framenum = UI_get_item_frame_rot(npc);

	if		(framenum < 16) direction = NORTH;
	else if (framenum < 32) direction = SOUTH;
	else if (framenum < 48) direction = WEST;
	else if (framenum < 64) direction = EAST;

	return direction;
}


