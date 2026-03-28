

void delayedBark 0x97F (var npc, var bark_text, var delay)
{
	var action;

	if (UI_get_array_size(bark_text) > 1)
		bark_text = bark_text[1];
 
	if (npcCanTalk(npc))
		action = UI_delayed_execute_usecode_array(UI_get_npc_object(npc), [no_halt, script_bark, bark_text], delay);
 
	return;
}
