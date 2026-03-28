void Aramina object#(0x4f2) ()

//important - search todo in this file for places needing attention

{
	UI_error_message("Aramina usecode called, event: " + event);
	///////////
	// SETUP //
	///////////
	var npc = item;
	var party = UI_get_party_list();
	var player_name = getAvatarName();
	var polite_title;
	if (UI_is_pc_female()) {
		polite_title = "milady";
	} else {
		polite_title = "milord";
	}
	UI_error_message("polite_title set to: " + polite_title);
	var yes_option = "yes, I am " + player_name;  //todo - used in case but not sure if we should gflag "The Avatar" or the player's chosen name?
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
	
	var hydrosFree = gflags[HYDROS_FREE];
	var pyrosFree = gflags[PYROS_FREE];
	var hasHeart = gflags[HAS_HEART];
	var devonInRule = gflags[DEVON_IN_RULE];
	var lothianDead = gflags[LOTHIAN_DEAD];
	var mordeaDead = gflags[MORDEA_DEAD];
	var hearTruthActive = gflags[HEAR_TRUTH_ACTIVE];
	var toldDagger = gflags[TOLD_DAGGER];
	var toldOfTreasure = gflags[TOLD_OF_TREASURE];
	var araminaMet = UI_get_item_flag(item, MET);
	var araminaName = gflags[ARAMINA_NAME];
	var araminaJob = gflags[ARAMINA_JOB];
	var araminaSchedule = gflags[ARAMINA_SCHEDULE];

	UI_error_message("=====ARAMINA FLAGS=====");
	UI_error_message("hydrosFree flag is: " + hydrosFree);
	UI_error_message("pyrosFree flag is: " + pyrosFree);
	UI_error_message("hasHeart flag is: " + hasHeart);
	UI_error_message("devonInRule flag is: " + devonInRule);
	UI_error_message("lothianDead flag is: " + lothianDead);
	UI_error_message("mordeaDead flag is: " + mordeaDead);
	UI_error_message("hearTruthActive flag is: " + hearTruthActive);
	UI_error_message("toldDagger flag is: " + toldDagger);
	UI_error_message("toldOfTreasure flag is: " + toldOfTreasure);
	UI_error_message("araminaMet flag is: " + araminaMet);
	UI_error_message("araminaName flag is: " + araminaName);
	UI_error_message("araminaJob flag is: " + araminaJob);
	UI_error_message("araminaSchedule flag is: " + araminaSchedule);
	UI_error_message("=====ARAMINA FLAGS=====");
	
	/////////////////
	// BARK SETUP //
	////////////////	
	if (event == PROXIMITY)
	{
		var barks = ["I must remember to get some butter.", "hmmmm", "No rest for the weary.", "I must change the bed linens.", "Oh, my poor back.", "I sure could use a day off.", "Oh, my aching bones."];
		var size = UI_get_array_size(barks);
		var rand = UI_get_random(size);
		delayedBark(item, barks[rand], 2);
	}


	////////////////////////
	// START CONVERSATION //
	////////////////////////
	var started_talking = UI_get_item_flag(item, READ);

	if (event == DOUBLECLICK)
	{
		UI_error_message("DOUBLECLICK event triggered");
		UI_error_message("Before setting greetings, araminaMet: " + araminaMet + ", devonInRule: " + devonInRule);
		// Set default greetings (first meeting without Devon)
		av_1st_greet = [];
		npc_1st_greet = "@How may I serve you, stranger?@";
		
		// Set subsequent greetings
		av_2nd_greet = "@Hello again, Aramina.@";
		npc_2nd_greet = [];
		
		// Override based on conditions
		if (!devonInRule && araminaMet)
		{
			UI_error_message("Overriding for subsequent meeting without Devon");
			av_1st_greet = [];
			npc_1st_greet = "@Good morrow to you.@";
		}
		else if (devonInRule && !araminaMet)
		{
			UI_error_message("Overriding for first meeting with Devon");
			av_1st_greet = [];
			npc_1st_greet = "@Good day to you, stranger.@";
		}
		else if (devonInRule && araminaMet)
		{
			UI_error_message("Overriding for subsequent meeting with Devon");
			av_1st_greet = [];
			npc_1st_greet = "@'Tis a grand day, friend " + player_name + ".@";
		}
		
		if (araminaSchedule == 2 || araminaSchedule == 3)
		{
			UI_error_message("araminaSchedule is " + araminaSchedule + ", overriding for busy");
			av_1st_greet = [];
			if (devonInRule)
			{
				npc_1st_greet = "@I'd love to stay and talk, but Devon needs me right now, and...well, you know. Talk to you later, Ta-ta!@";
			}
			else
			{
				npc_1st_greet = "@I am sorry, but I can not talk to you now. I must attend to her ladyship. Find me later at my house in east Tenebrae, I will be there at bloodwatch.@";
			}
		}

		if (hasHeart)
		{
			UI_error_message("hasHeart is true, overriding for dead");
			av_1st_greet = [];
			npc_1st_greet = "@AAhhhhhh! 'Tis another dead one! AAAAHHHHHHHHH!@";
		}
		
		startConvo(item, av_1st_greet, npc_1st_greet, av_2nd_greet, npc_2nd_greet); 
		UI_error_message("~~~~Pull Params From startConvo Function~~~~");				
		UI_error_message("~~startConvo item: " + item);				
		UI_error_message("~~startConvo av_1st_greet: " + av_1st_greet);
		UI_error_message("~~startConvo npc_1st_greet: " + npc_1st_greet);
		UI_error_message("~~startConvo av_2nd_greet: " + av_2nd_greet);
		UI_error_message("~~startConvo npc_2nd_greet: " + npc_2nd_greet);
	}

	UI_error_message("READ flag is: " + started_talking);

	///////////////////////////////
	// NPC CONDITIONAL RESPONSES //
	///////////////////////////////
	if (started_talking)
	{
		UI_error_message("begin started talking conditionals");

		if (hasHeart)
		{
			item.say("@AAhhhhhh! 'Tis another dead one! AAAAHHHHHHHHH!@");
			sayGoodbye2(item);
			return;
		}
		else
		{
			// Fallback greeting description
			if (devonInRule)
			{
				item.say("Aramina smiles warmly as you approach her.");
			}
			else
			{
				item.say("The timid servant girl glances nervously at you.");
			}
		}

		//END CONDITIONALS
		UI_error_message("complete started talking conditionals");
		
		/////////////////////////////
		// HANDLE INITIAL EXCHANGE //
		/////////////////////////////
		
		var is_first = !araminaMet;
		
		UI_set_item_flag(item, MET, true);
		
		var options = [];
		UI_error_message("Building options, araminaName: " + araminaName + ", araminaJob: " + araminaJob + ", araminaMet: " + araminaMet + ", devonInRule: " + devonInRule);
		
		if (!araminaName)
		{
			if (devonInRule && !araminaMet)
			{
				UI_error_message("Adding 'What is your name?'");
				options = options & ["What is your name?"];
			}
			else
			{
				UI_error_message("Adding 'by what are you called'");
				options = options & ["by what are you called"];
			}
		}
		
		if (araminaName)
		{
			UI_error_message("Adding 'what do you do here'");
			options = options & ["what do you do here"];
		}
		
		if (araminaJob)
		{
			UI_error_message("Adding 'tell me about the palace'");
			options = options & ["tell me about the palace"];
		}
		
		if (devonInRule && araminaMet)
		{
			UI_error_message("Adding 'it is good to see you smile, Aramina'");
			options = options & ["it is good to see you smile, Aramina"];
		}
		else if (araminaName && araminaJob)
		{
			UI_error_message("Adding 'have you met Devon'");
			options = options & ["have you met Devon"];
		}
		
		if (toldDagger && !lothianDead)
		{
			UI_error_message("Adding 'I'm looking for a dagger'");
			options = options & ["I'm looking for a dagger"];
		}
		
		if (toldOfTreasure)
		{
			UI_error_message("Adding 'what do you know of treasure'");
			options = options & ["what do you know of treasure"];
		}
		
		options = options & ["bye"];
		UI_error_message("Options built, count: " + UI_get_array_size(options));

		//////////////
		// CONVERSE //
		//////////////
		

		converse(options)
		{
		case "by what are you called" (remove):
			UI_error_message("Case 'by what are you called' entered");
			if (!araminaName)
			{
				if (devonInRule && !araminaMet)
				{
					// First meeting with Devon in rule
					UI_error_message("Devon in rule first meeting path");
					say("@I am Aramina, my friend. I work here in the palace for Devon. You're " + player_name + ", aren't you? Devon speaks of you often.@");
					add([yes_option]);
					UI_error_message("Added yes_option: " + yes_option);
				}
				else
				{
					UI_error_message("General first meeting path");
					say("@My name is Aramina.@");
					add(["what do you do here"]);
					UI_error_message("Added 'what do you do here'");
				}
			}
			else
			{
				UI_error_message("Subsequent name ask");
				say("@My name is Aramina.@");
			}
			gflags[ARAMINA_NAME] = true;
			UI_error_message("ARAMINA_NAME set to true");
			if (araminaName && araminaJob)
			{
				UI_error_message("Adding 'have you met Devon'");
				add(["have you met Devon"]);
			}
		
		case "What is your name?" (remove):
			if (!araminaName)
			{
				if (devonInRule && !araminaMet)
				{
					// First meeting with Devon in rule
					say("@I am Aramina, my friend. I work here in the palace for Devon. You're " + player_name + ", aren't you? Devon speaks of you often.@");
					add([yes_option]);
				}
				else
				{
					say("@My name is Aramina.@");
					add(["what do you do here"]);
				}
			}
			else
			{
				say("@My name is Aramina.@");
			}
			gflags[ARAMINA_NAME] = true;
			if (araminaName && araminaJob)
			{
				add(["have you met Devon"]);
			}
		
		case yes_option (remove):
			say("@" + yes_option + ".@");
			say("@Yes, I knew it was you. Did you really save him?@");
			add(["Yes, I did.", "Well, it was nothing, really."]);
		
		case "what do you do here" (remove):
			UI_error_message("Case 'what do you do here' entered");
			say("@I am merely a servant here.@");
			gflags[ARAMINA_JOB] = true;
			UI_error_message("ARAMINA_JOB set to true");
			if (!araminaJob)
			{
				add(["tell me about the palace"]);
				UI_error_message("Added 'tell me about the palace'");
			}
		
		case "tell me about the palace" (remove):
			UI_error_message("Case 'tell me about the palace' entered");
			say("@This is the home of our Tempest, the Lady Mordea.@");
			add(["tell me of Lady Mordea"]);
			UI_error_message("Added 'tell me of Lady Mordea'");
		
		case "tell me of Lady Mordea" (remove):
			if (!hearTruthActive)
			{
				say("@Well, it is not good for me to speak of my employer behind her back, but I will tell you she is a hard woman.@");
			}
			else
			{
				say("@Well, it is not good for me to speak of my employer behind her back, but I will tell you she is a hard woman. (She will stop at nothing to preserve her power here. Nothing, not even murder.)@");
			}
			add(["why do you say she is hard"]);
		
		case "why do you say she is hard" (remove):
			if (!hearTruthActive)
			{
				say("@She hardly notices my existence. At least she does not take pleasure in tormenting me like her seneschal does.@");
			}
			else
			{
				say("@She hardly notices my existence. At least she does not take pleasure in tormenting me like her seneschal does. (She will stop at nothing to preserve her power here. Nothing, not even murder.)@");
			}
			add(["she wishes to preserve power", "murder", "tell me of the seneschal"]);
		
		case "tell me of the seneschal" (remove):
			if (!hearTruthActive)
			{
				say("@Salkind is her seneschal.@");
			}
			else
			{
				say("@Salkind is her seneschal. (Salkind, that evil, perverted man, is her seneschal.)@");
			}
			add(["tell me of Salkind"]);
		
		case "murder" (remove):
			if (!hearTruthActive)
			{
				say("@Murder? Did I say murder? Oh no, I meant mother, that's it, mother. She is like a mother to her people.@");
			}
			else
			{
				say("@Murder? Did I say murder? Oh no, I meant mother, that's it, mother. She is like a mother to her people. (I think she trumps up charges against people who question her authority and then uses the laws of execution to eliminate them...legal murder.)@");
			}
		
		case "she wishes to preserve power" (remove):
			if (!hearTruthActive)
			{
				say("@The power of the Tempestry, " + polite_title + ". The power to control the weather. This is, indeed, great power.@");
			}
			else
			{
				say("@The power of the Tempestry, " + polite_title + ". The power to control the weather. This is, indeed, great power. (She threatens to make the weather bad, or worse yet, send them to the Lurker, if they don't do her bidding.)@");
			}
			add(["tell me of the Tempestry"]);
		
		case "tell me of the Tempestry" (remove):
			say("@Tempestry, " + polite_title + "? Surely you have heard of it. It is the power that is transferred through the bloodline of the Tempests.@");
			add(["what do you mean by 'bloodline'", "what power is transferred"]);
		
		case "what do you mean by 'bloodline'" (remove):
			say("@It is inherited, father to son, mother to daughter.@");
		
		case "what power is transferred" (remove):
			if (!hearTruthActive)
			{
				say("@As I said, " + polite_title + ", the power to control the weather. While at times, a good thing, it can be a powerful weapon to hold over the people's heads.@");
			}
			else
			{
				say("@As I said, " + polite_title + ", the power to control the weather. While at times, a good thing, it can be a powerful weapon to hold over the people's heads. (She holds it over her people's heads.)@");
			}
			add(["she holds it over her people's heads"]);
		
		case "she holds it over her people's heads" (remove):
			if (!hearTruthActive)
			{
				say("@I mean...I mean it is a powerful tool to help the people's herds.... of torax, that is. Please, ask me no more. I am afraid Salkind will punish me.@");
			}
			else
			{
				say("@I mean...I mean it is a powerful tool to help the people's herds.... of torax, that is. (Yes, she threatens to make the weather bad, or worse yet, send them to the Lurker, if they don't do her bidding.) Please, ask me no more. I am afraid Salkind will punish me.@");
			}
			add(["Salkind punishes you"]);
		
		case "Salkind punishes you" (remove):
			if (!hearTruthActive)
			{
				say("@Punished? No, no, not punished...er, pampered, yes, that's it, pampered by... Salkind. Please, friend, I do not wish to speak of it.@");
			}
			else
			{
				say("@Punished? No, no, not punished... er,pampered, yes that's it, pampered by...Salkind. (He is a horrid man who delights in tormenting me. He says lewd things and puts his hands on me. There is nothing I can do.)@");
			}
			converse(["bye"])
			{
			case "bye" (remove):
				sayGoodbye2(item);
				return;
			}
		
		case "tell me of Salkind" (remove):
			if (!hearTruthActive)
			{
				say("@He sets me to difficult tasks, then delights in tormenting me until I am barely able to complete them.@");
			}
			else
			{
				say("@He sets me to difficult tasks, then delights in tormenting me until I am barely able to complete them. (He says lewd things and puts his hands on me. There is nothing I can do.)@");
			}
			add(["what difficult tasks does he give you", "how does he torment you"]);
		
		case "what difficult tasks does he give you" (remove):
			if (!hearTruthActive)
			{
				say("@No, no, certainly not difficult, rather, challenging, That's it, he gives me challenging tasks. For instance, he will give me a very small brush and tell me to clean the floor of his room. Then he will arrive, his boots muddy from his walks along the shore, and track mud all over the floor I just cleaned. He then points the dirt out to me and chastises me for poor work, calling me a no good slackard.@");
			}
			else
			{
				// Same as above, no difference
				say("@No, no, certainly not difficult, rather, challenging, That's it, he gives me challenging tasks. For instance, he will give me a very small brush and tell me to clean the floor of his room. Then he will arrive, his boots muddy from his walks along the shore, and track mud all over the floor I just cleaned. He then points the dirt out to me and chastises me for poor work, calling me a no good slackard.@");
			}
		
		case "how does he torment you" (remove):
			if (!hearTruthActive)
			{
				say("@Perhaps 'torment' is too strong a word. He just sets me difficult tasks and then criticizes me harshly when I don't do them perfectly. Do you find that humorous?@");
				var choice = chooseFromMenu(["yes", "no"]);
				if (choice == "yes")
				{
					say("@Oh,...well...I guess perhaps some find it humorous. I must be back to my chores now.@");
				}
				else
				{
					say("@No? Really? Truly, I didn't find it very humorous either. But he finds it hilarious. So, I smile and try my best to stay out of his way. There is precious little I can do.@");
					add(["speak up about it", "slap him"]);
				}
			}
			else
			{
				say("@Perhaps 'torment' is too strong a word. He just sets me difficult tasks and then criticizes me harshly when I don't do them perfectly. Do you find that humorous?@");
				var choice = chooseFromMenu(["yes", "no"]);
				if (choice == "yes")
				{
					say("@Oh,...well...I guess perhaps some find it humorous. I must be back to my chores now.@");
				}
				else
				{
					say("@No? Really? Truly, I didn't find it very humorous either. But he finds it hilarious. So, I smile and try my best to stay out of his way. There is precious little I can do. (He says lewd things and puts his hands on me. There is nothing I can do.)@");
					add(["speak up about it", "slap him"]);
				}
			}
		
		case "speak up about it" (remove):
			if (!hearTruthActive)
			{
				say("@Oh, you are very nice, and I appreciate your concern, however, who would I speak to? Lady Mordea? No, she dotes on him. Darion? He simply would not believe me. No, my friend, I need this job. Speaking of keeping my job, I need to get back to work.@");
			}
			else
			{
				// Same
				say("@Oh, you are very nice, and I appreciate your concern, however, who would I speak to? Lady Mordea? No, she dotes on him. Darion? He simply would not believe me. No, my friend, I need this job. Speaking of keeping my job, I need to get back to work.@");
			}
			sayGoodbye2(item);
			break;
		
		case "slap him" (remove):
			if (!hearTruthActive)
			{
				say("@No, my friend, I have no desire to lose my job nor my head, for to strike the seneschal would be considered treason. I would be beheaded before the next morning. Well, I must get back to work now.@");
			}
			else
			{
				// Same
				say("@No, my friend, I have no desire to lose my job nor my head, for to strike the seneschal would be considered treason. I would be beheaded before the next morning. Well, I must get back to work now.@");
			}
			sayGoodbye2(item);
			break;
		
		case "have you met Devon" (remove):
			if (!devonInRule)
			{
				if (!araminaMet)
				{
					// First meeting
					say("@Devon? Well, I know him but I've never actually met him. But I think I'd like to.@");
					add(["you'd like to meet him", "you know of him"]);
				}
				else
				{
					// Subsequent
					// The tree has the same for met and not, but since met is set, perhaps repeat
					say("@Devon? Well, I know him but I've never actually met him. But I think I'd like to.@");
					add(["you'd like to meet him", "you know of him"]);
				}
			}
			else
			{
				if (!araminaMet)
				{
					// First meeting with Devon in rule
					av_1st_greet = "@What is your name?@";
					npc_1st_greet = "@I am Aramina, my friend. I work here in the palace for Devon. You're " + player_name + ", aren't you? Devon speaks of you often.@";
					add([yes_option]);
				}
				else
				{
					// Subsequent
					add(["it is good to see you smile, Aramina"]);
				}
			}
		
		case "it is good to see you smile, Aramina" (remove):
			if (devonInRule && araminaMet)
			{
				say("@I have you to thank for it. You did save Devon, didn't you?@");
				var choice = chooseFromMenu(["Yes, I did.", "Well, it was nothing, really."]);
				if (choice == "Yes, I did.")
				{
					say("@Oh, I can't thank you enough. He is so... so... well, just dreamy.@");
					add(["did you say ... 'dreamy'?"]);
				}
				else
				{
					say("@Oh, I can't thank you enough. He is so... so... well, just dreamy.@");
					add(["did you say ... 'dreamy'?"]);
				}
			}
		
		case "you'd like to meet him" (remove):
			say("@Once, when I was sent to the store to purchase something for Lady Mordea, he was there. I thought he had the nicest smile.@");
		
		case "you know of him" (remove):
			if (!devonInRule)
			{
				say("@I've seen him and I know his name. I rarely get to meet anyone outside.@");
				add(["I know Devon"]);
			}
		
		case "I know Devon" (remove):
			if (!devonInRule)
			{
				say("@You do? Oh, is he as nice as he looks? He has such a nice smile. And his eyes, they're blue aren't they? I really think he's handsome. Do you think that you might mention me to him next time you see him?@");
				var choice = chooseFromMenu(["Of course I will.", "I'm sorry, I can not."]);
				if (choice == "Of course I will.")
				{
					say("@That is very thoughtful of you. Now, I must get back to work.@");
				}
				else
				{
					say("@Oh ... well, I guess I understand, me being a lowly servant and all. He probably wouldn't be interested in me anyway. I'm just a silly girl for even dreaming it. Now, if you'll excuse me, sir, I must get back to work. There are floors yet to be scrubbed.@");
				}
			}
		
		case yes_option (remove):
			if (devonInRule && !araminaMet)
			{
				say("@Yes, I knew it was you. Did you really save him?@");
				var choice = chooseFromMenu(["Yes, I did.", "Well, it was nothing, really."]);
				if (choice == "Yes, I did.")
				{
					say("@Oh, I can't thank you enough. He is so... so... well, just dreamy.@");
					add(["did you say ... 'dreamy'?"]);
				}
				else
				{
					say("@Oh, I can't thank you enough. He is so... so... well, just dreamy.@");
					add(["did you say ... 'dreamy'?"]);
				}
			}
		
		case "did you say ... 'dreamy'?" (remove):
			if (devonInRule)
			{
				say("@Uh huh. He is the nicest man. He never torments me like that nasty old Salkind did. Why he even asked me to eat supper with him the other night ... in the dining room no less. Then we went for a walk outside and he picked a flower for me...ME! a simple servant girl...did you ever hear of anything so romantic? I just can't get over it ...@");
				add(["uhm, ... I've got to leave now."]);
			}
		
		case "uhm, ... I've got to leave now." (remove):
			if (devonInRule)
			{
				say("@...and those eyes. Did you ever see eyes like that? They're just so blue, I could get lost in them. I tell you ...@");
			}
		
		case "it is good to see you smile, Aramina" (remove):
			if (devonInRule && araminaMet)
			{
				say("@I have you to thank for it. You did save Devon, didn't you?@");
				var choice = chooseFromMenu(["Yes, I did.", "Well, it was nothing, really."]);
				if (choice == "Yes, I did.")
				{
					say("@Oh, I can't thank you enough. He is so... so... well, just dreamy.@");
					add(["did you say ... 'dreamy'?"]);
				}
				else
				{
					say("@Oh, I can't thank you enough. He is so... so... well, just dreamy.@");
					add(["did you say ... 'dreamy'?"]);
				}
			}
		
		case "I'm looking for a dagger" (remove):
			if (toldDagger && !lothianDead)
			{
				if (!mordeaDead)
				{
					say("@A dagger? I know nothing of daggers. I am just a servant to the Lady.@");
					add(["I need help"]);
				}
				else
				{
					say("@A dagger? Hmmm, I saw a dagger once. Mordea kept it in a chest in her room. I have the key. Would you like it?@");
					var choice = chooseFromMenu(["Yes!", "No, thank you anyway."]);
					if (choice == "Yes!")
					{
						say("@My, it must be an important dagger for you to get that excited over it. Oh well, it always made me feel most uneasy. Well, here is the key.@");
						//to do usecode func to give key to avatar
					}
					else
					{
						say("@Suit yourself.@");
					}
				}
			}
		
		case "I need help" (remove):
			if (!mordeaDead)
			{
				say("@I am not surprised by that, m'lord. Many people are in need of help these days.@");
				add(["others are in need of help"]);
			}
		
		case "others are in need of help" (remove):
			if (!mordeaDead)
			{
				if (!hearTruthActive)
				{
					say("@Not due to Lady Mordea, mind you. I-I'm certain that anyone out there who suffers or is hungry is in such a state due to their own laziness.@");
				}
				else
				{
					// Same
					say("@Not due to Lady Mordea, mind you. I-I'm certain that anyone out there who suffers or is hungry is in such a state due to their own laziness.@");
				}
			}
		
		case "are you certain" (remove):
			if (!mordeaDead)
			{
				if (!hearTruthActive)
				{
					say("@Yes, mmm... Look, I do not want to get into any trouble, m'lord. Please, do not ask me to do anything that might cause me to anger the Lady.@");
					add(["you won't get into trouble", "never mind"]);
				}
				else
				{
					// Same
					say("@Yes, mmm... Look, I do not want to get into any trouble, m'lord. Please, do not ask me to do anything that might cause me to anger the Lady.@");
					add(["you won't get into trouble", "never mind"]);
				}
			}
		
		case "you won't get into trouble" (remove):
			if (!mordeaDead)
			{
				if (!hearTruthActive)
				{
					say("@Ohh, I do not know why, but I am going to trust you. Mordea keeps a very special dagger in a locked chest. You will find the chest in a small closet near her bed.@");
					add(["it's in a chest"]);
				}
				else
				{
					// Same
					say("@Ohh, I do not know why, but I am going to trust you. Mordea keeps a very special dagger in a locked chest. You will find the chest in a small closet near her bed.@");
					add(["it's in a chest"]);
				}
			}
		
		case "never mind" (remove):
			if (!mordeaDead)
			{
				say("@Very well, thank you.@");
			}
		
		case "it's in a chest" (remove):
			if (!mordeaDead)
			{
				if (!hearTruthActive)
				{
					say("@Yes and I have the key. I will give you the key, but you must promise not to tell -anyone- where you got it.@");
					add(["I promise", "I can't promise that"]);
				}
				else
				{
					// Same
					say("@Yes and I have the key. I will give you the key, but you must promise not to tell -anyone- where you got it.@");
					add(["I promise", "I can't promise that"]);
				}
			}
		
		case "I promise" (remove):
			if (!mordeaDead)
			{
				if (!hearTruthActive)
				{
					say("@Very well, here it is.@");
					// TODO: Give key
					say("@Do what you will with it, but remember: You did not get that key from me.@");
				}
				else
				{
					// Same
					say("@Very well, here it is.@");
					// TODO: Give key
					say("@Do what you will with it, but remember: You did not get that key from me.@");
				}
			}
		
		case "I can't promise that" (remove):
			if (!mordeaDead)
			{
				if (!hearTruthActive)
				{
					say("@Well, then I can not give you the key. Farewell.@");
				}
				else
				{
					// Same
					say("@Well, then I can not give you the key. Farewell.@");
				}
			}
		
		case "what do you know of treasure" (remove):
			if (toldOfTreasure)
			{
				say("@Only what I've heard from Orlok. And no one can believe what he says. Though, now that I think about it, I heard Salkind mention something about a magic hammer that he wanted to find.@");
				add(["what did Salkind say"]);
			}
		
		case "what did Salkind say" (remove):
			if (toldOfTreasure)
			{
				say("@Oh, he said he was going to get a couple of strong men to dig for treasure they heard about from Orlok. I can't imagine why they would want to do that. Everyone knows you can't trust Orlok's stories. But, I guess Salkind did.@");
				add(["did he say where"]);
			}
		
		case "did he say where" (remove):
			if (toldOfTreasure)
			{
				say("@I don't remember exactly, something about a stand of mushrooms to the south of town. Wait, don't tell me you are going chasing after one of Orlok's stories!@");
				add(["yes, I believe there is treasure there"]);
			}
		
		case "yes, I believe there is treasure there" (remove):
			if (toldOfTreasure)
			{
				if (!hearTruthActive)
				{
					say("@If there was treasure there to be found, Salkind would have found it, he is just that kind of a lucky weasel. But I know he didn't find anything for he came back with his robes ripped and in a foul temper which I felt the brunt of for several days.@");
				}
				else
				{
					say("@If there was treasure there to be found, Salkind would have found it, he is just that kind of a lucky weasel. But I know he didn't find anything for he came back with his robes ripped and in a foul temper which I felt the brunt of for several days. I think it had to do with the dangerous beasts that live in the wilds.@");
					add(["dangerous beasts"]);
				}
			}
		
		case "dangerous beasts" (remove):
			if (toldOfTreasure && hearTruthActive)
			{
				say("@Oh yes, I heard several of the men who went with Salkind talking about trolls and such they encountered. If you must go, please, be careful.@");
			}
		
		case "what magic hammer" (remove):
			if (toldOfTreasure)
			{
				say("@You know, the one Orlok says his great-great-great-granpappy fought off the water Titan with. I think Orlok would give his great-great-great-granpappy credit with creating this world, if he could.@");
			}
		
		case "bye" (remove):
			npc_goodbye = "@Thank you, sir.@";
			avatar_goodbye = [];
			sayGoodbye(item, npc_goodbye, avatar_goodbye);
			break;
		}
	}
}