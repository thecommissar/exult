//Used for conversations that say "good afternoon/morning/evening"
var timeFunction(var hour)
{
	var time_of_day; 
	if ((hour >= 6) && (hour < 12)) //'good morning'
	{
		time_of_day = "morning";
	}
	
	else if ((hour >= 12) && (hour < 18)) //'good afternoon'
	{
		time_of_day = "afternoon";
	}
	else 
		time_of_day = "evening";
	
	return time_of_day;
}