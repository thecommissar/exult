/*	Copyright (C) 2006  Alun Bestor/The Exult Team
 *	Copyright (C) 2017  Scott Cooper
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
 */

/*	This header file defines general constants used throughout usecode, for
 *	Black Gate and Serpent Isle. Constants particular to a function can be
 *	found in the relevant codefile; constants particular to a game can be
 *	found in that game's header directory.
 *
 *	Author: Alun Bestor (exult@washboardabs.net)
 *	With modifications by Marzo Junior (marzojr@yahoo.com)
 *	Last modified: 2006-02-27
 *	2017-01-26 Knight Captain added ANY
 */

/*
 *	Event types, compiled with help from Marzo
 *	The global <event> variable is set with one of these values to describe
 *	how the current function was called: whether by the player clicking on the
 *	object, or by a scripted event, or by egg trigger conditions, or just the
 *	item being onscreen, etc.
 *	Functions check the value of <event> in order to provide different responses
 *	to different events.
 *	Functions can also set <event> to an arbitrary value, in order to mimic a
 *	real event or just as a 'pseudo-argument' to functions called with the
 *	likes of UI_path_run_usecode.
 */

/*
 *	parts of the day (3-hour intervals). Returned by UI_part_of_day. This is
 *	usually only used by conversation scripts, as a way of narrowing down
 *	schedule-related behaviour.
 */
 
 #include "headers/u8_npcs.uc"
 
 const int LOOP_ONCE = -1;
 
enum day_periods
{
	// The period is equal to one-third of the current game hour.
	MIDNIGHT		= 0,	// 0-2		12AM
	EARLY			= 1,	// 3-5		3AM
	DAWN			= 2,	// 6-8		6AM
	MORNING			= 3,	// 9-11		9AM
	NOON			= 4,	// 12-14	12PM
	AFTERNOON		= 5,	// 15-17	3PM
	EVENING			= 6,	// 18-20	6PM
	NIGHT			= 7		// 21-23	9PM
};


// tick multipliers, for use with UI_advance_time or script statements
enum times
{
	MINUTE	= 25,
	HOUR	= 1500
};
const long DAY		= 36000;
/*
 *	Examples:
 *	UI_advance_time(30 * MINUTE); // advance time by 30 game minutes
 *	UI_advance_time(2 * HOUR); // advance time by two game hours
 *	script after MINUTE ticks	{ ... } // schedule this script block to execute
 *	                       // after one game minute
 */


enum egg_states
{
	CACHED_IN = 0,			// Activated when chunk read in?
	PARTY_NEAR = 1,
	AVATAR_NEAR = 2,		// Avatar steps into area.
	AVATAR_FAR = 3,			// Avatar steps outside area.
	AVATAR_FOOTPAD = 4,		// Avatar must step on it.
	PARTY_FOOTPAD = 5,
	SOMETHING_ON = 6,		// Something placed on/near it.
	EXTERNAL_CRITERIA = 7	// Appears on Isle of Avatar.  Guessing
};


//Mask values used (e.g.) in find_nearby intrinsic; these are flags, which mean
//that they can be added together
enum item_masks
{
	MASK_NONE				= 0x0,
	MASK_NPC				= 0x04,
	MASK_NPC2				= 0x08,		//Maybe non-party NPCs only? All NPCs in Exult
	MASK_EGG				= 0x10,		//Also for barges
	MASK_INVISIBLE			= 0x20,
	MASK_PARTY_INVISIBLE	= 0x40,
	MASK_TRANSLUCENT		= 0x80,
	MASK_ALL_UNSEEN			= 0xB0		//MASK_EGG+MASK_INVISIBLE+MASK_TRANLUCENT
};



// Business activities (taken from the cheat screen)
enum schedules
{
	IN_COMBAT		= 0,	// renamed to not conflict with COMBAT, the NPC
							// stat property.
	PACE_HORIZONTAL	= 1,	// Walk horizontally until you hit a wall, then
							// turn around. (Patrolling on the cheap.)
	PACE_VERTICAL	= 2,	// Same as above, but vertically.
	TALK			= 3,	// NPC runs to the Avatar to talk to them. When
							// they get within a certain distance of where the
							// Avatar was when this schedule was set, a
							// STARTED_TALKING event is triggered on the NPC.
							// At this point the schedule must be changed.
	DANCE			= 4,
	EAT				= 5,
	FARM			= 6,	// Waves farm implements around.
	TEND_SHOP		= 7,	// This is really just a more specific version of
							// LOITER, used for narrowing down schedule barks.
							// See BAKE, SEW and BLACKSMITH for more specific
							// examples of shop behaviour.
	MINE			= 8,
	MINER			= 8,
	HOUND			= 9,
	STAND_THERE		= 10,	// Added 2017-02-23
	STANDTHERE		= 10,	// renamed to not conflict with STAND, the NPC
							// animation frame
	LOITER			= 11,	// Hangs around a certain point, within 10 units
							// or so
	WANDER			= 12,	// Roams nearby a certain point (as much as a
							// 320x200 screen away)
	BLACKSMITH		= 13,
	SLEEP			= 14,
	WAIT			= 15,	// Similar to STAND, except that they will never
							// leave the WAIT schedule until it is manually
							// changed: their preset schedule list is ignored.
	MAJOR_SIT		= 16,
	GRAZE			= 17,
	BAKE			= 18,
	SEW				= 19,
	SHY				= 20,	// Tries to keep out of the Avatar's way - will
							// half-heartedly flee until out of a certain range.
	LAB				= 21,
	THIEF			= 22,	// Approaches the party and will take gold from the Avatar's
							// backpack, then will bark "Greetings!" in SI.
	WAITER			= 23,
	SPECIAL			= 24,	// ??
	KID_GAMES		= 25,	// Tag! Thou art it! And so forth.
	TAG				= 25,
	EAT_AT_INN		= 26,	// same as Eat, only with different barks.
	DUEL			= 27,
	SPAR			= 27,
	PREACH			= 28,	// Broken in SI, Leon resets to Loiter after trying it.
							// He looks for a vertical podium shape, but there isn't one.
	PATROL			= 29,	// This tells the AI to follow a particular set of
							// patrol waypoints, defined by path eggs.
	DESK_WORK		= 30,
	FOLLOW_AVATAR	= 31,	// That most noble of pursuits. Like WAIT, this
							// completely overrides the NPC's schedule list.
							
	// These are not normally scheduled, but are used by the game engine.
	MOVE2SCHEDULE	= 32
};



// NPC attack behaviours. Retrieve and set using UI_set_attack_mode(npc, mode)
// and UI_get_attack_mode(npc).
enum npc_attack_modes
{
	NEAREST		= 0,
	WEAKEST		= 1,
	STRONGEST	= 2,
	BERSERK		= 3,
	PROTECT		= 4,
	DEFEND		= 5,
	FLANK		= 6,
	FLEE		= 7,
	RANDOM		= 8,
	MANUAL		= 9
};



/*	Coordinate axes - use when referencing X,Y,Z coordinate arrays.
 *	Note that the coordinates returned by UI_click_on_item are 1 array-index
 *	higher, because index 1 of the returned array is the actual item clicked on.
 *	You can resolve this to a regular X,Y,Z coordinates array by using
 *	array = removeFromArray(array, array[1]); (see also bg_externals.uc)
 */

enum axes
{
	X = 1,	// Horizontal, numbered from west to east (left to right).
	Y = 2,	// Vertical, numbered from north to south (top to bottom).
	Z = 3	// Lift, numbered from ground to sky. (low to high).
};


/*
 *	Failure cursor constants for use with UI_flash_mouse. Note that these do not
 *	correspond to frame numbers in pointers.uc, but to some internal mapping.
 *	(the "BLOCKED" cursor seems to be unavailable through this method.)
 */
enum cursors
{
	CURSOR_X			= 1,	//Default "no you can't do that" X cursor
	CURSOR_OUT_OF_RANGE = 2,
	CURSOR_OUT_OF_AMMO	= 3,
	CURSOR_TOO_HEAVY	= 4,
	CURSOR_WONT_FIT		= 5
};

// I wonder if Blocked is missing because of the Usecode in SI?



enum damage_types
{
	NORMAL_DAMAGE		= 0,
	FIRE_DAMAGE			= 1,
	MAGIC_DAMAGE		= 2,
	LIGHTNING_DAMAGE	= 3,
	ETHEREAL_DAMAGE		= 4,
	SONIC_DAMAGE		= 5
};



/*
 *	Cardinal directions: returned by UI_get_direction. Use with face or step
 *	statements in script{} blocks. e.g:
 *	script item { step NORTH; step NORTH; face SOUTH; }
 *	takes two steps north, then turn to face south
 */
enum directions
{
	NORTH		= 0,
	NORTHEAST	= 1,
	EAST		= 2,
	SOUTHEAST	= 3,
	SOUTH		= 4,
	SOUTHWEST	= 5,
	WEST		= 6,
	NORTHWEST	= 7
};


enum events
{
	// When an NPC is on-screen or nearby this is called repeatedly,
	// with a random delay between each call. Typically used for barks.
	PROXIMITY		= 0,

	// When an object (item or NPC) is double-clicked.
	// NPCs in combat, sleeping, or otherwise unable to speak will ignore this.
	DOUBLECLICK		= 1,
	
	// When a function is called from inside a script{} block, very common.
	SCRIPTED		= 2,

	// When an egg is hatched (triggered by activation conditions) this event
	// occurs, such as spawning guards, monsters, or barks, etc.
	EGG				= 3,

	// When an item is wielded and 'swing' in combat. This is mainly used with
	// 'weapon-like' objects like smokebombs, fishing rods, and other items
	// that have more advanced 'attack' behavior.
	WEAPON			= 4,

	// When an item is worn or readied in a party member's inventory.
	// Used by items like the Ring of Invisibilty and Helm of Light.
	READIED			= 5,
	
	// When an item is taken off or put away.
	UNREADIED		= 6,
	
	// SI-only. When an NPC with the TOURNAMENT flag set is killed.
	DEATH			= 7,
	
	// When an object is transformed, but Exult does not fully implement this.
	// It was unknown for some time. This is why some NPCs do not return
	// to their original shapes on death. Brunt, Deadeye, etc.
	POLYMORPHED		= 8,
	
	// SI-only. When an NPC conversation starts, showing the NPC's portrait.
	// This happens when the NPC's schedule is set to TALK by double-clicking
	// on them or if they are already scheduled for TALK.
	// Some characters behind walls, like Flicken, may not use this.
	STARTED_TALKING	= 9,

	// When called by SI script{} blocks that allow listing a specific event
	// to be run. This allows for multiple scripted events for each NPC,
	// though few use all three possibilities.
	SCRIPTED_A 		= 10,
	
	// Same as above, but less frequent.
	SCRIPTED_B		= 11,

	// Event 12 does not appear in SI.
							
	//The following events are arbitrary programmer conventions:
	// Used by calls to UI_path_run_usecode, to indicate
	// a successful pathfind to the target object.
	PATH_SUCCESS	= 13,

	// Used by calls to UI_set_path_failure, to indicate an interrupted 
	// pathfind, such as when the Avatar moves away manually.
	PATH_FAILURE	= 14
};





/*
 *	NPC animation frames. Use these with UI_set_item_frame or (preferably) in
 *	script blocks, with 'actor frame'.
 *	e.g.: script AVATAR { actor frame STAND; actor frame USE; actor frame
 *	SWING_1; actor_frame STAND; }
 *	Important note: use 'actor frame' with NPCs instead of 'frame', as 'actor
 *	frame' takes the NPC's current facing into account.
 */
enum npc_frames
{
	STAND		= 0,
	WALK_1		= 1,
	WALK_2		= 2,

	USE			= 3,	//general use motion

	SWING_1		= 4,	//start of one-handed swing, arm up over shoulder
	SWING_2		= 5,	//middle of one-handed swing, arm out to the side
	SWING_3 	= 6,	//end of one-handed swing, arm out to the front

	SWING_2H_1 	= 7,	//start of 2-handed swing, arms up over shoulder
	SWING_2H_2 	= 8,	//middle of 2-handed swing, arms out to the side
	SWING_2H_3	= 9,	//end of 2-handed swing, arms out to the front

	SIT			= 10,	//sitting down
	LEAN		= 11,	//leaning down
	KNEEL		= 12,	//kneeling on one knee
	LIE			= 13,	//lying down
	CAST_1		= 14,	//both arms high in the air (casting motion)
	CAST_2		= 15	//both arms stretched out (casting motion)
};

// North/South/East/West frame offsets for the NPC frames. Only really necessary
// if you're using UI_set_item_frame or 'frame'
enum frame_offsets
{
	NORTH_FRAMESET	= 0,
	SOUTH_FRAMESET	= 16,
	WEST_FRAMESET	= 32,
	EAST_FRAMESET	= 48
};



//NPC animation frames, WITH rotation bit. Use these with UI_set_item_frame_rot
//or (preferably) in script blocks, with 'frame'.
//e.g.: script AVATAR { frame STAND_WEST; frame USE_NORTH; frame SWING_1_SOUTH; frame STAND_EAST; }
enum npc_rot_frames
{
	STAND_NORTH			= 0,
	WALK_1_NORTH		= 1,
	WALK_2_NORTH		= 2,
	USE_NORTH			= 3,
	SWING_1_NORTH		= 4,
	SWING_2_NORTH		= 5,
	SWING_3_NORTH		= 6,
	SWING_2H_1_NORTH	= 7,
	SWING_2H_2_NORTH	= 8,
	SWING_2H_3_NORTH	= 9,
	SIT_NORTH			= 10,
	LEAN_NORTH			= 11,
	KNEEL_NORTH			= 12,
	LIE_NORTH			= 13,
	CAST_1_NORTH		= 14,
	CAST_2_NORTH		= 15,
	STAND_SOUTH			= 16,
	WALK_1_SOUTH		= 17,
	WALK_2_SOUTH		= 18,
	USE_SOUTH			= 19,
	SWING_1_SOUTH		= 20,
	SWING_2_SOUTH		= 21,
	SWING_3_SOUTH		= 22,
	SWING_2H_1_SOUTH	= 23,
	SWING_2H_2_SOUTH	= 24,
	SWING_2H_3_SOUTH	= 25,
	SIT_SOUTH			= 26,
	LEAN_SOUTH			= 27,
	KNEEL_SOUTH			= 28,
	LIE_SOUTH			= 29,
	CAST_1_SOUTH		= 30,
	CAST_2_SOUTH		= 31,
	STAND_WEST			= 32,
	WALK_1_WEST			= 33,
	WALK_2_WEST			= 34,
	USE_WEST			= 35,
	SWING_1_WEST		= 36,
	SWING_2_WEST		= 37,
	SWING_3_WEST		= 38,
	SWING_2H_1_WEST		= 39,
	SWING_2H_2_WEST		= 40,
	SWING_2H_3_WEST		= 41,
	SIT_WEST			= 42,
	LEAN_WEST			= 43,
	KNEEL_WEST			= 44,
	LIE_WEST			= 45,
	CAST_1_WEST			= 46,
	CAST_2_WEST			= 47,
	STAND_EAST			= 48,
	WALK_1_EAST			= 49,
	WALK_2_EAST			= 50,
	USE_EAST			= 51,
	SWING_1_EAST		= 52,
	SWING_2_EAST		= 53,
	SWING_3_EAST		= 54,
	SWING_2H_1_EAST		= 55,
	SWING_2H_2_EAST		= 56,
	SWING_2H_3_EAST		= 57,
	SIT_EAST			= 58,
	LEAN_EAST			= 59,
	KNEEL_EAST			= 60,
	LIE_EAST			= 61,
	CAST_1_EAST			= 62,
	CAST_2_EAST			= 63
};


/*
 *	Item/NPC flags, stolen from the Exult LB-joins-party patch with some 
 *	comments added.
 *	These can be retrieved and set using UI_get_item_flag(itemref, flag),
 *	UI_set_item_flag(itemref, flag) and UI_clear_item_flag(itemref, flag).
*/
enum item_flags
{
	INVISIBLE			= 0,
	ASLEEP				= 1,
	CHARMED				= 2,
	CURSED				= 3,
	DEAD				= 4,
	
	IN_PARTY			= 6,
	PARALYZED			= 7,
	PARALYSED			= 7,		//British spelling
	POISONED			= 8,
	PROTECTION			= 9,
	ON_MOVING_BARGE		= 10,
	OKAY_TO_TAKE		= 11,		// The item does not belong to anyone, and won't
									// trigger stealing behaviour if you take it.
	MIGHT				= 12,		// Double strength, dext, intel.
	IMMUNITIES			= 13,		// Lots of imunities; can be gotten only.
	CANT_DIE			= 14,		// Test flag in monster_info.
	DANCING				= 15,		// Set by "Dance" spell in BG.
	DONT_MOVE			= 16,		// SI-only. NPC can't move; "cutscene" mode.
	// DONT_RENDER		= 16,		// BG-only. Like DONT_MOVE, but avatar also
									// completely invisible.
	TEMPORARY			= 18,		// Is temporary - this means that the item will
									// be deleted once the party gets beyond a certain
									// range from it (outside the superchunk?)

	SAILOR				= 20,		// The barge's 'captain'. When getting the flag,
									// you will actually get the current captain.
	OKAY_TO_LAND		= 21,		// Used for flying-carpet.
	// BG_DONT_MOVE		= 22,		// BG-only. NPC can't move; "cutscene" mode.
	DONT_RENDER			= 22,		// SI-only. Like DONT_MOVE, but avatar also
									// completely invisible.
	IN_DUNGEON			= 23,		// If set, you won't be accused of stealing.
	CONFUSED			= 25,
	IN_MOTION			= 26,		// Object is a barge object moving, or on a barge
									// object that is moving. Set in usecode, and mostly
									// used for the SI 'NPC' ships such as the turtle.

	MET					= 28,		// Has the npc been met before - originally this
									// was SI-only, but Exult implements it for BG
									// too. This determines conversation behaviour,
									// and whether the NPC's real name or shape name
									// is displayed when they are single-clicked on.
									// BG originally used global flags for this, which
									// amounts to an extra 250-odd flags.
	SI_TOURNAMENT		= 29,		// Call usecode (eventid = 7) on death
	SI_ZOMBIE			= 30,		// Used for sick Neyobi, Cantra, post-Bane companions.

	NO_SPELL_CASTING	= 31,
	POLYMORPH			= 32,		// Do not set this flag directly; use the
									// UI_set_polymorph intrinsic instead.
	TATTOOED			= 33,
	READ				= 34,		// Can read non-Latin alphabet scrolls, books, signs.
	IS_PETRA			= 35,
	LIZARD_KING			= 36,		// Set by using large magic mushrooms after Batlin dies.
	FREEZE				= 37,
	NAKED				= 38, 		// Exult. Makes the avatar naked given its skin.// Other NPCs should use set_polymorph instead.
	SHOP_IS_OPEN		= 40		//added by DB 						
};


/*
 *	NPC properties (mostly ability scores)
 *	These can be retrieved and set using UI_get_npc_property(npc, property) and
 *	UI_set_npc_property(npc, property, value) respectively.
 *	Note however that UI_set_npc_property will actually *add* the value to the
 *	original property, not set it to that value. Which means you will need to
 *	calculate a relative positive/negative adjustment to set it to a target
 *	value.
 */
enum npc_properties
{
	STRENGTH		= 0,
	DEXTERITY		= 1,
	INTELLIGENCE	= 2,
	HEALTH			= 3,
	COMBAT			= 4,
	MANA			= 5,
	MAX_MANA		= 6,
	TRAINING		= 7,
	EXPERIENCE		= 8,
	FOOD_LEVEL		= 9,
	SEX_FLAG		= 10,	// 1 (nonzero) if female, 0 if male.
	MISSILE_WEAPON	= 11	// Cannot be set; returns 1 if wearing a missile
							// or (good) thrown weapon, 0 otherwise.
};



enum weather_types
{
	CLEAR_WEATHER	= 0,
	SNOWING			= 1,	//Unsure; in Exult, works the same as RAIN, below and seems identical to RAIN in the originals
	RAIN			= 2,
	SPARKLE			= 3,	//Prevents casting of spells in BG (and maybe SI too?)
	FOG				= 4,	//Seems to work like RAIN in the originals
	OVERCAST		= 5,	//Seems to clear weather in the originals
	CLOUDY			= 6
};


/*
 *	Wildcards, used for specifying "any acceptable value for this parameter"
 *	to a measuring function. These are commonly used with object-related
 *	intrinsics like UI_get_cont_items, UI_count_objects, UI_remove_party_items.
 */
enum wildcards
{
	ANY				= -359,
	SHAPE_ANY		= -359,
	QUALITY_ANY		= -359,
	QUANTITY_ANY	= -359,
	FRAME_ANY		= -359
};



