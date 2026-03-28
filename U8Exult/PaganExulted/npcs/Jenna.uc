void Jenna object#(0x4f8) ()
{
	// TODO: Fix old maid conversation - "An old maid?" option causes Jenna to get angry even though she brought up the topic herself (in "An old maid?" case statements)
	
	///////////
	// SETUP //
	///////////
	var npc = item;
	var party = UI_get_party_list();
	var player_name = getAvatarName();
	UI_error_message("DEBUG: player_name retrieved = " + player_name);
	var player_intro = "My name is " + player_name + ".";
	UI_error_message("DEBUG: player_intro = " + player_intro);
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
	
	// Flag setup
	var hydrosFree = gflags[HYDROS_FREE];
	var hasHeart = gflags[HAS_HEART];
	var jennaMet = UI_get_item_flag(item, MET);
	var jennaName = gflags[JENNA_NAME];
	var jennaJob = gflags[JENNA_JOB];
	var jennaPissed = gflags[JENNA_PISSED];
	var havAvaName = gflags[HAV_AVA_NAME];
	var barmaidForNow = gflags[BARMAID_FOR_NOW];
	var cyrrusMet = gflags[CYRRUS_MET];
	var darionMet = gflags[DARION_MET];
	var orlokMet = gflags[ORLOK_MET];
	var toldGhostStory = gflags[TOLD_GHOST_STORY];
	var jennaGhostStory = gflags[JENNA_GHOST_STORY];
	var mythranScrolls = gflags[MYTHRAN_SCROLLS];
	var sendJennaToLunch = gflags[SEND_JENNA_TO_LUNCH];

	UI_error_message("=====JENNA FLAGS=====");
	UI_error_message("hydrosFree flag is: " + hydrosFree);
	UI_error_message("hasHeart flag is: " + hasHeart);
	UI_error_message("jennaMet flag is: " + jennaMet);
	UI_error_message("jennaName flag is: " + jennaName);
	UI_error_message("jennaJob flag is: " + jennaJob);
	UI_error_message("jennaPissed flag is: " + jennaPissed);
	UI_error_message("havAvaName flag is: " + havAvaName);
	UI_error_message("barmaidForNow flag is: " + barmaidForNow);
	UI_error_message("=====JENNA FLAGS=====");
	
	/////////////////
	// BARK SETUP //
	////////////////	
	if (event == PROXIMITY)
	{
		var barks = ["@These torax smell terrible.@", "@I wish I could go adventuring.@", "@Another day in the tavern...@", "@My father will never understand me.@", "@This sword is my pride and joy.@"];
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
		UI_error_message("jennaMet: " + jennaMet + ", jennaPissed: " + jennaPissed + ", hasHeart: " + hasHeart);
		
		// Set default greetings (first meeting)
		av_1st_greet = [];
		npc_1st_greet = "@Hello.@";
		
		av_2nd_greet = "@Hello, Jenna.@";
		npc_2nd_greet = [];
		
		// Override based on conditions
		if (hasHeart)
		{
			UI_error_message("hasHeart is true, override greeting");
			av_1st_greet = "@Good day to you, Jenna.@";
			npc_1st_greet = "@What do you mean, 'good day'?! Can you not see what is happening? The dead have left their graves and are walking the streets of Tenebrae! Darion needs my sword, I have no time to chat now!@";
		}
		else if (jennaPissed)
		{
			UI_error_message("jennaPissed is true, override greeting");
			av_1st_greet = [];
			npc_1st_greet = "@You're lucky I don't skewer you where you stand.@";
		}
		else if (jennaMet)
		{
			UI_error_message("jennaMet is true, setting subsequent meeting greetings");
			// Vary greetings for subsequent meetings
			// Note: startConvo uses av_2nd_greet/npc_2nd_greet when MET flag is set
			var mood = UI_get_random(10);
			if (mood < 5)
			{
				if (havAvaName)
				{
					npc_2nd_greet = "@Well, hello again, " + player_name + ".@";
				}
				else
				{
					npc_2nd_greet = "@Good to see you, friend.@";
				}
			}
			else
			{
				if (havAvaName)
				{
					npc_2nd_greet = "@Good to see you, " + player_name + ".@";
				}
				else
				{
					npc_2nd_greet = "@Good to see you, friend.@";
				}
			}
		}
		else
		{
			UI_error_message("First meeting - using default greetings");
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
			item.say("@What do you mean, 'good day'?! Can you not see what is happening? The dead have left their graves and are walking the streets of Tenebrae! Darion needs my sword, I have no time to chat now!@");
			gflags[SEND_JENNA_TO_LUNCH] = true;
			sayGoodbye2(item);
			return;
		}
		else
		{
			// Fallback greeting description
			item.say("The strong-willed barmaid looks at you expectantly, one hand resting on the hilt of her sword.");
		}

		//END CONDITIONALS
		UI_error_message("complete started talking conditionals");
		
		/////////////////////////////
		// HANDLE INITIAL EXCHANGE //
		/////////////////////////////
		
		var is_first = !jennaMet;
		
		UI_set_item_flag(item, MET);
		
		var options = [];
		UI_error_message("Building options, jennaName: " + jennaName + ", jennaJob: " + jennaJob + ", jennaMet: " + jennaMet + ", jennaPissed: " + jennaPissed);
		
		// Build initial options based on state
		if (jennaPissed)
		{
			// Angry Jenna - limited options
			options = ["I am sorry if I upset you.", "Just try it!", "bye"];
			UI_error_message("Options set for jennaPissed");
		}
		else if (!jennaName)
		{
			// First meeting - only ask name
			options = ["What is your name?", "bye"];
			UI_error_message("Options set for first meeting");
		}
		else
		{
			// Know her name - add main conversation options
			options = ["bye"];
			
			// Main conversation topics
			if (!havAvaName)
			{
				options = options & [player_intro];
			}
			options = options & ["That's a pretty name.", "What do you do?", "Why do you carry a sword?"];
			
			// Contextual options for repeat visits
			if (hydrosFree && !hasHeart)
			{
				options = options & ["What strange weather this is."];
			}
			
			if (toldGhostStory)
			{
				options = options & ["Orlok sure likes his tales."];
			}
			
			// Add service options
			options = options & ["I'd like something to drink, please.", "I'd like something to eat."];
			
			UI_error_message("Options set for repeat meeting");
		}
		
		UI_error_message("Initial options: " + UI_get_array_size(options) + " items");

		/////////////////////
		// CONVERSATION LOOP //
		/////////////////////
		
		converse (options)
		{
		//=================
		// ANGRY JENNA
		//=================
		case "I am sorry if I upset you." (remove):
			say("@I have a long memory for slights. It is only out of respect for Orlok that I will hold my temper.@");
			gflags[JENNA_PISSED] = false;
			remove("Just try it!");
			add(["I'd like something to drink, please.", "I'd like something to eat."]);
			
		case "Just try it!" (remove):
			say("@You animal! I will not disgrace Orlok's trust in me by fighting in his tavern. Now get out!@");
			sayGoodbye2(item);
			break;
			
		//=================
		// FIRST MEETING - NAME
		//=================
		case "What is your name?" (remove):
			say("@My name is Jenna, and yours?@");
			gflags[JENNA_NAME] = true;
			add(["That's a pretty name.", "What do you do?", "Why do you carry a sword?", player_intro]);
			
		case player_intro (remove):
			say("@Well met, " + player_name + ".@");
			gflags[HAV_AVA_NAME] = true;
			
		case "That's a pretty name." (remove):
			say("@If it is a lady's company you are after, then I am afraid you have come to the wrong establishment.@");
			
		//=================
		// JOB BRANCH
		//=================
		case "What do you do?" (remove):
			say("@Well, for now I'm a barmaid. Can I get you a drink or something to eat?@");
			gflags[JENNA_JOB] = true;
			add(["I'd like something to drink, please.", "I'd like something to eat."]);
			if (!barmaidForNow)
			{
				add("A barmaid for now?");
			}
			
		case "A barmaid for now?" (remove):
			say("@Yes. It was the only job I could find at short notice. What I really want to do is go adventuring, like you. Oh, how I would like to see something of the world beyond this smelly village.@");
			gflags[BARMAID_FOR_NOW] = true;
			add(["Smelly village?", "Job at short notice?", "See the world?"]);
			
		case "Smelly village?" (remove):
			say("@Yes, ugh. Can you not smell it? The rancid odor of fish combined with the nasty smell of those stupid torax. Sometimes I think that even if I left the smell would still be in my blood. It's terrible.@");
			
		case "Job at short notice?" (remove):
			say("@Well, see, my father wanted me married. He seems to think that a woman can't support herself. She must have a husband to make her a complete person. Well, just to prove to him I could do it, I got this job. It's not much, but it got me out of the house.@");
			
		case "See the world?" (remove):
			say("@Ah, what I wouldn't give to see it all, but I can't.@");
			add(["What is there to see?", "Why can't you see it?"]);
			
		case "What is there to see?" (remove):
			say("@Why, just the whole world. I've heard there are sorcerers who can call up the forces of fire and ancient ruins where hordes of treasure await anyone brave enough to fight the evil creature guarding it.@");
			
		case "Why can't you see it?" (remove):
			say("@Because I am a woman, so they say.@");
			add("Why can't a woman adventure?");
			
		case "Why can't a woman adventure?" (remove):
			say("@There are those who say only young men are interested in adventuring, and women are only interested in cooking and shopping. Well, I say they are wrong! There mayn't be many of us, but we are here. Maybe someday they will realize it. Until then, how about that drink?@");
			
		//=================
		// DRINKS MENU
		//=================
		case "I'd like something to drink, please." (remove):
			say("@We have Tenebraean Ale, Blackwine, Hurricanes, Breath O'Spirit and Cloven Hoof.@");
			
			converse(["Tenebraean Ale", "Black Wine", "Hurricane", "Breath O'Spirit", "Cloven Hoof", "Nothing, thank you."])
			{
			case "Tenebraean Ale" (remove):
				say("@Our Tenebraean ale is the finest. It'll costs one glassy black.@");
				// TODO: Implement purchasing
				var purchase = chooseFromMenu(["Here is the amount.", "Never mind, thank you."]);
				if (purchase == "Here is the amount.")
				{
					say("@Thanks. Enjoy.@");
					sayGoodbye2(item);
					break;
				}
				else
				{
					say("@Let me know if you change your mind.@");
				}
				
			case "Black Wine" (remove):
				say("@The Blackwine is my favorite. It costs three obsidians.@");
				// TODO: Implement purchasing
				var purchase = chooseFromMenu(["Here is the amount.", "Never mind, thank you."]);
				if (purchase == "Here is the amount.")
				{
					say("@Thanks. Enjoy.@");
					sayGoodbye2(item);
					break;
				}
				else
				{
					say("@Let me know if you change your mind.@");
				}
				
			case "Hurricane" (remove):
				say("@Don't drink too many of these, they're quite potent. One costs two ladies.@");
				// TODO: Implement purchasing
				var purchase = chooseFromMenu(["Here is the amount.", "Never mind, thank you."]);
				if (purchase == "Here is the amount.")
				{
					say("@Thanks. Enjoy.@");
					sayGoodbye2(item);
					break;
				}
				else
				{
					say("@Let me know if you change your mind.@");
				}
				
			case "Breath O'Spirit" (remove):
				say("@Oh, I think Breath O'Spirit is really an acquired taste. But if you insist, it'll be two ladies.@");
				// TODO: Implement purchasing
				var purchase = chooseFromMenu(["Here is the amount.", "Never mind, thank you."]);
				if (purchase == "Here is the amount.")
				{
					say("@Thanks. Enjoy.@");
					sayGoodbye2(item);
					break;
				}
				else
				{
					say("@Let me know if you change your mind.@");
				}
				
			case "Cloven Hoof" (remove):
				say("@Ah, the finest in the house. I see you have good taste. Our Cloven Hoof is five smooth black chips.@");
				// TODO: Implement purchasing
				var purchase = chooseFromMenu(["Here is the amount.", "Never mind, thank you."]);
				if (purchase == "Here is the amount.")
				{
					say("@Thanks. Enjoy.@");
					sayGoodbye2(item);
					break;
				}
				else
				{
					say("@Let me know if you change your mind.@");
				}
				
			case "Nothing, thank you." (remove):
				say("@Well, call if you change your mind.@");
				break;
			}
			// After drinks menu, return to main conversation
			add(["I'd like something to drink, please.", "I'd like something to eat."]);
			
		//=================
		// FOOD MENU
		//=================
		case "I'd like something to eat." (remove):
			say("@Well, we have a good kitchen here. We serve fish, Toraxen Jerky, Kith filet, bread, mushrooms, tubers and Toraxen cheese.@");
			
			converse(["fish", "Toraxen jerky", "Kith filet", "bread", "mushrooms", "tubers", "Toraxen cheese", "Nothing, thank you."])
			{
			case "fish" (remove):
				say("@It's very fresh. Kilandra just brought it in today. It will cost you only one obsidian.@");
				// TODO: Implement purchasing
				var purchase = chooseFromMenu(["Here is the amount.", "Never mind, thank you."]);
				if (purchase == "Here is the amount.")
				{
					say("@Thanks. Enjoy.@");
					sayGoodbye2(item);
					break;
				}
				else
				{
					say("@Let me know if you change your mind.@");
				}
				
			case "Toraxen jerky" (remove):
				say("@Hmmm, planning a long trip? It's a bit tough, but travels well. It is 3 stones a pound.@");
				// TODO: Implement purchasing
				var purchase = chooseFromMenu(["Here is the amount.", "Never mind, thank you."]);
				if (purchase == "Here is the amount.")
				{
					say("@Thanks. Enjoy.@");
					sayGoodbye2(item);
					break;
				}
				else
				{
					say("@Let me know if you change your mind.@");
				}
				
			case "Kith filet" (remove):
				say("@Ah, you do have good taste. Our filet of Kith is the finest in the land. It only costs 8 blacks.@");
				// TODO: Implement purchasing
				var purchase = chooseFromMenu(["Here is the amount.", "Never mind, thank you."]);
				if (purchase == "Here is the amount.")
				{
					say("@Thanks. Enjoy.@");
					sayGoodbye2(item);
					break;
				}
				else
				{
					say("@Let me know if you change your mind.@");
				}
				
			case "bread" (remove):
				say("@It was baked fresh just today. You can have a serving for 1 stone.@");
				// TODO: Implement purchasing
				var purchase = chooseFromMenu(["Here is the amount.", "Never mind, thank you."]);
				if (purchase == "Here is the amount.")
				{
					say("@Thanks. Enjoy.@");
					sayGoodbye2(item);
					break;
				}
				else
				{
					say("@Let me know if you change your mind.@");
				}
				
			case "mushrooms" (remove):
				say("@The Blue Mushrooms are my favorite. We can only serve them at this time because this is the only time they are in season. They will cost you only a single coin.@");
				// TODO: Implement purchasing
				var purchase = chooseFromMenu(["Here is the amount.", "Never mind, thank you."]);
				if (purchase == "Here is the amount.")
				{
					say("@Thanks. Enjoy.@");
					sayGoodbye2(item);
					break;
				}
				else
				{
					say("@Let me know if you change your mind.@");
				}
				
			case "tubers" (remove):
				say("@I don't know if I would eat them alone. They are very good with the filet. But if you wish, you may have them for one glassie.@");
				// TODO: Implement purchasing
				var purchase = chooseFromMenu(["Here is the amount.", "Never mind, thank you."]);
				if (purchase == "Here is the amount.")
				{
					say("@Thanks. Enjoy.@");
					sayGoodbye2(item);
					break;
				}
				else
				{
					say("@Let me know if you change your mind.@");
				}
				
			case "Toraxen cheese" (remove):
				say("@Not everyone likes Toraxen cheese. It has a bit of a pungent flavor. It costs 1 black stone.@");
				// TODO: Implement purchasing
				var purchase = chooseFromMenu(["Here is the amount.", "Never mind, thank you."]);
				if (purchase == "Here is the amount.")
				{
					say("@Thanks. Enjoy.@");
					sayGoodbye2(item);
					break;
				}
				else
				{
					say("@Let me know if you change your mind.@");
				}
				
			case "Nothing, thank you." (remove):
				say("@If you change your mind, let me know.@");
				break;
			}
			// After food menu, return to main conversation
			add(["I'd like something to drink, please.", "I'd like something to eat."]);
			
		//=================
		// SWORD BRANCH
		//=================
		case "Why do you carry a sword?" (remove):
			say("@Because it is mine, and I'll have you know I'm not afraid to use it.@");
			add("You know how to use a sword?");
			
		case "You know how to use a sword?" (remove):
			say("@Yes, this blade has sent more than one man running for his life!@");
			add(["You have killed men?", "It is a nice blade."]);
			
		case "You have killed men?" (remove):
			say("@Only one or two. Most know to stay clear of me.@");
			add("Why do they stay clear?");
			
		case "Why do they stay clear?" (remove):
			say("@They stay clear because I do not want them around. My father calls them 'suitors', I call them a nuisance.@");
			add("Suitors?");
			if (darionMet)
			{
				add("I met your father.");
			}
			else
			{
				add("Who is your father?");
			}
			
		case "Suitors?" (remove):
			say("@You know, male callers. They show up here and hang around like mooncalves. One in particular was bad. His name was Cyrrus.@");
			if (cyrrusMet)
			{
				add("I met Cyrrus.");
			}
			else
			{
				add("Tell me of Cyrrus.");
			}
			
		case "I met Cyrrus." (remove):
			say("@Oh, he is a dull thing, isn't he? All he ever used to talk about were those darn torax. He wanted me to marry him and live in the hills and be a herdsman's wife. I was certainly glad when he went to Argentrock.@");
			add("Why did he go to Argentrock?");
			
		case "Tell me of Cyrrus." (remove):
			say("@He was a herdsman's son. He wanted to marry me and live in the hills tending torax. Now torax may be wonderful to him, but I think they are stupid and they smell. I was so glad when he went to Argentrock.@");
			add(["Why did he go to Argentrock?", "Where is Argentrock?"]);
			
		case "Why did he go to Argentrock?" (remove):
			say("@They say he has some talent for healing. He always did feel closer to Stratos than he did to Hydros, though he didn't tell his family that. They would have been very angry. Well, I don't know if he ever became a healer, I'm just glad he is gone.@");
			
		case "Where is Argentrock?" (remove):
			say("@It is quite a way from here. I'm not exactly sure, but I know you must travel through the cemetary to get there.@");
			
		case "I met your father." (remove):
			say("@Yes, he is quite a man. He tries to marry me off to everyone who comes through town. He's afraid I'm going to be an old maid.@");
			add("An old maid?");
			
		case "Who is your father?" (remove):
			say("@Darion, the Arms Master and Captain of the Palace Guard, is my father. He thinks I am going to be an old maid and tries to marry me off to everyone who comes around.@");
			add("An old maid?");
			
		case "An old maid?" (remove):
			say("@I am NOT an old maid! How dare you say that?! You are just like my father! I can't kill him, but I can you and I just might. Now, get out while I still feel civil!@");
			gflags[JENNA_PISSED] = true;
			sayGoodbye2(item);
			break;
			
		case "It is a nice blade." (remove):
			say("@Yes, it is a fine blade, a wondrous blade. Have you ever seen finer?@");
			var blade_choice = chooseFromMenu(["yes", "no"]);
			if (blade_choice == "yes")
			{
				say("@You wretch! How dare you insult my grandfather's memory? You will pay for your disrespect! Now get out of my sight, before I decide to show you just how fine this blade is!@");
				gflags[JENNA_PISSED] = true;
				sayGoodbye2(item);
				break;
			}
			else
			{
				say("@It's all I have left from my grandfather. Before he died, he gave me this sword and told me to wear it with pride. And I always have.@");
				add("Where did you learn to wield it?");
			}
			
		case "Where did you learn to wield it?" (remove):
			say("@My father taught me. He always wanted a son, but all he got was me. So he taught me. He is determined to marry me off, though.@");
			
		//=================
		// CONTEXTUAL TOPICS
		//=================
		case "What strange weather this is." (remove):
			say("@I can't believe it. I've heard some fool somehow released Hydros and now our Tempest has no power to control the weather. It's even been said that Hydros is going to try to wash away the town!@");
			add(["Do they know who did it?", "I released Hydros."]);
			
		case "Do they know who did it?" (remove):
			say("@They are not sure. But when they do find out, it's going to be ugly. They probably will design some hideous torture for that person! Anyway, what can I get you?@");
			add(["I'd like something to drink, please.", "I'd like something to eat."]);
			
		case "I released Hydros." (remove):
			say("@Ha, ha, ha! I'm sorry, but I don't think -you- are the type to release a -Titan-! The thought is rather funny. Ha, ha, ha! Now, what can I get for you?@");
			add(["I'd like something to drink, please.", "I'd like something to eat."]);
			
		case "Orlok sure likes his tales." (remove):
			say("@You don't have to tell me. I've heard every one of them at least a thousand times. And let me tell you, they get bigger with each telling. Did he tell you the ghost story yet?@");
			var ghost_choice = chooseFromMenu(["Yes, he has.", "No, he hasn't."]);
			if (ghost_choice == "Yes, he has.")
			{
				say("@You know, of all his tales, that one is the only one that never changes when he tells it. I always wondered if there wasn't a grain of truth in it. Why, just the other night I heard my father, Darion, asking Orlok about that story. I don't know why, though. Anyway, what can I get you?@");
				gflags[JENNA_GHOST_STORY] = true;
				if (!mythranScrolls)
				{
					gflags[MYTHRAN_SCROLLS] = true;
				}
			}
			else
			{
				say("@Well, don't you worry, he will. He always does. It's one of his favorites. Now, what can I get for you?@");
			}
			add(["I'd like something to drink, please.", "I'd like something to eat."]);
			
		//=================
		// GOODBYE
		//=================
		case "bye" (remove):
			avatar_goodbye = [];
			npc_goodbye = "@Good day to you.@";
			sayGoodbye(item, npc_goodbye, avatar_goodbye);
			break;
		}
	}
}
