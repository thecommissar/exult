enum party_levels
{
	SCHEDULE_MOVE                                      = 1,
	PERFORM_MOVE                                       = 2

};

void leaveParty  object#()()
{
	UI_set_schedule_type(item, WANDER);
	UI_remove_from_party(item);
	UI_clear_item_flag(item, IN_PARTY);

	if (event == SCHEDULE_MOVE)
	{
		script item after 150 ticks
		{
			call leaveParty, PERFORM_MOVE;
		}
		return;
	}

	if (event == PERFORM_MOVE)
	{
		var npc_name = UI_get_npc_name(item);

		if (npc_name == "ExampleTestNpcDude")
		{
			UI_move_object(item, [0, 0, 0, 1], true);
		}
		else
		{
			UI_move_object(item, [2883, 2826, 0, 0], true); //entrance to Hythloth
		}
	}
}