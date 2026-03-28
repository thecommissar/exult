/*
    Copyright (C) 2007 Malignant Manor

    This file is part of SI BG Merge.

    SI BG Merge is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 2 of the License, or
    (at your option) any later version.

    SI BG Merge is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with SI BG Merge.  If not, see <http://www.gnu.org/licenses/>.

    Author: Malignant Manor
    Last Modified: 2008-09-11
*/

Gremlin_function object#()() //weapon function for stealing food
{
	var var0000;
	var var0001;
	var var0002;
	var var0003;

	var0000 = UI_find_nearby(item, 0x0201, 0x0003, 0x0000);
	var0001 = UI_get_cont_items(item, 0x0179, -359, -359);
	if (!var0001) goto labelFunc0627_008C;
	var0002 = UI_set_last_created(var0001[0x0001]);
	if (!(var0002 && var0000)) goto labelFunc0627_004C;
	var0002 = UI_give_last_created(var0000[0x0001]);
	labelFunc0627_004C:
		if (!((UI_die_roll(0x0001, 0x0002) == 0x0001) && (var0001[0x0002] != 0x0000))) goto labelFunc0627_008C;
		var0002 = UI_set_last_created(var0001[0x0002]);
		if (!(var0002 && var0000)) goto labelFunc0627_008C;
		var0002 = UI_give_last_created(var0000[0x0001]);
	labelFunc0627_008C:
		if (!(var0000 && (UI_die_roll(0x0001, 0x0002) == 0x0001))) goto labelFunc0627_00DD;
		var0001 = UI_find_nearby(var0000[0x0001], 0x0179, 0x000A, 0x0000);
		if (!var0001) goto labelFunc0627_00DD;
		var0002 = UI_set_last_created(var0001[0x0001]);
		if (!var0002) goto labelFunc0627_00DD;
		var0002 = UI_give_last_created(var0001[0x0001]);
	labelFunc0627_00DD:
		return;
}
