/*
 *	Copyright 2019 AgentOrangeGuy 
 *
 *	This program is free software: you can redistribute it and/or modify it under the terms
 *	of the GNU General Public License as published by the Free Software Foundation,
 *	either version 2 of the Licens,e or (at your option) any later version.
 *
 *	This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
 *	without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 *	See the GNU General Public License for more details.
 *
 *	You should have received a copy of the GNU General Public License along with this program.
 *	If not, see <http://www.gnu.org/licenses/>.
 */

	//Used to initiate SI-style conversations

	void playRandomSong()
	{
		var track;
		var rand = UI_get_random(4);
		
		//get avatar's map
		var map = UI_get_map_num(AVATAR);
		
		if (map == 1 || map == 2)
			track = 52; //U6 dungeon
		else if (map == 3)
			track = 103; //gargish theme
		else
		{
			
			if (rand == 1)
				track = 3; //U6 theme
			else if (rand == 2)
				track = 23; //Rule Britannia
			else if (rand == 3)
				track = 207; //U6 Forest theme
			else if (rand == 4)
				track = 208; //U6 stones
			
		}	
		UI_play_music(track);
	}
 
	var startConvo(var npc, var av_1st_greet, var npc_1st_greet, var av_2nd_greet, var npc_2nd_greet) 
	{
		var bark;
		var met_npc = UI_get_item_flag(npc, MET);
		var current_track = UI_get_music_track();
		var avatar_pos = UI_get_object_position(AVATAR);
		
		if (!UI_is_dest_reachable(npc, avatar_pos))
		{
			UI_clear_item_flag(item, READ); //to allow greeting barks to play next time
		
		}
		else
		{
			//Avatar barks
			if (!met_npc)
				bark = av_1st_greet;  
			else 
				bark = av_2nd_greet; 
			
			delayedBark(AVATAR, bark, 0);
			
			//attempt to clear the default "Stop!" barks
			UI_clear_item_say(npc);	

			//if annoying combat music is played, clear it.
			if (current_track == 10 || current_track == 11 || current_track == 12 || current_track == 16)
				UI_play_music(255);
				
			
			//NPC barks
			if (!met_npc)
				bark = npc_1st_greet;  
			else 
				bark = npc_2nd_greet; 
			delayedBark(npc, bark, 3);	

			UI_set_schedule_type(npc, TALK);
			UI_set_item_flag(npc, READ); //to start convo
		}	
	}
	
	void sayGoodbye(var npc, var npc_goodbye, var avatar_goodbye)
	{
	
	//Prevent circular conversation, clear flags and schedules as needed
		//clear TALK schedule and go back to activities
		UI_set_schedule_type(npc, LOITER);
		
		//if NPC is in party, make them get back with the Avatar instead of wandering around
		if (UI_get_item_flag(npc, IN_PARTY))
			UI_set_schedule_type(npc, FOLLOW_AVATAR);
		else	
			UI_run_schedule(npc);
		
		//clear any initial Avatar & npc barks to prevent overlapping
		UI_clear_item_say(AVATAR); 
		UI_clear_item_say(npc);
		UI_clear_item_flag(item, READ); //to allow greeting barks to play next time
		
		//Avatar and NPC goodbye barks
		delayedBark(AVATAR, avatar_goodbye, 4);
		delayedBark(npc, npc_goodbye, 12);
		
		//should play random song if song isn't already playing. 
		var current_track = UI_get_music_track();
		if (!current_track)
			playRandomSong();
			
	}
	
	//when you want to abruptly end a convo without saying anything
	void sayGoodbye2(var npc)
	{
		//clear previous barks
		UI_clear_item_say(npc);	
		
		//Prevent circular conversation, clear flags and schedules as needed
		//clear TALK schedule and go back to activities
		UI_set_schedule_type(npc, LOITER);
		
		//if NPC is in party, make them get back with the Avatar instead of wandering around
		if (UI_get_item_flag(npc, IN_PARTY))
			UI_set_schedule_type(npc, FOLLOW_AVATAR);
		else	
			UI_run_schedule(npc);
		
		
		//clear any initial Avatar & npc barks to prevent overlapping
		UI_clear_item_say(AVATAR); 
		UI_clear_item_say(npc);
		UI_clear_item_flag(item, READ); //to allow greeting barks to play next time
		
				
		//should play random song if song isn't already playing. 
		var current_track = UI_get_music_track();
		if (!current_track)
			playRandomSong();
	
	}	
	
	//when you want them to say something as they leave abruptly
	void sayGoodbyeAbrupt(var npc, npc_goodbye)
	{	
		//clear TALK schedule and go back to activities
		UI_set_schedule_type(npc, LOITER);
				
		//if NPC is in party, make them get back with the Avatar instead of wandering around
		if (UI_get_item_flag(npc, IN_PARTY))
			UI_set_schedule_type(npc, FOLLOW_AVATAR);
		else	
			UI_run_schedule(npc);
		
		//clear any initial Avatar & npc barks to prevent overlapping
		UI_clear_item_say(AVATAR); 
		UI_clear_item_say(npc);
		UI_clear_item_flag(item, READ); //to allow greeting barks to play next time
	
		delayedBark(npc, npc_goodbye, 4);
				
		//should play random song if song isn't already playing. 
		var current_track = UI_get_music_track();
		if (!current_track)
			playRandomSong();
	}
