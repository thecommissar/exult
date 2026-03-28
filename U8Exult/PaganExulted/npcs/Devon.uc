//NPC template by agentorangeguy


void Devon object# (0x4ea) () //replace with name and number from ES
{

	var party = UI_get_party_list();
	var player_name = getAvatarName();
	var polite_title = getPoliteTitle();
	var hour = UI_game_hour();
	var partynum = UI_get_array_size(party);
	var bark;
	var player_is_female = UI_is_pc_female();
	var greeting; //When addressing party as plural or singular
	var avatar_bark;
	var npc_bark;
	var time_of_day = timeFunction(hour);
	var schedule = UI_get_schedule_type(item); //use for schedule specific convos
	var current_schedule = schedule; 
	
	//variables to store initial and later greetings
	var av_1st_greet;
	var npc_1st_greet;
				
	var av_2nd_greet;
	var npc_2nd_greet;	
	
	var avatar_goodbye;
	var npc_goodbye;
				
	
	//Flags used for conversation flags if you need something specific to happen. rename "example" to whatever 
	// use PETRA, SI_ZOMBIE, FREEZE, NAKED, POLYMORPH
	var example = UI_get_item_flag(item, SI_ZOMBIE);
	
	
	//READ flag used to initiate conversations via TALK
	var started_talking = UI_get_item_flag(item, READ);


	//if you need conversations to change depending on if Avatar is M/F
	if (player_is_female) //
	{
	//	pronoun = "  ";
	//	title = "madame";
	}
	else 
	{
	//	pronoun = " ";
	//	title = " ";
	}
	
	//determine single/plural greeting based on party size - change as needed
	if (partynum > 1)
		greeting = "friends"; 
	else 
		greeting = "friend"; //Avatar is solo
	
	
	//to initiate "SI" style conversations
	if (event == DOUBLECLICK)
	{
		//Avatar and NPC greeting barks
		av_1st_greet = "@Avatar Opening bark.@";
		npc_1st_greet = "@NPC opening bark@";
				
		av_2nd_greet  = "@Avatar 2nd greeting bark@"; 
		npc_2nd_greet = "@NPC 2nd greeting bark@";	
		
		//call convo script
		startConvo(item, av_1st_greet, npc_1st_greet, av_2nd_greet, npc_2nd_greet); 
	}
	
	if (started_talking)
	{
		//reset schedule for after convo
		UI_run_schedule(item);
		
	
		if (!UI_get_item_flag(item, MET))
		{
			item.say("Usually a description of the npc.");
			item.say("@Initial conversation greetings, add more as necessary.@");
		
			
			UI_set_item_flag(item, MET);
		}
		else //already met
			item.say("@already met dialogue@");

		
		//standard conversation options - add more if you want them to start out with options
		var options = ["who are you?", "goodbye"];
		
		
	/////////////////////////////////////////////////////////////////////
	// Main conversation thread
	/////////////////////////////////////////////////////////////////////
		
		converse(options)
		{
			case "who are you?"(remove): 
				say("@I am Devon, my strange friend. And I am glad to see you are feeling better, " + player_name + ".@");
				add(["how did you know my name?", "where am I?"]); 

			case "how did you know my name?"(remove): 
				say("@I am sorry. I did not mean to pry, but when I found you, I knew not who you were. I am afraid I read through your logbook and discovered your name. Please forgive me.@");
				
			case "where am I?"(remove): 
				say("@Why, on the shore, friend.@");
				add(["shore of what?"]); 

			case "shore of what?"(remove): 
				say("@The shore of Tenebrae, of course, upon the Sea of Rains.@");
				add(["Sea of Rains?", "Tenebrae?"]); 

			case "Sea of Rains?"(remove): 
				say("@Obviously you don't spend time away from the city. The story goes that the rains are quite great the farther you go from the shore. It is supposed to have something to do with Mordea's powers. Part of her role as ruling Tempest is to control the rain over the city.@");
				
			case "Tenebrae?"(remove): 
				say("@Aye, Tenebrae, the City of Eternal Twilight. They say you'll never find a more lovely place, and I do not disagree, save for one place. But I will say this, the farther I am from the Lady, the better I feel.@");
				add(["where are you from?"]); 

			case "where are you from?"(remove): 
				say("@I come from a distant island myself. I can tell by your questions that you are not from this land. Perhaps you, too, come from far away.@");
				add(["yes, I am from far away."]); 

			case "yes, I am from far away."(remove): 
				say("@I suspected as much, my friend, for your questions are most unusual. I must confess that I'm but a simple fisherman, and a poor source of information about city ways and such. When you get to town, visit Bentic, in the Library. My friend knows practically all there is to know about our land and its people.@");
			

			case "who is the lady?"(remove): 
				say("@You mean Lady Mordea. She is the Tempest ruler of the city. Others call her a tyrant. I did not agree with that opinion, until recently.@");
				add(["what changed your mind?"]); 

			case "what changed your mind?"(remove): 
				say("@Lately, the Lady has taken to eliminating dissenters. She has them executed — beheaded on the docks. At first no one was killed but criminals, but soon, anyone who showed disagreement was put to the block. I fear for the freedom of the people.@");
				add(["what happened to me?"]); 

			case "what happened to me?"(remove): 
				say("@I am unsure, my friend. I found your water-logged body in the deeps of Lurker's domain. What happened before remains a mystery, I discovered you in one of my nets while pulling them in.@");
				add(["the lurker's domain?"]); 

			case "the lurker's domain?"(remove): 
				say("@Aye, the sea. You were drowning in it, my friend. Any longer in it would not only have meant death, but then you would have had to walk the ocean floor for eternity to fulfill the Pact with Lithos.@");
				
			case "goodbye":
				say("@Farewell, friend " + player_name + ". Know that you are welcome to stay with me for as long as you need. My food and provisions are yours until you wish to head for the city. Be careful in your travels, for I fear you will encounter much violence.@");

				//departing barks
				avatar_goodbye = "@Safe travels!@";
				npc_goodbye = "@Take care, my friend.@";

				//function that is called, do not change this:
				sayGoodbye(item, npc_goodbye, avatar_goodbye);
				break;
		}

	}                               
}
