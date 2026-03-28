void Devon object#(0x4ea) ()
{
	gflags[TORAN_DEAD] = true; //until we have a cutscene which sets this flag we will set it here as toran is always dead before talking to shaana		

	///////////////////////////
	// FORCE LOITER SCHEDULE //
	///////////////////////////
	var npc = item;
	var pos = UI_get_object_position(npc);

	UI_halt_scheduled(npc);

	var sched = [
		[0, 21, pos[1], pos[2], pos[3]],
		[3, 21, pos[1], pos[2], pos[3]],
		[6, 21, pos[1], pos[2], pos[3]],
		[9, 21, pos[1], pos[2], pos[3]],
		[12, 21, pos[1], pos[2], pos[3]],
		[15, 21, pos[1], pos[2], pos[3]],
		[18, 21, pos[1], pos[2], pos[3]],
		[21, 21, pos[1], pos[2], pos[3]]
	];

	UI_set_new_schedules(npc, sched);

	UI_set_schedule_type(npc, 21);
	if (!UI_get_item_flag(npc, IN_PARTY))
		UI_run_schedule(npc);


	///////////
	// SETUP //
	///////////

	var party = UI_get_party_list();
	var player_name = getAvatarName();
	var polite_title = getPoliteTitle();
	var hour = UI_game_hour();
	var partynum = UI_get_array_size(party);
	var bark;
	var player_is_female = UI_is_pc_female();
	var greeting;
	var avatar_bark;
	var npc_bark;
	var time_of_day = timeFunction(hour);
	var schedule = UI_get_schedule_type(item);
	var current_schedule = schedule; 

	var av_1st_greet;
	var npc_1st_greet;
				
	var av_2nd_greet;
	var npc_2nd_greet;	
	
	var avatar_goodbye;
	var npc_goodbye;

	var map = UI_get_map_num(AVATAR);
	
	var lithosHis = gflags[LITHOS_HIS];
	var hydrosFree = gflags[HYDROS_FREE];
	var pyrosFree = gflags[PYROS_FREE];
	var hasHeart = gflags[HAS_HEART];
	var devonInRule = gflags[DEVON_IN_RULE];
	var toranDead = gflags[TORAN_DEAD];
	var metDevonInJail = gflags[MET_DEVON_IN_JAIL];
	var secondexecution = gflags[SECOND_EXECUTION];
	var shaanaBored = gflags[SHAANA_BORED];
	var sawShaana = gflags[SAW_SHAANA];
	var shaanaSchedule = gflags[SHAANA_SCHEDULE];
	// var shaanaMet = gflags[SHAANA_MET]; handle with Exult NPC flag instead

	var shaanaMad1 = gflags[SHAANA_MAD1];
	var shaanaMad2 = gflags[SHAANA_MAD2];
	var shaanaMad3 = gflags[SHAANA_MAD3];

	var madLevel = 0;
	if (shaanaMad3) {
		madLevel = 3;
	} else if (shaanaMad2) {
		madLevel = 2;
	} else if (shaanaMad1) {
		madLevel = 1;
	}

	UI_error_message("=====FLAGS=====");
	UI_error_message("lithosHis flag is: " + lithosHis);
	UI_error_message("hydrosFree flag is: " + hydrosFree);
	UI_error_message("pyrosFree flag is: " + pyrosFree);
	UI_error_message("hasHeart flag is: " + hasHeart);
	UI_error_message("devonInRule flag is: " + devonInRule);
	UI_error_message("toranDead flag is: " + toranDead);
	UI_error_message("metDevonInJail flag is: " + metDevonInJail);
	UI_error_message("secondexecution flag is: " + secondexecution);
	UI_error_message("SHAANA_NAME flag is: " + gflags[SHAANA_NAME]);
	UI_error_message("SHAANA_AXE flag is: " + gflags[SHAANA_AXE]);
	//UI_error_message("shaanaJob flag is: " + shaanaJob);
	//UI_error_message("shaanaMad flag is: " + shaanaMad);
	UI_error_message("sawShaana flag is: " + sawShaana);
	UI_error_message("shaanaSchedule flag is: " + shaanaSchedule);
	UI_error_message("shaanaBored flag is: " + shaanaBored);
	UI_error_message("=====FLAGS=====");	
	
	////////////////////
	// BARK SETUP //
	////////////////	
	if (event == PROXIMITY)
	{
		var barks = ["@En guard!@", "@Watch this!@", "@ooouuu...@", "@auuggh...@"];
		var size = UI_get_array_size(barks);
		var rand = UI_get_random(size);
		delayedBark(item, barks[rand], 2);
	}


	////////////////////////
	// START CONVERSATION //
	////////////////////////
	if (event == DOUBLECLICK)
	{
		av_1st_greet = "@Pardon me...@";
		npc_1st_greet = "@Yes?@";
				
		av_2nd_greet  = "@May we speak?@";
		npc_2nd_greet = "@What now?@";	
		
		startConvo(item, av_1st_greet, npc_1st_greet, av_2nd_greet, npc_2nd_greet); 
	}

	var started_talking = UI_get_item_flag(item, READ);
	UI_error_message("READ flag is: " + started_talking);


	///////////////////////////////
	// NPC CONDITIONAL RESPONSES //
	///////////////////////////////
	if (started_talking)
	{
		UI_error_message("begin started talking conditionals");

		if (toranDead && map == 3 && !devonInRule)  //map 3 is the Docks
		{
			UI_error_message("condition met: toran dead & devon not tempest & we're at the docks");
			item.say("@I am much too busy to talk to you now. Out of my way!@");
			sayGoodbye2(item);
			return;
		}
		else if (toranDead && map == 3 && devonInRule) //map 3 is the Docks
		{
			UI_error_message("condition met: toran dead & devon is the tempest & we're at the docks");
			var pain = ["@Aaagh...@", "@Ooooo...@"];
			var size = UI_get_array_size(pain);
			var rand = UI_get_random(size);
			item.say(pain[rand]);
			sayGoodbye2(item);
			return;
		}
		else if (toranDead && (hydrosFree + pyrosFree + hasHeart > 1))
		{
			UI_error_message("condition met: toran dead & hydros free & pyros free & we have heart");
			item.say("@You fool! I have no time for conversation. The Titans are angry. You had best find permanent cover!@");
			sayGoodbye2(item);
			return;
		}
		else if (toranDead && hasHeart)
		{
			UI_error_message("condition met: toran dead & we have heart of the earth");
			item.say("@I speak to no one when the living dead walk the streets. If you are dead, then return to where you once rested. And if you are alive, you had best find shelter from the rampaging ghouls and the quaking ground!@");
			sayGoodbye2(item);
			return;
		}
		//END CONDITIONALS
		UI_error_message("complete started talking conditionals");
		
		/////////////////////////////
		// HANDLE INITIAL EXCHANGE //
		/////////////////////////////		
		var is_first = !UI_get_item_flag(item, MET);
		if (is_first)
		{
			UI_error_message("!shaanaMet");
			item.say("@Good day, stranger.@");
		}
		else
		{
			UI_error_message("shaanaMet");
			var greetings = ["@Hello again.@"];

			if (gflags[SHAANA_NAME])
			{
				UI_error_message("shaanaName");
				UI_error_message("SHAANA_NAME flag is: " + gflags[SHAANA_NAME]);			
				greetings = greetings & ["@Hello again, Shaana.@"];
			}
			var size = UI_get_array_size(greetings);
			var rand = UI_get_random(size);
			item.say(greetings[rand]);
		}
		UI_set_item_flag(item, MET);
		
		var pried = false;
		
		var options = [];
		
		if (!is_first)
		{
			options = options & ["may we speak"];
		}
		
		if (!gflags[SHAANA_NAME])
		{
			options = options & ["who are you"]; 
		}
		
		if (!gflags[SHAANA_AXE] && is_first) {  //nice axe only available in first interaction
			options = options & ["nice axe"];
		}
		
		if (gflags[SHAANA_NAME] && gflags[SHAANA_AXE])
		{
			options = options & ["what do you do"];
			options = options & ["who was the man I saw you kill"];
		}
		
		if (map == 8) {  // map 8 is plateau
			options = options & ["why are you here"];
		}
		
		if (metDevonInJail)
		{
			options = options & ["why was bentic killed"];
		}
		
		options = options & ["goodbye"];
		
		converse(options)
		{
			UI_error_message("=====ENTERED MAIN CONVERSE=====");
			case "may we speak" (remove):
				if (madLevel >= 3)
				{
					say("@Enough of this, fool! I am not here to act as your source for information. If you feel the need for idle gossip, go and listen to Orlok's grand stories.@");
					sayGoodbye2(item);
					break;
				}
				else if (madLevel == 2)
				{
					say("@Have you nothing more to do than have me answer your questions? Do you not think I have work elsewhere to do?@");
					sayGoodbye2(item);
					break;
				}
				else
				{
					say("@Very well, stranger. You have a moment. What is it that you want? And I assume it is not to beg me away from an appointed task.@");
					add(["what is your task", "goodbye"]);
					if (metDevonInJail)
					{
						add("why was bentic killed");
					}
					// Escalate mad level for prying
					if (madLevel == 0) gflags[SHAANA_MAD1] = true;
					else if (madLevel == 1)
					{
						gflags[SHAANA_MAD1] = false;
						gflags[SHAANA_MAD2] = true;
					}
					else if (madLevel == 2)
					{
						gflags[SHAANA_MAD2] = false;
						gflags[SHAANA_MAD3] = true;
					}
				}
			
			case "who are you" (remove):
				say("@Not that it is any of your concern, stranger, I am called Shaana.@");
				UI_error_message("SHAANA_NAME flag before attempting set: " + gflags[SHAANA_NAME]);
				gflags[SHAANA_NAME] = true;
				UI_error_message("SHAANA_NAME flag after attempting set: " + gflags[SHAANA_NAME]);
				if (gflags[SHAANA_NAME] && gflags[SHAANA_AXE])
				{
					add(["what do you do", "who was the man I saw you kill"]);
				}
			
			case "nice axe" (remove):
				say("@Yes, stranger, it is.@");
				UI_error_message("SHAANA_AXE flag before attempting set: " + gflags[SHAANA_AXE]);
				gflags[SHAANA_AXE] = true;
				UI_error_message("SHAANA_AXE flag after attempting set: " + gflags[SHAANA_AXE]);
				if (gflags[SHAANA_NAME] && gflags[SHAANA_AXE])
				{
					add(["what do you do", "who was the man I saw you kill"]);
				}
			
			case "what do you do" (remove):
				say("@I assume you are speaking in jest, for it is obvious by my executioner's blade that I... remove heads to earn my keep. Why are you so concerned about my name and occupation?@");
				add(["i am not", "i am simply curious"]);

			case "i am not" (remove):
				UI_error_message("click registered on: *i am not*");
				remove("i am simply curious");	
				say("@Then by all means stop wasting my time. One would think you were employed by the scholar, the way you waste time with useless banter.@");
				gflags[SHAANA_BORED] = true;
				add(["who is the scholar", "i am not wasting time"]);
				pried = true;
					
			case "i am simply curious" (remove):
				UI_error_message("click registered on: *i am simply curious*");
				remove("i am not");
				say("@I am not here to satisfy an idle curiosity, stranger. One would think you were employed by the scholar, the way you waste time with useless banter.@");
				gflags[SHAANA_BORED] = true;
				add(["who is the scholar", "i am not wasting time"]);
				pried = true;
			
			case "who was the man I saw you kill" (remove):
				say("@The man I just killed? You must be an imbecile to think that I have any knowledge -- or desire for the knowledge -- of whom I execute. Even were I interested, there are too many to remember. Why are you so concerned about me and my victims?@");
				add(["i am not", "i am simply curious"]);

			case "i am not" (remove):
				UI_error_message("click registered on: *i am not*");
				remove("i am simply curious");	
				say("@Then by all means stop wasting my time. One would think you were employed by the scholar, the way you waste time with useless banter.@");
				gflags[SHAANA_BORED] = true;
				add(["who is the scholar", "i am not wasting time"]);
				pried = true;
					
			case "i am simply curious" (remove):
				UI_error_message("click registered on: *i am simply curious*");
				remove("i am not");
				say("@I am not here to satisfy an idle curiosity, stranger. One would think you were employed by the scholar, the way you waste time with useless banter.@");
				gflags[SHAANA_BORED] = true;
				add(["who is the scholar", "i am not wasting time"]);
				pried = true;
			
			case "why are you here" (remove):
				say("@'Twould be best for you, stranger, to ignore such things. Tell no one of seeing me here... or you, yourself, shall feel my axe upon your scrawny neck.@");
				gflags[SAW_SHAANA] = true;
				sayGoodbye2(item);
				break;
			
			case "why was bentic killed" (remove):
				say("@'Tis not mine to judge the condemned. I simply carry out The Lady's commands. If you have issue with that, I suggest you speak with her. Goodbye.@");
				sayGoodbye2(item);
				break;

			case "who is the scholar" (remove):
				UI_error_message("click registered on: *who is the scholar*");
				remove("i am not wasting time");
				say("@If I am to be a source of information, I do not expect this to occupy too much of my time. The scholar, Bentic, is a rather long-winded individual who spends his days and nights buried in the pages of the many books he maintains. In fact, stranger, perhaps you should speak with him. His work -is- knowledge, after all, and I doubt the rest of us have time for this prattle. Then again, you seem the sort to be more interested in hearing rumors in a darkened tavern than the ramblings of a learned man.@");
				add(["where is the scholar", "where is the tavern"]);

			case "i am not wasting time" (remove):
				remove("who is the scholar");
				say("@You are wrong, stranger. You are wasting mine. Farewell.@");
				sayGoodbye2(item);
				break;

			case "where is the scholar" (remove):
				say("@So it -is- the knowledge you seek. Then you may find Bentic in the northeastern part of town. He is wise and knows much, and he will impart that which you wish and more. I will tell you this, stranger: if he cannot answer your query then only one other might. But I am loath to tell you who for fear you would waste his precious time like you have mine.@");
				add("who is this other");

			case "where is the tavern" (remove):
				say("@The Shattered Skull is the large building in the center of town. Orlok is the man you seek. I am certain his tales of seafaring will amuse you to no end.@");

			case "who is this other" (remove):
				say("@Swear to me you will not disturb his study without due cause and I will name him. Agreed?@");
				add(["aye, i swear", "i swear nothing"]);

			case "aye, i swear" (remove):
				remove("i swear nothing");
				say("@Very well. His name is Mythran. You may find him outside the city walls. His wisdom is great, but I warn you not to visit him for idle prattle such as this. I swear myself that you do not wish to see me angered.@");

			case "i swear nothing" (remove):
				remove("aye, i swear");
				say("@Then I tell nothing.@");
				add("i apologize. i swear");

			case "i apologize. i swear" (remove):
				say("@I hope for your sake you speak the truth. I swear myself that you do not wish to see me angered. Very well. His name is Mythran. You may find him outside the city walls. His wisdom is great, but I warn you not to visit him for idle prattle such as this.@");

			case "what is your task" (remove):
				say("@I think that you need not know such things. But let me assure you that not all of my life revolves around death. Most times there are far more interesting things to study than a decapitated body.@");
				add(["what do you study", "only most of the time"]);

			case "only most of the time" (remove):
				remove("what do you study");
				say("@I have warned you not to pry into my affairs. Do not fool yourself into thinking that I am incapable of performing the duties of my position -- even when the victims are not bound. I have -no- qualms about slaying someone who deserves to die. Though I do not necessarily agree with the Lady's methods.@");
				add("with what do you disagree");

			case "what do you study" (remove):
				remove("only most of the time");
				say("@My dear stranger, if I have not yet made it perfectly clear that my business is none of your concern, let me do so now. As far as you need know, I am but an executioner. Nothing more, but nothing less.@");
				add("yet you study other pursuits");

			case "yet you study other pursuits" (remove):
				say("@I have warned you not to pry into my affairs. Do not fool yourself into thinking that I am incapable of performing the duties of my position -- even when the victims are not bound. I have -no- qualms about slaying someone who deserves to die. Though I do not necessarily agree with the Lady's methods.@");
				add("with what do you disagree");

			case "with what do you disagree" (remove):
				var response1;
				response1 = "@'Tis not right to let the body fall to The Lurker. It violates the pact, something for which Lithos will not likely stand much longer.@";
				if (devonInRule)
				{
					response1 = "@'Tis a moot point, considering she is no longer alive, but it was not right to let the body fall to The Lurker. It violated the pact, something which Lithos was not likely to tolerate much longer.@";
				}
				say(response1);
				if (!lithosHis)
				{
					add(["who is lithos", "what pact"]);
				}

			case "who is lithos" (remove):
				say("@I know not from where you hail, stranger, but I wonder about a man who does not know of the Titans. Speak to the scholar. He will show you the answer to your question. I assume you -do- know how to read.@");
				gflags[LITHOS_HIS] = true;

			case "what pact" (remove):
				say("@You know very little of our culture, stranger. I suggest that change. The pact is one forged ages ago between Lithos and our people. Our duty from the covenant is to send our dead to Lithos. Yet Lady Mordea elects to give them to her patron, Hydros. 'Tis only a matter of time before the dead rise up and avenge the Mountain King.@");
				gflags[LITHOS_HIS] = true;
				add(["dead rising up", "the mountain king"]);

			case "dead rising up" (remove):
				remove("the mountain king");
				say("@Aye, so the story goes. When he is angry, Lithos will set upon us our long lost kindred which he has willed to live again. Well, 'tis hardly living, but legend holds that they walk and fight like men. I have seen such wander about inside the confines of the cemetery, though even -I- have not dared to enter within.@");
				add("why do you avoid the cemetery");

			case "the mountain king" (remove):
				remove("dead rising up");
				say("@'Tis the earned title for Lithos, He who resides in the great Hall within the mountains. However, few have ever been there.@");
				add("which few");

			case "why do you avoid the cemetery" (remove):
				say("@An odd question, stranger. I do not wish audience with the dead. That is the realm of the Necromancers.@");
				add("who are the necromancers");

			case "which few" (remove):
				say("@The Necromancers.@");
				add("who are the necromancers");

			case "who are the necromancers" (remove):
				say("@I tire of these questions. They are common to all Tenebraeans, yet to me do you pose them. The Necromancers are the line of mages who carry out our half of the pact with Lithos. Their duties are quite distasteful, but they are necessary. If you are truly interested in them, why not speak to them yourself.@");
				add("are they in the cemetery");

			case "are they in the cemetery" (remove):
				say("@Do not tell me you are so much a fool as to take me seriously! I will grant you this, stranger, you are indeed brave if not equally senseless! Aye, the Necromancers reside in the graveyard. Beware where you tread.@");

			case "goodbye" (remove):
				avatar_goodbye = "@Goodbye.@";
				//npc_goodbye = "@Farewell.@"; she doesn't say much
				sayGoodbye(item, npc_goodbye, avatar_goodbye);
				break;
		}
	}
}