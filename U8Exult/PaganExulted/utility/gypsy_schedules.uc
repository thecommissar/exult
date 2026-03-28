var gypsySchedule (var day)
{
	//used with a usecode egg placed in each location, checks for game day then converts to "day"
	
	/* Taynith starts in Yew on Day 1, then catches up with the Gypsies there. 
	*  On day 5 she deviates from the main Gypsy schedule to chill with Dr. Cat 
	*  and on day 6 she catches up with them in Britain?
	*  
	*/
	var sleep_pos;
	var loiter_pos;
	var tavern_pos;
	

	if (day == 0)
	{
	
		//Britain
		UI_modify_schedule(TAYNITH, 0, SLEEP, [1236, 1315]); //midnight
		UI_modify_schedule(TAYNITH, 2, LOITER, [1215, 1293]); //6am
		UI_modify_schedule(TAYNITH, 7, EAT_AT_INN, [1199, 1262]); //9pm
		
		UI_modify_schedule(BLAINE, 0, SLEEP, [1224, 1325]); //midnight
		UI_modify_schedule(BLAINE, 2, DANCE, [1217, 1294]); //6am
		UI_modify_schedule(BLAINE, 7, EAT_AT_INN, [1214, 1263]); //9pm
		
		UI_modify_schedule(ZOLTAN, 0, SLEEP, [1213, 1317]); //midnight
		UI_modify_schedule(ZOLTAN, 2, LOITER, [1215, 1297]); //6am
		UI_modify_schedule(ZOLTAN, 7, EAT_AT_INN, [1204, 1265]); //9pm
		
		UI_modify_schedule(KARINA, 0, SLEEP, [1234, 1311]); //midnight
		UI_modify_schedule(KARINA, 2, LOITER, [1228, 1294]); //6am
		UI_modify_schedule(KARINA, 7, EAT_AT_INN, [1220, 1274]); //9pm
		
		UI_modify_schedule(KADOR, 0, SLEEP, [1215, 1323]); //midnight
		UI_modify_schedule(KADOR, 2, LOITER, [1209, 1287]); //6am
		UI_modify_schedule(KADOR, 7, TEND_SHOP, [1206, 1260]); //9pm
	
		//Trinsic
		UI_modify_schedule(MANDRAKE, 0, SLEEP, [1280, 2471]); //midnight
		UI_modify_schedule(MANDRAKE, 4, LOITER, [1237, 2256]); //noon
		UI_modify_schedule(MANDRAKE, 7, EAT_AT_INN, [1237, 2256]); //9pm
	
		
	

	}
	
	else if (day == 1)
	{
	
		//Yew
		UI_modify_schedule(TAYNITH, 0, SLEEP, [0782, 0513]); //midnight
		UI_modify_schedule(TAYNITH, 2, LOITER, [0743, 0521]); //6am
		UI_modify_schedule(TAYNITH, 7, EAT_AT_INN, [0716, 0486]); //9pm

		UI_modify_schedule(BLAINE, 0, SLEEP, [0781, 0523]); //midnight
		UI_modify_schedule(BLAINE, 2, DANCE, [0743, 0518]); //6am
		UI_modify_schedule(BLAINE, 7, EAT_AT_INN, [0700, 0479]); //9pm
		
		UI_modify_schedule(ZOLTAN, 0, SLEEP, [0793, 0523]); //midnight
		UI_modify_schedule(ZOLTAN, 2, LOITER, [0745, 513]); //6am
		UI_modify_schedule(ZOLTAN, 7, EAT_AT_INN, [0700, 0473]); //9pm
		
		UI_modify_schedule(KARINA, 0, SLEEP, [0793, 0516]); //midnight
		UI_modify_schedule(KARINA, 2, LOITER, [0747, 0528]); //6am
		UI_modify_schedule(KARINA, 7, EAT_AT_INN, [0715, 0488]); //9pm
		
		UI_modify_schedule(KADOR, 0, TEND_SHOP, [0786, 0525]); //midnight
		UI_modify_schedule(KADOR, 2, LOITER, [0745, 0514]); //6am
		UI_modify_schedule(KADOR, 7, LOITER, [0703, 0479]); //9pm
	
		//Paws
		UI_modify_schedule(MANDRAKE, 0, SLEEP, [1144, 1891]); //midnight
		UI_modify_schedule(MANDRAKE, 4, LOITER, [1192, 1785]); //noon
		UI_modify_schedule(MANDRAKE, 7, EAT_AT_INN, [1192, 1785]); //9pm
	
	}
	
	else if (day == 2)
	{
	
		//Yew
		UI_modify_schedule(TAYNITH, 0, SLEEP, [0782, 0513]); //midnight
		UI_modify_schedule(TAYNITH, 2, LOITER, [0743, 0521]); //6am
		UI_modify_schedule(TAYNITH, 7, EAT_AT_INN, [0716, 0486]); //9pm

		UI_modify_schedule(BLAINE, 0, SLEEP, [0781, 0523]); //midnight
		UI_modify_schedule(BLAINE, 2, DANCE, [0743, 0518]); //6am
		UI_modify_schedule(BLAINE, 7, EAT_AT_INN, [0700, 0479]); //9pm
		
		UI_modify_schedule(ZOLTAN, 0, SLEEP, [0793, 0523]); //midnight
		UI_modify_schedule(ZOLTAN, 2, LOITER, [0745, 513]); //6am
		UI_modify_schedule(ZOLTAN, 7, EAT_AT_INN, [0700, 0473]); //9pm
		
		UI_modify_schedule(KARINA, 0, SLEEP, [0793, 0516]); //midnight
		UI_modify_schedule(KARINA, 2, LOITER, [0747, 0528]); //6am
		UI_modify_schedule(KARINA, 7, EAT_AT_INN, [0715, 0488]); //9pm
		
		UI_modify_schedule(KADOR, 0, TEND_SHOP, [0786, 0525]); //midnight
		UI_modify_schedule(KADOR, 2, LOITER, [0745, 0514]); //6am
		UI_modify_schedule(KADOR, 7, LOITER, [0703, 0479]); //9pm
	
		//Paws
		UI_modify_schedule(MANDRAKE, 0, SLEEP, [1144, 1891]); //midnight
		UI_modify_schedule(MANDRAKE, 4, LOITER, [1192, 1785]); //noon
		UI_modify_schedule(MANDRAKE, 7, EAT_AT_INN, [1192, 1785]); //9pm
	
	}
	
	else if (day == 3)
	{
		//Trinsic
		UI_modify_schedule(TAYNITH, 0, SLEEP, [1278, 2260]); //midnight
		UI_modify_schedule(TAYNITH, 2, LOITER, [1259, 2273]); //6am
		UI_modify_schedule(TAYNITH, 7, EAT_AT_INN, [1252, 2258]); //9pm
		
		UI_modify_schedule(BLAINE, 0, SLEEP, [1268, 2255]); //midnight
		UI_modify_schedule(BLAINE, 2, DANCE, [1261, 2279]); //6am
		UI_modify_schedule(BLAINE, 7, EAT_AT_INN, [1232, 2288]); //9pm
		
		UI_modify_schedule(ZOLTAN, 0, SLEEP, [1274, 2266]); //midnight
		UI_modify_schedule(ZOLTAN, 2, LOITER, [1253, 2279]); //6am
		UI_modify_schedule(ZOLTAN, 7, EAT_AT_INN, [1258, 2259]); //9pm
		
		UI_modify_schedule(KARINA, 0, SLEEP, [1278, 2256]); //midnight
		UI_modify_schedule(KARINA, 2, LOITER, [1254, 2273]); //6am
		UI_modify_schedule(KARINA, 7, EAT_AT_INN, [1241, 2256]); //9pm
		
		UI_modify_schedule(KADOR, 0, TEND_SHOP, [1280, 2259]); //midnight
		UI_modify_schedule(KADOR, 2, LOITER, [1242, 2287]); //6am
		UI_modify_schedule(KADOR, 7, LOITER, [1243, 2256]); //9pm
	
		//Britain
		UI_modify_schedule(MANDRAKE, 0, SLEEP, [1045, 1356]); //midnight
		UI_modify_schedule(MANDRAKE, 4, LOITER, [1206, 1264]); //noon
		UI_modify_schedule(MANDRAKE, 7, EAT_AT_INN, [1206, 1264]); //9pm
	
	}
	else if (day == 4)
	{
	
		//Paws
		UI_modify_schedule(TAYNITH, 0, TEND_SHOP, [1192, 1767]); //midnight when she talks to Dr Cat
		UI_modify_schedule(TAYNITH, 2, LOITER, [1210, 1785]); //6am
		UI_modify_schedule(TAYNITH, 7, EAT_AT_INN, [1210, 1785]); //9pm
		
		//Trinsic
		UI_modify_schedule(BLAINE, 0, SLEEP, [1268, 2255]); //midnight
		UI_modify_schedule(BLAINE, 2, DANCE, [1261, 2279]); //6am
		UI_modify_schedule(BLAINE, 7, EAT_AT_INN, [1232, 2288]); //9pm
		
		UI_modify_schedule(ZOLTAN, 0, SLEEP, [1274, 2266]); //midnight
		UI_modify_schedule(ZOLTAN, 2, LOITER, [1253, 2279]); //6am
		UI_modify_schedule(ZOLTAN, 7, EAT_AT_INN, [1258, 2259]); //9pm
		
		UI_modify_schedule(KARINA, 0, SLEEP, [1278, 2256]); //midnight
		UI_modify_schedule(KARINA, 2, LOITER, [1241, 2285]); //6am
		UI_modify_schedule(KARINA, 7, EAT_AT_INN, [1241, 2256]); //9pm
		
		UI_modify_schedule(KADOR, 0, TEND_SHOP, [1280, 2259]); //midnight
		UI_modify_schedule(KADOR, 2, LOITER, [1242, 2287]); //6am
		UI_modify_schedule(KADOR, 7, LOITER, [1243, 2256]); //9pm
	
		//Britain
		UI_modify_schedule(MANDRAKE, 0, SLEEP, [1045, 1356]); //midnight
		UI_modify_schedule(MANDRAKE, 4, LOITER, [1206, 1264]); //noon
		UI_modify_schedule(MANDRAKE, 7, EAT_AT_INN, [1206, 1264]); //9pm
	
	
	}
	else if (day == 5)
	{
		//Britain
		UI_modify_schedule(BLAINE, 0, SLEEP, [1224, 1325]); //midnight
		UI_modify_schedule(BLAINE, 2, DANCE, [1217, 1294]); //6am
		UI_modify_schedule(BLAINE, 7, EAT_AT_INN, [1214, 1263]); //9pm
		
		UI_modify_schedule(ZOLTAN, 0, SLEEP, [1213, 1317]); //midnight
		UI_modify_schedule(ZOLTAN, 2, LOITER, [1215, 1297]); //6am
		UI_modify_schedule(ZOLTAN, 7, EAT_AT_INN, [1204, 1265]); //9pm
		
		UI_modify_schedule(KARINA, 0, SLEEP, [1234, 1311]); //midnight
		UI_modify_schedule(KARINA, 2, LOITER, [1228, 1294]); //6am
		UI_modify_schedule(KARINA, 7, EAT_AT_INN, [1220, 1274]); //9pm
		
		UI_modify_schedule(KADOR, 0, SLEEP, [1215, 1323]); //midnight
		UI_modify_schedule(KADOR, 2, LOITER, [1209, 1287]); //6am
		UI_modify_schedule(KADOR, 7, TEND_SHOP, [1206, 1260]); //9pm
		
		//Trinsic
		UI_modify_schedule(TAYNITH, 0, SLEEP, [1278, 2260]); //midnight
		UI_modify_schedule(TAYNITH, 2, LOITER, [1229, 2283]); //6am
		UI_modify_schedule(TAYNITH, 7, EAT_AT_INN, [1242, 2258]); //9pm
		
		UI_modify_schedule(MANDRAKE, 0, SLEEP, [1280, 2471]); //midnight
		UI_modify_schedule(MANDRAKE, 4, LOITER, [1240, 2256]); //6am
		UI_modify_schedule(MANDRAKE, 7, EAT_AT_INN, [1221, 2256]); //9pm
	
	
	
	
	}
	else if (day == 6)
	{
	
		//Britain
		UI_modify_schedule(BLAINE, 0, SLEEP, [1224, 1325]); //midnight
		UI_modify_schedule(BLAINE, 2, DANCE, [1217, 1294]); //6am
		UI_modify_schedule(BLAINE, 7, EAT_AT_INN, [1214, 1263]); //9pm
		
		UI_modify_schedule(ZOLTAN, 0, SLEEP, [1213, 1317]); //midnight
		UI_modify_schedule(ZOLTAN, 2, LOITER, [1215, 1297]); //6am
		UI_modify_schedule(ZOLTAN, 7, EAT_AT_INN, [1204, 1265]); //9pm
		
		UI_modify_schedule(KARINA, 0, SLEEP, [1234, 1311]); //midnight
		UI_modify_schedule(KARINA, 2, LOITER, [1228, 1294]); //6am
		UI_modify_schedule(KARINA, 7, EAT_AT_INN, [1220, 1274]); //9pm
		
		UI_modify_schedule(KADOR, 0, SLEEP, [1215, 1323]); //midnight
		UI_modify_schedule(KADOR, 2, LOITER, [1209, 1287]); //6am
		UI_modify_schedule(KADOR, 7, TEND_SHOP, [1206, 1260]); //9pm
		
		UI_modify_schedule(TAYNITH, 0, SLEEP, [1236, 1315]); //midnight
		UI_modify_schedule(TAYNITH, 2, LOITER, [1215, 1293]); //6am
		UI_modify_schedule(TAYNITH, 7, EAT_AT_INN, [1199, 1262]); //9pm
		
		//Trinsic
		UI_modify_schedule(MANDRAKE, 0, SLEEP, [1280, 2471]); //midnight
		UI_modify_schedule(MANDRAKE, 4, LOITER, [1240, 2256]); //6am
		UI_modify_schedule(MANDRAKE, 7, EAT_AT_INN, [1221, 2256]); //9pm
	
	}
	
	
}	
	
	
