//NPC template by agentorangeguy


void boatmanBuc object# (0x4ee) () //replace with name and number from ES
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
		npc_1st_greet = "@Why walk, when you can ride?@";
				
		av_2nd_greet  = "@Avatar 2nd greeting bark@"; 
		npc_2nd_greet = "@I make a special trip just for you, same low price@";	
		
		//call convo script
		startConvo(item, av_1st_greet, npc_1st_greet, av_2nd_greet, npc_2nd_greet); 
	}
	
	if (started_talking)
	{
		//reset schedule for after convo
		UI_run_schedule(item);
		
	
		if (!UI_get_item_flag(item, MET))
		{
			item.say("You see a cheerful man calling out to you.");
			item.say("@Why walk, when you can ride? Buc asks, with a grin.@");
			// Need to add Kilandra dialogue here
			
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
				say("@The name's Buc, stranger.@ He nods.");

			case "job"(remove):
				say("@I run this little ferry up and down Morgaelin's coast, she's my first and dearest love.@ Buc laughs."); // Add remark by kilandra here, if she's in party
				add(["ferry"]); 

			case "ferry"(remove): 
				say("@Oh, aye. I've got plenty of history on the seas. Nowadays I love to get people where they need to go. You'll be safe with me. Want a ride?@");
				add(["history"]); 
				add(["ride"]);
				add(["safe"]);
				
			case "history"(remove): 
				say("@Oh, I used to raise all kinds of titan's ire out of Vengeance Bay. Those were the days.@");
				add(["Vengance Bay"]); 

			case "Vengance Bay"(remove): 
				say("@Don't know that I'm willing to discuss that with a stranger. Come back when yer a bit more seasoned, hey?@"); 
				
			case "safe"(remove): 
				say("@Aye, I stay close to the shore so the Lurker won't get me. Plus a lil' shortcut or two.@");
				add(["get me"]); 

			case "get me"(remove): 
				say("@Aye, she'll never catch me. That lovely fella Devon taught me how to swim, so you know I'm fast in the water.@");
				
			case "ride"(remove): 
				say("@Where would you like to go?@"); // Need to add options for Tenebrae & Stone Cove // Need dialogue choice
				var travel_destination = chooseFromMenu; 


					
			case "bye":
				say("@Come back any time!@");  //if you want the npc to say something before leaving, otherwise delete for barks only
				
				//departing barks
				avatar_goodbye = "@avatar goodbye bark@";
				npc_goodbye = "@Come back any time@";
				
				//function that is called, do not change this:
				sayGoodbye(item, npc_goodbye, avatar_goodbye);
				break;
	
		}                               
	}
}