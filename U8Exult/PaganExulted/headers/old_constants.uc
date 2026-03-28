/*
 *
 *  Copyright (C) 2006-2009  Alun Bestor/The Exult Team/Team TFL
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
 */

// Title: Constants
// This header file defines general constants used throughout usecode, for
// Black Gate and Serpent Isle. Constants particular to a function can be
// found in the relevant codefile; constants particular to a game can be
// found in that game's header directory.
//
// *Author:* Alun Bestor (exult at washboardabs dot net)
// with modifications by Marzo Junior (marzojr at yahoo dot com)
// and NaturalDocs implementation by Peter M Dodge (twicescorned at gmail dot com)
// 
// *Last modified:* 2009-01-31


// Enum: events
// Event types, compiled with help from Marzo
//
// The global *event* variable is set with one of these values to describe
// how the current function was called: whether by the player clicking on
// the object, or by a scripted event, or by egg trigger conditions, or
// just the item being onscreen, etc.
//
// Functions check the value of *event* in order to provide different responses
// to different events.
//
// Functions can also set *event* to an arbitrary value, in order to mimic a real
// event or just as a 'pseudo-argument' to functions called with the likes of UI_path_run_usecode.
//
// PROXIMITY       = 0 - Object is on-screen or nearby.  This is called repeatedly, with a random
// delay between each call
// DOUBLECLICK     = 1 - Object is double-clicked on.
// SCRIPTED        = 2 - Function is called from inside a sript{} block (very common).
// EGG             = 3 - Object is an egg that just hatched (triggered by egg activation conditions).
// WEAPON          = 4 - Object was wielded and 'swung' in combat.  This is mainly used with
// 'weapon-like' objects, e.g. smokebombs and fishing rods, that have more advanced 'attack' behaviour.
// READIED         = 5 - Object was worn or readied in inventory - used by items like the Ring of Invisibility.
// UNREADIED       = 6 - Object was taken off or put away in inventory.
// DEATH           = 7 - NPC has just been killed (SI-only).
// STARTED_TALKING = 9 - NPC starts conversation with you (has TALK schedule and has reached the Avatar).
// This is SI-only, BG uses event 1 for this, both for conversations triggered by doubleclick
// and by the TALK schedule.
//
// The following events are set manually in usecode, which means they're arbitrary programmer
// conventions rather than recognised game states.
//
// PATH_SUCCESS    = 10 - Set with calls to UI_path_run_usecode, to indicate a successful pathfind
// to the target object.
// PATH_FAILURE    = 11 - Set with calls to UI_set_path_failure, to indicate an interrupted pathfind
// (e.g. when the player moves the Avatar manually)
//
// In particular, I switched to SI values for these events because si_tournament flag
// also works in BG now.
enum events
{
   PROXIMITY         = 0,
   DOUBLECLICK       = 1,
   SCRIPTED          = 2,
   EGG               = 3,
   WEAPON            = 4,
   READIED           = 5,
   UNREADIED         = 6,
   DEATH             = 7,
   STARTED_TALKING   = 9,
   PATH_SUCCESS      = 10,
   PATH_FAILURE      = 11
};


// Enum: axes
// Coordinate axes, use when referencing X,Y,Z coordinate arrays, e.g. from UI_get_object_position
//
// Note that the coordinates returned by UI_click_on_item are 1 array-index higher, because
// index 1 of the returned array is the actual item clicked on. You can resolve this to a
// regular X,Y,Z coordinates array by using array = removeFromArray(array, array[1]).
//
// X = 1 - horizontal axis (numbered from west to east).
// Y = 2 - vertical axis (numbered from north to south).
// Z = 3 - lift axis (numbered from ground to sky).
//
// See Also:
// <Externals>
enum axes
{
   X = 1,
   Y = 2,
   Z = 3
};


// Enum: directions
// Cardinal directions: returned by UI_get_direction. Use with face or step statements in script{} blocks.
//
// NORTH     = 0 - Compass north.
// NORTHEAST = 1 - Compass northeast.
// EAST      = 2 - Compass east.
// SOUTHEAST = 3 - Compass southeast.
// SOUTH     = 4 - Compass south.
// SOUTHWEST = 5 - Compass southwest.
// WEST      = 6 - Compass west.
// NORTHWEST = 7 - Compass northwest.
//
// Example:
// > script item { step NORTH; step NORTH; face SOUTH; } //take two steps north, then turn to face south
enum directions
{
   NORTH    = 0,
   NORTHEAST   = 1,
   EAST     = 2,
   SOUTHEAST   = 3,
   SOUTH    = 4,
   SOUTHWEST   = 5,
   WEST     = 6,
   NORTHWEST   = 7
};


// Enum: day_periods
// Parts of the day (3-hour intervals). Returned by UI_part_of_day. This is usually only
// used by conversation scripts, as a way of narrowing down schedule-related behaviour.
//
// MIDNIGHT  = 0 - 0-2
// EARLY     = 1 - 3-5 (dim palette)
// DAWN      = 2 - 6-8 (day palette)
// MORNING   = 3 - 9-11
// NOON      = 4 - 12-14
// AFTERNOON = 5 - 15-17
// EVENING   = 6 - 18-20 (dim palette)
// NIGHT     = 7 - 21-23 (night palette)
enum day_periods
{
   MIDNIGHT    = 0,
   EARLY       = 1,
   DAWN        = 2,
   MORNING     = 3,
   NOON        = 4,
   AFTERNOON   = 5,
   EVENING     = 6,
   NIGHT       = 7
};


// Enum: wildcards
// Wildcards, used for specifying "any acceptable value for this parameter" to a
// measuring function. These are commonly used with object-related intrinsics like
// <UI_get_cont_items>, <UI_count_objects>, <UI_remove_party_items>, etc.
//
// SHAPE_ANY   = -359 - Any valid object from SHAPES.VGA.
// QUALITY_ANY = -359 - Any valid quality parameter.
// FRAME_ANY   = -359 - Any valid fram for a given shape.
enum wildcards
{
   SHAPE_ANY   = -359,
   QUALITY_ANY = -359,
   FRAME_ANY   = -359,
   FIND_ON_SCREEN = -359
};


// Enum: times
// Tick multipliers, for use with UI_advance_time or script statements
//
// MINUTE = 25 - One game 'minute'.
// HOUR   = 1500 - One game 'hour'.
// DAY    = 36000 - One game 'day'.
//
// Examples:
// > UI_advance_time(30 * MINUTE);  //advance time by 30 game minutes
// > UI_advance_time(2 * HOUR);     //advance time by two game hours
// > script after MINUTE ticks   { ... }  //schedule this script block to execute after one game minute
enum times
{
   MINUTE   = 25,
   HOUR  = 1500
};
const long DAY    = 36000;


// Enum: item_flags
// Item/NPC flags, stolen from the Exult LB-joins-party patch with some comments added.
//
// These can be retrieved and set using UI_get_item_flag(itemref, flag),
// UI_set_item_flag(itemref, flag) and UI_clear_item_flag(itemref, flag).
//
// INVISIBLE          = 0  - Object is invisible (rendered with 'invisible' palette).
// See <Invisibility>, <MassInvisibility>.
// ASLEEP             = 1  - Object is asleep.  Only really useful for PC/NPC/monster.
// See <Sleep>.
// CHARMED            = 2  - Object is charmed (attacks allies).  Only really useful for PC/NPC/monster.
// See <Charm>, <MassCharm>.
// CURSED             = 3  - Object is cursed (stats malus).  Only really useful for PC/NPC/monster.  See <Curse>.
// DEAD               = 4  - Object is dead.  Only really useful for NPC/monster.
// *DONT set on dead bodies, causes bugs.*
// IN_PARTY           = 6  - Object is an NPC in the party.
// PARALYZED          = 7  - Object is paralysed and unable to move.  Normal objects will be stationary by default.
// See <Paralyze>.
// PARALYSED          = 7  - Canadian/British spelling.
// POISONED           = 8  - Object is afflicted with poison.
// Can be set on objects, but will only do anything to PC/NPC/monster.  See <Poison>.
// PROTECTION         = 9  - Object is protected from harm.  Only really useful for PC/NPC/monster.  See <Protection>.
// ON_MOVING_BARGE    = 10 - Object is on a 'barge' object that is moving.
// OKAY_TO_TAKE       = 11 - Object will not trigger stealing usecode if you take it.
// MIGHT              = 12 - Object has might.  (Stats boon)  Only really useful for PC/NPC/monster.
// See <Might>, <MassMight>.
// IMMUNITIES         = 13 - Object has several immunities.  Can be gotten only.
// CANT_DIE           = 14 - Object can't die.  Used for testing purposes, and certain critical NPCs (such as L.B.).
// DANCING            = 15 - Object is executing the usecode called by the <Dance> spell.
// DONT_MOVE          = 16 - SI: User cannot move.
// DONT_RENDER        = 16 - BG: Same as INVISIBLE, but don't render at all.
// SI_ON_MOVING_BARGE = 17 - SI: Object is on a special instance of the SI barges.  (Turtle for example.)
// TEMPORARY          = 18 - Object is temporary and will decay once the chunk it is in is un-cached.
// SAILOR             = 20 - Object is the 'captain' of a barge.  *Only set on PC/NPCs!*
// OKAY_TO_LAND       = 21 - Set in usecode for flying carpet, TRUE if you can land currently.
// BG_DONT_MOVE       = 22 - BG: BG's version of DONT_MOVE.
// IN_DUNGEON         = 23 - If set on PC or an NPC, they won't trigger the stealing usecode if they take food objects.
// CONFUSED           = 25 - Object is 'confused' - no apparent intrinsic affects.  Was supposed to be part of a spell
// axed for space limitations in spellbook.
// IN_MOTION          = 26 - Object is a barge object moving, or on a barge object that is moving.  Set in usecode, and
// mostly used for the SI 'NPC' ships such as the turtle.
// MET                = 28 - Object has been talked to previously.  Should be set in a conversation Usecode script.
// This determines conversation behaviour, and whether the NPC's real name or shape name is displayed when they are
// single-clicked on. BG originally used global flags for this, which amounts to an extra 250-odd flags. What a waste of 
// time.
//
// Flags 29, 30, and 38 were originally SI-only, but are implemented in BG by Exult.
//
// SI_TOURNAMENT      = 29 - Object call usecode (eventid = 7) on death.  Used for the List Field in SI.
// SI_ZOMBIE          = 30 - Object will not respond to normal cues.
// Used for sick Neyobi, insane party members/Cantra.
// NAKED              = 38 - Object is naked.  On PC, causes them to use appropriate 'naked' shape.  On NPCs or
// monsters, no effect unless you give it a meaning in Usecode scripting.  To actually make NPCs naked, use
// set_polymorph instead.
//
// Flags > 31 appear to be SI flags only, excepting 38 which Exult implements (above).
//
// NO_SPELL_CASTING   = 31 - Object cannot cast spells nor have spells cast upon them.  Used to protect certain NPCs.
// POLYMORPH          = 32 - Object is polymorphed.  Used in <SerpentBond> spell.
// TATTOOED           = 33 - Object has been tattooed.  Set after the lady tattoos you by usecode.  Causes the NPC
// portraits to use a different 'tattooed' shape num.
// READ               = 34 - Object can read serpent-script text.  Set by the <Translate> spell.  Only really
// meaningful used on the PC.
// PETRA              = 35 - Object has switched bodies with petra.  Only really meaningful used on the PC.
// FREEZE             = 36 - Object cannot move.  Used as part of the <Freeze> spell.
enum item_flags
{
   INVISIBLE         = 0,
   ASLEEP            = 1,
   CHARMED           = 2,
   CURSED            = 3,
   DEAD              = 4,
   IN_PARTY          = 6,
   PARALYZED         = 7,
   PARALYSED         = 7,
   POISONED          = 8,
   PROTECTION        = 9,
   ON_MOVING_BARGE   = 10,
   OKAY_TO_TAKE      = 11,
   MIGHT             = 12,
   IMMUNITIES        = 13,
   CANT_DIE          = 14,
   DANCING           = 15,
   //DONT_MOVE       = 16,
   DONT_RENDER       = 16,
   SI_ON_MOVING_BARGE= 17,
   TEMPORARY         = 18,
   SAILOR            = 20,
   OKAY_TO_LAND      = 21,
   BG_DONT_MOVE      = 22,
   IN_DUNGEON        = 23,
   CONFUSED          = 25,
   IN_MOTION         = 26,
   MET               = 28,
   SI_TOURNAMENT     = 29,
   SI_ZOMBIE         = 30,
   NO_SPELL_CASTING  = 31,
   POLYMORPH         = 32,
   TATTOOED          = 33,
   READ              = 34,
   PETRA             = 35,
   FREEZE            = 37,
   NAKED             = 38
};


// Enum: schedules
// Business activities (taken from the cheat screen).
//
// IN_COMBAT       = 0  - Creature will fight nearby creatures of opposite alignment.  Renamed to not conflict with
// COMBAT, the NPC stat property.
// PACE_HORIZONTAL = 1  - Walk horizontally until you hit a wall, then turn around. (Patrolling on the cheap.)
// PACE_VERTICAL   = 2  - Same as above, but vertically.
// TALK            = 3  - NPC runs to the Avatar to talk to them. When they get within a certain distance of where
// the Avatar was when this schedule was set, a doubleclick event is triggered on the NPC. At this point the
// schedule must be changed.
// DANCE           = 4  - NPC dances, basically moving about and looking kinda funny. :-)
// EAT             = 5  - Find the nearest table with a place set with plate.  Wait for food.  Eat.
// FARM            = 6  - Waves farm implements around.  Otherwise, same as *Loiter*.
// TEND_SHOP       = 7  - Same as *Loiter,* but used to narrow down schedule barks in the Usecode.
// MINE            = 8  - Wander around with pickaxe, hack at random dungeon walls.
// MINER           = 8  - Same as above.  Convinence name.
// HOUND           = 9  - Follow PC and party members very closely if they come close.
// STANDTHERE      = 10 - Just stand around, as name implies.  Renamed to not conflict with STAND, the
// NPC animation frame.
// LOITER          = 11 - Hangs around a certain point, within 10 units or so.
// WANDER          = 12 - Roams nearby a certain point (as much as a 320x200 screen away).
// BLACKSMITH      = 13 - Same as *Loiter*/*Tend_Shop*, except if there is a firepit, anvil, and trough around, the NPC
// will smith items.
// SLEEP           = 14 - Find a bed, sleep in it.  Pretty simple.
// WAIT            = 15 - Similar to *Stand*, except that they will never leave the WAIT schedule until it is
// manually changed: their preset schedule list is overridden.
// MAJOR_SIT       = 16 - Do absolutely nothing but find the nearest seat and sit in it.
// GRAZE           = 17 - Wander around in the plains, eat grass.  More for animals than NPCs. :-)
// BAKE            = 18 - Same as *Loiter*, unless the NPC has an oven and a table around, in which case they will
// produce baked goods.
// SEW             = 19 - Same as *Loiter*, unless the NPC has a seat with a weaving loom and a seat with a spinning
// wheel, in which case they will produce clothing.
// SHY             = 20 - Tries to keep out of the Avatar's way - will half-heartedly flee until out of a
// certain range.
// LAB             = 21 - Same as *Loiter*, unless there is a table and cauldron around, in which case they will
// produce potions.
// THEIF           = 22 - NPC follows the party, tries to steal items.  Only really works if the NPC usecode has a
// handler to take the items.
// WAITER          = 23 - NPC will go to other NPCs in the vicinity (same range as *Wander*), 'serving' food items to
// them if they have a plate in front of them.
// SPECIAL         = 24 - Used in some special usecode scripts, namely Frigidazzi in SI.  Basically stops a NPC from
// wandering around such as with *Wait* but without neccesarily wiping the schedule.
// KID_GAMES       = 25 - Tag! Thou art it! And so forth.
// TAG             = 25 - Convinence name, same as above.
enum schedules
{
   IN_COMBAT         = 0,
   PACE_HORIZONTAL   = 1,
   PACE_VERTICAL     = 2,
   TALK              = 3,
   DANCE             = 4,
   EAT               = 5,
   FARM              = 6,
   TEND_SHOP         = 7,
   MINE              = 8,
   MINER             = 8,
   HOUND             = 9,
   STANDTHERE        = 10,
   LOITER            = 11,
   WANDER            = 12,
   BLACKSMITH        = 13,
   SLEEP             = 14,
   WAIT              = 15,
   MAJOR_SIT         = 16,
   GRAZE             = 17,
   BAKE              = 18,
   SEW               = 19,
   SHY               = 20,
   LAB               = 21,
   THIEF             = 22,
   WAITER            = 23,
   SPECIAL           = 24,
   KID_GAMES         = 25,
   TAG               = 25,
   EAT_AT_INN        = 26, //same as Eat, only with different barks.
   DUEL              = 27,
   SPAR              = 27,
   PREACH            = 28,
   PATROL            = 29, //This tells the AI to follow a particular set of patrol waypoints
   DESK_WORK         = 30,
   FOLLOW_AVATAR     = 31  //That most noble of pursuits. Like WAIT, this completely overrides the NPC's schedule list.
};

// Enum: npc_frames
// NPC animation frames. Use these with UI_set_item_frame or (preferably) in script blocks,
// with 'actor frame'.
//
// *Important note:* use 'actor frame' with NPCs instead of 'frame', as 'actor frame' takes
// the NPC's current facing into account.
//
// Examples:
// > script AVATAR { actor frame STAND; actor frame USE; actor frame SWING_1; actor_frame STAND; }
//
// STAND       = 0 - standing at rest
// WALK_1      = 1 - stepping forward
// WALK_2      = 2 - stepping forward
//
// USE         = 3 - general use motion
//
// SWING_1     = 4 - start of one-handed swing, arm up over shoulder
// SWING_2     = 5 - middle of one-handed swing, arm out to the side
// SWING_3     = 6 - end of one-handed swing, arm out to the front
//
// SWING_2H_1  = 7 - start of 2-handed swing, arms up over shoulder
// SWING_2H_2  = 8 - middle of 2-handed swing, arms out to the side
// SWING_2H_3  = 9 - end of 2-handed swing, arms out to the front
//
// SIT    = 10 - sitting down
// LEAN   = 11 - leaning down
// KNEEL  = 12 - kneeling on one knee
// LIE    = 13 - lying down
// CAST_1 = 14 - both arms high in the air (casting motion)
// CAST_2 = 15 - both arms stretched out (casting motion)
enum npc_frames
{
   STAND       = 0,
   WALK_1      = 1,
   WALK_2      = 2,

   USE         = 3,

   SWING_1     = 4,
   SWING_2     = 5,
   SWING_3     = 6,

   SWING_2H_1  = 7,
   SWING_2H_2  = 8,
   SWING_2H_3  = 9,

   SIT         = 10,
   LEAN        = 11,
   KNEEL       = 12,
   LIE         = 13,
   CAST_1      = 14,
   CAST_2      = 15
};

// Enum: frame_offsets
// North/South/East/West frame offsets for the NPC frames. Only really necessary if you're
// using <UI_set_item_frame> or 'frame'
//
// NORTH_FRAMESET = 0  - Frames in Shapes.vga start facing north
// SOUTH_FRAMESET = 16 - After 16 frames they face south.
// WEST_FRAMESET  = 32 - After 32 frames they face west.
// EAST_FRAMESET  = 48 - After 48 frames they face east.
enum frame_offsets
{
   NORTH_FRAMESET = 0,
   SOUTH_FRAMESET = 16,
   WEST_FRAMESET  = 32,
   EAST_FRAMESET  = 48
};

// Enum: is_readied_inv_slots
// Ready slots: use with <UI_is_readied>. These are the same whether paperdolls are on or off.
//
//
// IR_RIGHT_HAND     = 1 - Item wielded in right hand
// IR_WEAPON_HAND    = 1 - Right hand is also called the weapon hand
// IR_BOTH_HANDS     = 1 - Item wielded with both hands
//
// IR_LEFT_HAND      = 2 - Item wielded in left hand
// IR_SHIELD_HAND    = 2 - Left hand is also called the shield hand
// IR_OFF_HAND       = 2 - Left hand is also called the off hand
//
// IR_NECK           = 3 - Item worn around the neck
// IR_CLOAK          = 3 - Cloaks happen to be worn around the neck
//
// IR_RIGHT_FINGER   = 6 - Item worn on right finger (ring)
// IR_LEFT_FINGER    = 7 - Item worn on left finger (ring)
// IR_GLOVES         = 6 - Gloves technically take up the right finger spot.
//
// IR_HEAD           = 9  - Items worn on the head such as headbands, helms, etc
// IR_BELT           = 11 - Items worn around the waist such as belts, girdles
enum is_readied_inv_slots
{
   IR_RIGHT_HAND     = 1,
   IR_WEAPON_HAND    = 1,
   IR_BOTH_HANDS     = 1,  //For two-handed items

   IR_LEFT_HAND      = 2,
   IR_SHIELD_HAND    = 2,
   IR_OFF_HAND       = 2,

   IR_NECK           = 3,
   IR_CLOAK       = 3,

   IR_RIGHT_FINGER      = 6,
   IR_LEFT_FINGER    = 7,
   IR_GLOVES         = 6,

   IR_HEAD           = 9,
   
   IR_QUIVER		 = 10, 
   IR_BELT           = 11, // - Worn across the waist, such as belts and girdles
   IR_TORSO          = 5, // - Worn on the torso, such as armour
   IR_FEET           = 13, // - Worn on feet, such as boots
   IR_LEGS           = 14, // - Worn on legs, such as greaves
   IR_BACKPACK       = 15, // - Containers worn on the back, such as backpacks
   IR_BACK_SHIELD    = 16, // - *SI only.* Shield slung across the back
   IR_BACK_SPOT      = 17 // - *SI only.* Weapon slung across the back
   
};

// Enum: get_readied_inv_slots
// Ready slots: use with <UI_get_readied>. These are the same whether paperdolls are on or off.
//
// LEFT_HAND         = 0 - Items wielded in the left hand.
// SHIELD_HAND       = 0 - Left hand is also called shield hand.
// OTHER_HAND        = 0 - Left hand is also called other hand.
//
// RIGHT_HAND        = 1 - Items wielded in the right hand.
// WEAPON_HAND       = 1 - Right hand is also called the weapon hand.
// BOTH_HANDS        = 1 - Items worn in both hands technically count as wielded in the right hand.
//
// CLOAK             = 2 - *SI only.* Items worn around the neck and back such as cloaks and capes.
// NECK              = 3 - Items worn on the neck such as a collar.
// HEAD              = 4 - Items worn on the head such as a helm.
//
// GLOVES            = 5 - Items worn on both hands, such as gloves.
// In BG, exclusive with ONE_FINGER and OTHER_FINGER
//
// USECODE_CONTAINER = 6 - *SI only.*  Usecode container, used for containing eggs 'carried' by player.
//
// ONE_FINGER        = 7 - Ring or item worn on right hand.  In BG, exclusive with GLOVES.
// OTHER_FINGER      = 8 - Ring or item worn on left hand.  In BG, exclusive with GLOVES
//
// EARRINGS          = 9  - *SI only.* Earrings, such as the serpent earrings
//
// QUIVER            = 10 - Arrows held in quiver
// BELT              = 11 - Worn across the waist, such as belts and girdles
// TORSO             = 12 - Worn on the torso, such as armour
// FEET              = 13 - Worn on feet, such as boots
// LEGS              = 14 - Worn on legs, such as greaves
// BACKPACK          = 15 - Containers worn on the back, such as backpacks
// BACK_SHIELD       = 16 - *SI only.* Shield slung across the back
// BACK_SPOT         = 17 - *SI only.* Weapon slung across the back
enum get_readied_inv_slots
{
   LEFT_HAND         = 0,
   SHIELD_HAND       = 0,
   OTHER_HAND        = 0,

   RIGHT_HAND        = 1,
   WEAPON_HAND       = 1,
   BOTH_HANDS        = 1,

   CLOAK             = 2,     //SI only
   NECK              = 3,
   HEAD              = 4,

   GLOVES            = 5,     //In BG, exclusive with ONE_FINGER and OTHER_FINGER

   USECODE_CONTAINER = 6,     //SI only

   ONE_FINGER        = 7,     //In BG, exclusive with GLOVES
   OTHER_FINGER      = 8,     //In BG, exclusive with GLOVES

   EARRINGS          = 9,     //SI only

   QUIVER            = 10,
   BELT              = 11,
   TORSO             = 12,
   FEET              = 13,
   LEGS              = 14,
   BACKPACK          = 15,
   BACK_SHIELD       = 16,    //SI only
   BACK_SPOT         = 17     //SI only
};

// Enum: npc_properties
// NPC properties (mostly ability scores).  These can be retrieved and set
// using <UI_get_npc_property>(npc, property) and <UI_set_npc_property>(npc, property, value)
// respectively. Note however that <UI_set_npc_property> will actually *add* the value to
// the original property, not set it to that value. Which means you will need to calculate
// a relative positive/negative adjustment to set it to a target value.
//
// STRENGTH       = 0 - How strong a character is.
// DEXTERITY      = 1 - The manual dexterity of the character.
// INTELLIGENCE   = 2 - How intelligent a character is.
// HEALTH         = 3 - How much punishment a character can take before they die.
// COMBAT         = 4 - The combat skill of a character.
// MANA           = 5 - The mental reserves of a spellcaster.
// MAX_MANA       = 6 - The maximum mana a spellcaster can have.
// TRAINING       = 7 - Training points are used to increase stats.
// EXPERIENCE     = 8 - Experience points accumulate to increase levels.
// FOODLEVEL      = 9 - How sustained a character is.
enum npc_properties
{
   STRENGTH       = 0,
   DEXTERITY      = 1,
   INTELLIGENCE   = 2,
   HEALTH         = 3,
   COMBAT         = 4,
   MANA           = 5,
   MAX_MANA       = 6,
   TRAINING       = 7,
   EXPERIENCE     = 8,
   FOODLEVEL      = 9
};

// Enum: npc_attack_modes
// NPC attack behaviours. Retrieve and set using <UI_set_attack_mode>(npc, mode)
// and <UI_get_attack_mode>(npc).
//
// NEAREST     = 0 - Attack the nearest hostile NPC.
// WEAKEST     = 1 - Attack the hostile NPC deemed the weakest.
// STRONGEST   = 2 - Attack the hostile NPC deemed the strongest.
// BERSERK     = 3 - Attack anything and everything!
// PROTECT     = 4 - Go to the protection of party members in Defend mode.
// DEFEND      = 5 - Defend a designated party member.  Only useful for members of the party.
// FLANK       = 6 - Try to get to the enemy's side.
// FLEE        = 7 - Flee from any enemy that tries to engage them.
// RANDOM      = 8 - Random of the above.
// MANUAL      = 9 - Player-controlled.  Only the Avatar can be manual controlled, though in
// the future I'd like to see it that it can just be any _one_ party member.
enum npc_attack_modes
{
   NEAREST     = 0,
   WEAKEST     = 1,
   STRONGEST   = 2,
   BERSERK     = 3,
   PROTECT     = 4,
   DEFEND      = 5,
   FLANK       = 6,
   FLEE        = 7,
   RANDOM      = 8,
   MANUAL      = 9
};

// Enum: cursors
// Failure cursor constants for use with <UI_flash_mouse>. Note that these do not
// correspond to frame numbers in pointers.uc, but to some internal mapping. (the 
// "BLOCKED" cursor seems to be unavailable through this method.)
//
// CURSOR_X            = 1 - Default "no you can't do that" X cursor
// CURSOR_OUT_OF_RANGE = 2 - Displays a message "out of range"
// CURSOR_OUT_OF_AMMO  = 3 - Displays a message "out of ammo", should only be for projectile weapons of course.
// CURSOR_TOO_HEAVY    = 4 - Displays a message "too heavy", when we cant move something.
// CURSOR_WONT_FIT     = 5 - Displays a message "won't fit", when we exceed container size.
enum cursors
{
   CURSOR_X             = 1,
   CURSOR_OUT_OF_RANGE  = 2,
   CURSOR_OUT_OF_AMMO   = 3,
   CURSOR_TOO_HEAVY     = 4,
   CURSOR_WONT_FIT      = 5
};

// Enum: alignments
// NPC atitudes toward the player.
//
// FRIENDLY       = 0 - Will aid the player in combat.
// NEUTRAL        = 1 - Won't aid, or hinder, the player in combat.
// HOSTILE        = 2 - Will hinder the player and attempt to attack them if possible.
// RANDOM_ALIGN   = 3 - Random of the above.
enum alignments
{
   FRIENDLY       = 0,
   NEUTRAL        = 1,
   HOSTILE        = 2,
   RANDOM_ALIGN   = 3
};

// Enum: weather_types
// Different engine weather types.
//
// CLEAR_WEATHER  = 0 - Clear skies, no clouds, nothing.
// SNOWING        = 1 - Unsure; in Exult, works the same as RAIN, below and seems identical to RAIN in the originals.
// RAIN           = 2 - Rain falling, overcast and dark skies.
// SPARKLE        = 3 - Prevents casting of spells in BG (and maybe SI too?)
// FOG            = 4 - Seems to work like RAIN in the originals.  More overcast.
// OVERCAST       = 5 - Seems to clear weather in the originals.
// CLOUDY         = 6 - Clouds appear but otherwise, clear.
enum weather_types
{
   CLEAR_WEATHER  = 0,
   SNOWING        = 1,  //Unsure; in Exult, works the same as RAIN, below and seems identical to RAIN in the originals
   RAIN           = 2,
   SPARKLE        = 3,  //Prevents casting of spells in BG (and maybe SI too?)
   FOG            = 4,  //Seems to work like RAIN in the originals
   OVERCAST       = 5,  //Seems to clear weather in the originals
   CLOUDY         = 6
};

// Enum: item_masks
// Mask values used (e.g.) in <find_nearby> intrinsic; these are flags, which mean
// that they can be added together.
//
// MASK_NONE            = 0x0   - No masks apply to this object.
// MASK_NPC             = 0x04  - Non-player characters.
// MASK_NPC2            = 0x08  - Maybe non-party NPCs only? All NPCs in Exult.
// MASK_EGG             = 0x10  - Item is a usecode egg. Also for barges
// MASK_INVISIBLE       = 0x20  - Render the object using the invisible pallete.
// MASK_PARTY_INVISIBLE = 0x40  - Invisible, but only to the party?  Unsure.
// MASK_TRANSLUCENT     = 0x80  - Do not render.
// MASK_ALL_UNSEEN      = 0xB0  - MASK_EGG + MASK_INVISIBLE + MASK_TRANLUCENT.
enum item_masks
{
   MASK_NONE            = 0x0,
   MASK_NPC             = 0x04,
   MASK_NPC2            = 0x08,
   MASK_EGG             = 0x10,
   MASK_INVISIBLE       = 0x20,
   MASK_PARTY_INVISIBLE = 0x40,
   MASK_TRANSLUCENT     = 0x80,
   MASK_ALL_UNSEEN      = 0xB0
};

// Enum: npc_rot_frames
// NPC animation frames, WITH rotation bit. Use these with UI_set_item_frame_rot
// or (preferably) in script blocks, with 'frame'.
//
// Examples:
// > script AVATAR { frame STAND_WEST; frame USE_NORTH; frame SWING_1_SOUTH; frame STAND_EAST; }
//
// STAND_NORTH       - 0x0000
// WALK_1_NORTH      - 0x0001
// WALK_2_NORTH      - 0x0002
// USE_NORTH         - 0x0003
// SWING_1_NORTH     - 0x0004
// SWING_2_NORTH     - 0x0005
// SWING_3_NORTH     - 0x0006
// SWING_2H_1_NORTH  - 0x0007
// SWING_2H_2_NORTH  - 0x0008
// SWING_2H_3_NORTH  - 0x0009
// SIT_NORTH         - 0x000A
// LEAN_NORTH        - 0x000B
// KNEEL_NORTH       - 0x000C
// LIE_NORTH         - 0x000D
// CAST_1_NORTH      - 0x000E
// CAST_2_NORTH      - 0x000F
// STAND_SOUTH       - 0x0010
// WALK_1_SOUTH      - 0x0011
// WALK_2_SOUTH      - 0x0012
// USE_SOUTH         - 0x0013
// SWING_1_SOUTH     - 0x0014
// SWING_2_SOUTH     - 0x0015
// SWING_3_SOUTH     - 0x0016
// SWING_2H_1_SOUTH  - 0x0017
// SWING_2H_2_SOUTH  - 0x0018
// SWING_2H_3_SOUTH  - 0x0019
// SIT_SOUTH         - 0x001A
// LEAN_SOUTH        - 0x001B
// KNEEL_SOUTH       - 0x001C
// LIE_SOUTH         - 0x001D
// CAST_1_SOUTH      - 0x001E
// CAST_2_SOUTH      - 0x001F
// STAND_WEST        - 0x0020
// WALK_1_WEST       - 0x0021
// WALK_2_WEST       - 0x0022
// USE_WEST          - 0x0023
// SWING_1_WEST      - 0x0024
// SWING_2_WEST      - 0x0025
// SWING_3_WEST      - 0x0026
// SWING_2H_1_WEST   - 0x0027
// SWING_2H_2_WEST   - 0x0028
// SWING_2H_3_WEST   - 0x0029
// SIT_WEST          - 0x002A
// LEAN_WEST         - 0x002B
// KNEEL_WEST        - 0x002C
// LIE_WEST          - 0x002D
// CAST_1_WEST       - 0x002E
// CAST_2_WEST       - 0x002F
// STAND_EAST        - 0x0030
// WALK_1_EAST       - 0x0031
// WALK_2_EAST       - 0x0032
// USE_EAST          - 0x0033
// SWING_1_EAST      - 0x0034
// SWING_2_EAST      - 0x0035
// SWING_3_EAST      - 0x0036
// SWING_2H_1_EAST   - 0x0037
// SWING_2H_2_EAST   - 0x0038
// SWING_2H_3_EAST   - 0x0039
// SIT_EAST          - 0x003A
// LEAN_EAST         - 0x003B
// KNEEL_EAST        - 0x003C
// LIE_EAST          - 0x003D
// CAST_1_EAST       - 0x003E
// CAST_2_EAST       - 0x003F
enum npc_rot_frames
{
   STAND_NORTH       = 0x0000,
   WALK_1_NORTH      = 0x0001,
   WALK_2_NORTH      = 0x0002,
   USE_NORTH         = 0x0003,
   SWING_1_NORTH     = 0x0004,
   SWING_2_NORTH     = 0x0005,
   SWING_3_NORTH     = 0x0006,
   SWING_2H_1_NORTH  = 0x0007,
   SWING_2H_2_NORTH  = 0x0008,
   SWING_2H_3_NORTH  = 0x0009,
   SIT_NORTH         = 0x000A,
   LEAN_NORTH        = 0x000B,
   KNEEL_NORTH       = 0x000C,
   LIE_NORTH         = 0x000D,
   CAST_1_NORTH      = 0x000E,
   CAST_2_NORTH      = 0x000F,
   STAND_SOUTH       = 0x0010,
   WALK_1_SOUTH      = 0x0011,
   WALK_2_SOUTH      = 0x0012,
   USE_SOUTH         = 0x0013,
   SWING_1_SOUTH     = 0x0014,
   SWING_2_SOUTH     = 0x0015,
   SWING_3_SOUTH     = 0x0016,
   SWING_2H_1_SOUTH  = 0x0017,
   SWING_2H_2_SOUTH  = 0x0018,
   SWING_2H_3_SOUTH  = 0x0019,
   SIT_SOUTH         = 0x001A,
   LEAN_SOUTH        = 0x001B,
   KNEEL_SOUTH       = 0x001C,
   LIE_SOUTH         = 0x001D,
   CAST_1_SOUTH      = 0x001E,
   CAST_2_SOUTH      = 0x001F,
   STAND_WEST        = 0x0020,
   WALK_1_WEST       = 0x0021,
   WALK_2_WEST       = 0x0022,
   USE_WEST          = 0x0023,
   SWING_1_WEST      = 0x0024,
   SWING_2_WEST      = 0x0025,
   SWING_3_WEST      = 0x0026,
   SWING_2H_1_WEST   = 0x0027,
   SWING_2H_2_WEST   = 0x0028,
   SWING_2H_3_WEST   = 0x0029,
   SIT_WEST          = 0x002A,
   LEAN_WEST         = 0x002B,
   KNEEL_WEST        = 0x002C,
   LIE_WEST          = 0x002D,
   CAST_1_WEST       = 0x002E,
   CAST_2_WEST       = 0x002F,
   STAND_EAST        = 0x0030,
   WALK_1_EAST       = 0x0031,
   WALK_2_EAST       = 0x0032,
   USE_EAST          = 0x0033,
   SWING_1_EAST      = 0x0034,
   SWING_2_EAST      = 0x0035,
   SWING_3_EAST      = 0x0036,
   SWING_2H_1_EAST   = 0x0037,
   SWING_2H_2_EAST   = 0x0038,
   SWING_2H_3_EAST   = 0x0039,
   SIT_EAST          = 0x003A,
   LEAN_EAST         = 0x003B,
   KNEEL_EAST        = 0x003C,
   LIE_EAST          = 0x003D,
   CAST_1_EAST       = 0x003E,
   CAST_2_EAST       = 0x003F
};

// Enum: damage_types
// Constants for the various types of damage in the game.
//
// NORMAL_DAMAGE     = 0 - Normal damage.
// FIRE_DAMAGE       = 1 - Damage from heat sources.
// MAGIC_DAMAGE      = 2 - Damage from a magical source.
// LIGHTNING_DAMAGE  = 3 - Damage from electrical sources such as lightning.
// ETHEREAL_DAMAGE   = 4 - Special magical damage, basically magic damage not
// blocked by normal magic resistance.
// SONIC_DAMAGE      = 5 - Sound-based damage.
enum damage_types
{
   NORMAL_DAMAGE     = 0,
   FIRE_DAMAGE       = 1,
   MAGIC_DAMAGE      = 2,
   LIGHTNING_DAMAGE  = 3,
   ETHEREAL_DAMAGE   = 4,
   SONIC_DAMAGE      = 5
};
