/* This script contains constants for each global flag used in the game. Fill them in as you go along! */

/* New flags */
/*Flags we do not want to use 
	//Flags we DON'T want to reset - 
	//global flag # 61 (learned password) so the portullius works
	//global flag # 442 - quenton seance
	//global flag # 749 Set when the Magic Storm spell is cast:
	//const int MAGIC_STORM_SPELL					= 0x02ED;
	//global flag # 30  Used the armageddon spell - const int CAST_ARMAGEDDON = 0x1E; 
*/


enum main_quest_flags
{
	MARCELINE_STORY = 1011,
	START_OF_GAME = 1016,
	
	//Mantras learned:
	LEARNED_MANTRA_VALOR = 1079,
	LEARNED_MANTRA_SACRIFICE = 1030,
	LEARNED_MANTRA_JUSTICE = 1031,
	LEARNED_MANTRA_COMPASSION = 1017, //Kenneth, Lady  Nan
	LEARNED_MANTRA_SPIRITUALITY = 1033,
	LEARNED_MANTRA_HONESTY = 1036,
	LEARNED_MANTRA_HUMILITY = 1037,
	LEARNED_MANTRA_HONOR = 1048,
	
	//Shrines freed: 

	SACRIFICE_FREED = 1027,
	COMPASSION_FREED = 1028,
	VALOR_FREED	= 1029,
	JUSTICE_FREED = 1032,
	SPIRITUALITY_FREED = 1034,
	HONOR_FREED = 1035,
	HUMILITY_FREED = 1038,
	HONESTY_FREED = 1039,

	//Used when you meditate at shrines so you don't get duplicate Karma
	MEDITATE_COMPASSION    = 1040,
	MEDITATE_VALOR		   = 1041,
	MEDITATE_HONESTY	   = 1042,
	MEDITATE_JUSTICE	   = 1043,
	MEDITATE_HUMILITY	   = 1044,
	MEDITATE_HONOR		   = 1045,
	MEDITATE_SPIRITUALITY  = 1046,
	MEDITATE_SACRIFICE	   = 1047,

	
	ASKED_NYSTUL_ABOUT_BOOK	 = 1050,
	ASKED_MARIAH_ABOUT_BOOK  = 1051,
	ASKED_NYSTUL_ABOUT_ORB	 = 1052,
	


	JOINED_THIEVES_GUILD	= 1150, 
	MARIAH_READ_TABLET 		= 1151, //Triggers convo about book of prophesies with Sin Vraal
	
	READ_GARGISH_SCROLL = 1188, //Set when double clicked John's scroll
	WEARING_AMULET_SUBMISSION = 1195, //checks to see if you are wearing the gargoyle amulet
	SUBMITTED_TO_DRAXINUSOM = 1194, 
	
	ASK_TO_SUBMIT 		= 1193, //valkadesh says to submit, you ask Naxatilor and Draxinosum
	
	
	PAPA_HAS_CUBE = 1200, //set by Myles or Mama when asked about cellar
	TOLD_ABOUT_CUBE = 1095, //set true when told about cube by Caretaker or visiting cyclops basement
							//and needing key
	
	
	//gargoyle shrine flags
	LEARNED_MANTRA_CONTROL = 1090,
	LEARNED_MANTRA_DILIGENCE = 1091,
	LEARNED_MANTRA_PASSION = 1092,

	START_CODEX_QUEST		= 1198, //given by Naxitilor
	FINAL_QUEST_GIVEN 		= 1197, //final codex quest by altar of singularity

	//determines which stones you put into the vortex cube
	MOONSTONE1				= 1150,
	MOONSTONE2				= 1151, 
	MOONSTONE3				= 1152,
	MOONSTONE4				= 1153,
	MOONSTONE5				= 1154,
	MOONSTONE6				= 1155,
	MOONSTONE7 				= 1156,
	MOONSTONE8				= 1157, 
	
	

	VORTEX_CUBE_FULL		= 1158, //set once all stones are put in
	HUMAN_LENS_PLACED		= 1159, 
	GARG_LENS_PLACED		= 1160





};

enum town_flags
{

//YEW
	
	LENORA_GAVE_LETTER = 1001,
	ASKEDABOUTPERMISSION = 1002,
	GOTJAILERSKEY = 1003,
	BOSKINCHILDREN = 1004,
	BOSKINPISSED = 1005,
	BOSKINCAVES = 1006,
	BOSKINLIES = 1007,
	BEN_FRIEND = 1008,
	FREEBOSKIN = 1009,
	BOSKINDENIED = 1010,
	LEARNED_ABOUT_NICODEMUS = 1013, //set by several npcs about "enchanter near Yew"
	
//Britain
	VIRTUE_STONES = 1011, //for Mandrake quest
	
	ASKEDARIANAABOUTRUNE = 1020,
	ASKED_THOLDEN_ABOUT_RUNE = 1015,
	ASKED_PARENTS_PERMISSION = 1016, //Anya
	LEARNED_RUNE_COMPASSION = 1018,
	MR_NOSE	= 0x371,

	BOUGHTTRIPLEXBOW = 1021,
	ASKEDABOUTTRIPLEXBOW = 1022, //Gwenno


//Skara Brae
	QUENTON_START = 1073, //quenton quest
	ASKED_LENORA_ABOUT_MURDER = 1110, //used in Michael / Quenton quest
	LEARNED_ABOUT_QUENTON =	1026, //set by Gideon when you learn what happened to open up convo flags on everyone else
	ASKEDGIDEONABOUTMARTA = 1026, //remove once Marta is fixed
	
	LEARNED_ABOUT_SEANCE = 1074, //learned from Dezana
	LEARNED_SEANCE = 1075,
	SEANCE_QUENTON = 0x01BA, //0442
	LEARNED_MICHAEL_NAME = 1076,
	MICHAEL_PISSED = 1077,
	MARNEY_SAVED = 1078,
	FAILED_QUENTON_QUEST = 1112,
	RINALDO_BACK = 1080,
	STARTED_INVESTIGATION = 1081,
	MARNEY_GONE = 1082, //set when you screw up and Marney left with Michael. Bad ending
	MICHAEL_AT_DOCKS = 1083, //
	READ_MICHAELS_SCROLL = 1084,
	QUENTON_MURDER_SOLVED = 1085,
	MICHAEL_TO_SKARA = 1086, //
	RENTHAR_TELLS_RINALDO = 1113, //Renthar tells Rinaldo of Michael's safehouse location. Will set a timer to move Michael 
	MICHAEL_CAPTURED	= 1114, //Michael is now at the cell awaiting his fate. Set when Renthar is with you and you kill Michael
	MICHAEL_TIMER_SET   = 1115,
	MARNEY_PISSED 		= 1116, //Marney was allowed to go with Michael by accident and holds a grudge against the Avatar
	RENTHAR_IN_PARTY	= 1117, //Renthar is in the party now, used to keep him from staying too long
	
	
//MINOC
	ASKED_SELGANOR_ABOUT_RUNE = 1054,
	LEARNED_STONES = 1055,
	JOINED_ARTISANS_GUILD = 1056,
	SELGANOR_GAVE_RUNE = 1057,
	LEARNED_ABOUT_BALLOONIST = 1058,  // where do I set this flag?!	
	
//Trinsic	
	LEARNED_WHITSABERS_SECRET = 1042, //Sandy?
	TALKEDTOHOMERABOUTMAP = 1043, //Homer
	WHITSABER_MAD = 1044,
	WHITSABER_KNOWS = 1045,
	WHITSABER_GAVE_MAP = 1046,
	KEEP_WHITSABERS_SECRET = 1047	
	

};


enum new_misc_flags
{
	
	/* Used for Gypsy schedules */
	GYPSY_TIMER_STARTED = 1111,
	DAY_ONE = 1103,
	DAY_TWO = 1104,
	DAY_THREE = 1105,
	DAY_FOUR = 1106,
	DAY_FIVE = 1107,
	DAY_SIX = 1108,
	DAY_SEVEN = 1109,
	
	ASK_ABOUT_DUCK = 1023,
	KADOR_SAD = 1024,	

	//Drudgeworth Quest
	READ_LEAFLET		= 1249,
	ASKED_PRIDGARM_ABOUT_DRUDGEY = 1250,
	ASK_ANDREA_ABOUT_DRUDGEY = 1251,
	HELP_DRUDGEWORTH = 1252, // set once you agree to help Drudgeworth after speaking to him in the mirror. Also sets Lucy convo flag on Chuckles
	CHUCKLES_WAITS = 1255, //set after you confront Chuckles about LUcy.  has him wait at 3am by mirror in Blue Boar
	CHUCKLES_CREMATED = 1253, //set when you cremate Chuckles body, so you can bring his ashes to Drudgeworth
	CHUCKLES_KILLED = 1254, //set when you script kill him in front of the mirror
	CHUCKLES_SECRET = 1255, //set when you "let Chuckles go", will open up convo option on LB
	
	
	
	GOTDUCK = 1025,
	
	ASKEDABOUTFREITAG = 0x372, //used to open up conversation with Gertan in Cove
	
	//flag to use Ankh as debugging tool
	DEBUG = 2047,

	IOLO_HATES_HORSEFLESH 	= 1161, //set once Iolo eats the horseflesh


	//INNKEEPER FLAGS
	INN_PEYTON = 1110,


	//DUNGEON FLAGS
	SWITCH_WRONG = 1087,
	SWITCH_WRONG_2 = 128,

	SWITCH_CONTROL = 1089,
	SWITCH_BASEMENT = 1095,
	
	SWITCH_TOMBKINGS =  1099, //used to remove barrier in tomb of kings when switch is flipped


//Gargoyles
	HALL_OF_KNOWLEDGE = 1196, //set when Naxatilor asks you to read the book of ritual
	READ_BOOK_RITUAL	= 1112, // for karma if you lie to Naxatilor
	SIXTH_MEMBER_LEAVES = 1110, 

	GET_HUMAN_LENS 		= 1195,
	MET_MONDAIN = 1197,
	MET_MINAX = 1198,
	MET_EXODUS = 1199,

	MET_ALTAR_SINGULARITY = 2222,


	MADE_BALLOON = 1096, //set by scroll code when balloon has been made

	BALLOON_IS_LANDED = 1093,
	LEARNED_ABOUT_FLYING = 1299,


	READ_BALLOON_PLANS = 1300,  //sets flag to ask weavers about silk bag/thread/cloth

	BRAWLING = 1111, //used for Bucs den brawling convos


	//Used in valor quest
	AVATAR_IS_SHERRY = 1096, 
	LEARNED_ABOUT_SHERRY = 1097, //when ask Lyssandra in Jhelom about rune
	GOT_VALOR_RUNE	= 1098,


		
	LEARNED_ABOUT_CAPT_JOHNE  = 1100, //set by Zoltan once you ask him of Silver Tablet
	LEARNED_ABOUT_TABLET = 1101,
	JOINED_OSS		= 1152, 
	ASK_JOIN_OSS		= 1153, //after join oss, can use again
	LEARNED_ABOUT_HYTHLOTH = 1154, 
	
	GAVE_MOLE_SHOVEL = 0x1071, //Empath abbey sidequest
	GLENGRAPES = 0x1072,

	

	GOT_ARMAGEDDON = 1251, //set when Armageddon spell received from Wisp
	GET_WISP_INFO = 1252, //set when Wisps ask for information, you can get the book of lost mantras
	WISPS_GAVE_GOLD = 1253, //Wisps either gave you information or gold

	JAANA_IN_PARTY = 1038,
	SHERRY_IN_PARTY = 1039,
	IOLO_IN_PARTY = 1053,
	ASK_KADOR_TRICKS = 1041,


	LEARNEDGYPSYSSTOLEMAP = 1049,
	REFUSED_WANDA_SEX	= 1050,
	ARTUROSIS = 1053, //set by Culham in Jhelom when asked about gypsy story
	WANDA_TIRED		= 1051,
	DURING_WANDA_CUTSCENE =  1052,
	ASKED_ABOUT_SACRIFICE_MANTRA = 1089,
	LENS = 1087, //Dale in Minoc makes Lens
	MET_ELAD	= 0x371, //bucs den 881
	LEONNA_IN_PARTY		= 0x372, //882
	LEODON_IN_PARTY		= 0x373, //883
	FENTRISSA_SOLD_OUT	= 0x374, //884

	LEARNED_ABOUT_GUILD	= 0x379, //886
	MET_CAPTAIN_JOHNE = 0x37A, //887
	GAVE_HOMER_STORMCLOAK = 0x37B, //888
	FIND_STORMCLOAK = 0x37C, //889
	//PETROPH_MAD	= 0x121,
	INN_DORIS	= 0x37D, //890 - true if rented room from Doris
	SEGGALLION_IN_PARTY	= 0x37E, //891
	LEARNED_OF_CAPT_JOHNE = 1115,


	TRAINED_WITH_LOUBET	= 894,
	SENTRI_IN_PARTY 	= 895,
	
 
	 //Lycaeum flags - set to randomize Quest books,
	BOOKS_ARE_RANDOMIZED = 1035,
	MANTRA_BOOK_PLACED = 1036, 
	OZ_SNILWITS_BOOKS_PLACED = 1027,
	FOUND_OZ_BOOK = 1030,
	 
	//Used for orb of the moons locations 
	FOUND_CONTROL = 1031,
	FOUND_PASSION = 1032, 
	FOUND_DILIGENCE = 1033,
	FOUND_SLAB = 1034
	

};



/* Original game flags */

//Who the player has met. BG used global flags for this because the Met flag didn't exist.
enum met_flags
{
//	MET_JULIA			= 0x1B,
	MET_LORD_BRITISH	= 0x98,
	MET_FINNIGAN		= 0x4C,
	MET_NYSTUL			= 0x99,
	MET_CHUCKLES		= 0x9A,
	MET_CANDICE			= 0xAA,
	MET_GORDON			= 0xBB,
	MET_GLADSTONE		= 0x110
};

//Flags used by the starting murder investigation quest
enum trinsic_murder_flags
{
//	GOT_CHRISTOPHERS_KEY		= 0x3C,
	GOT_TRINSIC_PASSWORD		= 0x3D,
	NEEDS_TRINSIC_PASSWORD		= 0x42,
	UNLOCKED_CHRISTOPHERS_CHEST	= 0x3E,

	KNOWS_ABOUT_CHRISTOPERS_ARGUMENT	= 0x3F,
	REFUSED_MURDER_INVESTIGATION		= 0x59,
	EXPECTED_TO_LOOK_IN_STABLES			= 0x5A,
	REPORTED_CHRISTOPHERS_KEY			= 0x48,
	CAN_GIVE_MURDER_REPORT				= 0x5B,
	STARTED_MURDER_REPORT				= 0x5D,
	LEARNED_ABOUT_CROWN_JEWEL			= 0x40,
	LEARNED_ABOUT_HOOK					= 0x43,
	FINISHED_MURDER_INVESTIGATION		= 0x44,
	WAITING_FOR_INVESTIGATION_PAYMENT	= 0x45
};

//Broken the tetrahedron generator that screws up magic. This affects most conversations with wizards.
const int BROKE_TETRAHEDRON = 0x03;

//Used the armageddon spell
const int CAST_ARMAGEDDON = 0x1E;


//Flags used in conversation with Lord British
enum lb_conversation_flags
{
	WESTON_FREED					= 0xCC,
	ASKED_LB_ABOUT_ORB							= 0xDD,
	ASKED_LB_ABOUT_MAGIC			= 0x66,
	LEARNED_ABOUT_BRITAIN_MURDER	= 0xD1, //allows you to ask Patterson about it
	ASKED_LB_ABOUT_HEAL				= 0xD3,
	LEARNED_ABOUT_BLACKROCK			= 0x65,	//allows you to ask Rudyom about it?
	ASKED_LB_ABOUT_GUARDIAN			= 0xD4,	//stops you ever asking him again (yes, plaster over those plot-holes)
	LB_REWARDED_FOR_FV				= 0x30D	//Received Lord British's reward for completing the Forge of Virtue
};

//Flags used in conversation with Julia
enum julia_conversation_flags
{
	ASKED_JULIA_TO_LEAVE			= 0x101,
	JULIA_IN_PARTY				= 0x108,
	KATRINA_IN_PARTY			= 0x121
};

//Flags used in Minoc conversations to do with the sawmill murder
enum minoc_murder_flags
{
	LEARNED_ABOUT_MINOC_MURDER		= 0x11F
};

//Flags used by the Owen's Monument quest
enum owen_monument_flags
{
//	COMPLETED_OWENS_QUEST		= 0xF7,
	LEARNED_ABOUT_PLANS			= 0x10B,
	OWENS_PLANS_ARE_UNSAFE		= 0xFD
};

//Batlin has buggered off (after you talk to him with the cube in your possession)
const int BATLIN_MISSING = 0xDA;

//Heard that Patterson is having an affair with Candice
const int HEARD_ABOUT_PATTERSONS_AFFAIR = 0x80;

//Heard about the Inner Voice
//const int HEARD_ABOUT_VOICE = 0x8C;