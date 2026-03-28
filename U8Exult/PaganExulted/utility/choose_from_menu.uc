

var chooseFromMenu 0x956 (var choices)
{
	var selection;

	UI_push_answers();
	add(choices);
	selection = UI_select_from_menu();
	UI_pop_answers();
	return selection;
}

//var chooseFromMenu2 0x957 (var choices)
//{
//	var selection;

	//UI_push_answers();
//	add(choices);
//	selection = UI_select_from_menu2();
//	UI_pop_answers();
//	return selection;
//}
