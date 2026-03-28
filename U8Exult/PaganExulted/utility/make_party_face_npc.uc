


void makePartyFaceNPC object#(0x7D1) () // Approach Avatar for conversation start.
{
	var party_list = UI_get_party_list();
	var index;
	var max;
	var party_member;
	var way_to_face;
	var turn_towards;

	 
	for (party_member in party_list with index to max)
	{
		if (UI_npc_nearby(party_member))
		{
			way_to_face = UI_direction_from(party_member, item);
			turn_towards = UI_execute_usecode_array(party_member, [no_halt, npc_frame_stand, face_dir, way_to_face]);
		}
	}
	
	return;
}
