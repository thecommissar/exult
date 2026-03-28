//NPC template by agentorangeguy


void Template object# (0x000) () //replace with name and number from ES
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
		var options = ["name", "job", "bye"];
		
		
	/////////////////////////////////////////////////////////////////////
	// Main conversation thread
	/////////////////////////////////////////////////////////////////////
		converse(options)
		{
			case "name"(remove): 
				say("@blank@*");
				say("@blank@");

			case "job"(remove):
				say("@blank@");
				add(["blank"]); // If new conversation topics are opened

			case "blank"(remove): 
				say("@blank@*");
				say("@blank@");
				add(["blank"]); 
				
			case "blank"(remove): 
				say("@blank@*");
				say("@blank@");
				add(["blank"]); 


			case "blank"(remove): 
				say("@blank@*");
				say("@blank@");
				add(["blank"]); 
				
			case "blank"(remove): 
				say("@blank@*");
				say("@blank@");
				add(["blank"]); 

			case "blank"(remove): 
				say("@blank@*");
				say("@blank@");
				add(["blank"]); 
				
			case "blank"(remove): 
				say("@blank@*");
				say("@blank@");
				add(["blank"]); 


					
			case "bye":
				say("@Goodbye!@");  //if you want the npc to say something before leaving, otherwise delete for barks only
				
				//departing barks
				avatar_goodbye = "@avatar goodbye bark@";
				npc_goodbye = "@npc goodbye bark@";
				
				//function that is called, do not change this:
				sayGoodbye(item, npc_goodbye, avatar_goodbye);
				break;
	
		}                               
	}
}