/*
 *	Copyright 2018 Scott Cooper
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
 */

/*
 *	The standard UI_get_cont_items command cannot be used to search the entire Party.
 *	This is problematic if you wish to get an array of each of a shape carried by the Party,
 *	using a single command.
 *
 *	2018-12-23 Knight Captain
 */

var getPartyItems 0x9D8 (var shape, var quality, var frame)
{
	var count;
	var party;
	var each_member;
	var index;
	var max;
	var member_name;
	var found;

	// Check if the party has any of the item. If not, there is no need to continue.
	count = UI_count_objects(PARTY, shape, quality, frame);
	if (count == 0)
	{
		UI_error_message("getPartyItems The Party has none of Shape ", shape, " Quality ", quality, " Frame ", frame, ".");
		return 0;
	}

	// Documentation does not describe a difference between versions list and list2.
	party = UI_get_party_list();

	UI_error_message("getPartyItems counted ", count, " of Shape ", shape, " Quality ", quality, " Frame ", frame, " in the Party.");
	
	for (each_member in party with index to max)
	{
		member_name = UI_get_npc_name(each_member);
		count = UI_count_objects(each_member, shape, quality, frame);
		if (count == 0)
		{
			UI_error_message("getPartyItems ", member_name, " has none.");
		}
		else
		{
			UI_error_message("getPartyItems ", member_name, " has ", count, ".");
			// This check is necessary to prevent a non-existent "found" being counted by UI_get_array_size below.
			if (found == 0)
				found = (UI_get_cont_items(each_member, shape, quality, frame));
			else
				found = (found & UI_get_cont_items(each_member, shape, quality, frame));
		}
	}

	count = UI_get_array_size(found);
	if (quality == -359)
		quality = "ANY";
	if (frame == -359)
		frame = "ANY";
	UI_error_message("getPartyItems has ", count, " of Shape ", shape, " Quality ", quality, " Frame ", frame, " in the array.");
	
	return found;
}
