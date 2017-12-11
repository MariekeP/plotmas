/********************************************/
/***** General knowledge  *******************/
/*****      Common sense beliefs ************/
/********************************************/

is_work(plant(_)).
is_work(tend(_)).
is_work(harvest(_)).
is_work(grind(_)).
is_work(bake(_)).

is_pleasant(eat(bread)).

obligation(farm_work).

!default_activity.

/********************************************/
/*****      Common sense reasoning ************/
/********************************************/
@share_food__1[atomic, affect(personality(agreeableness,medium), mood(pleasure,high)), isIntention]
+has(X) : is_pleasant(eat(X)) & has(X) <- 			// still has X when event selected
	?agents(Anims);
	!share(X, Anims);
	.print("Shared: ", X, " with the others");
	!eat(X).
	
@share_food__2[atomic, affect(personality(agreeableness,high), mood(pleasure,positive)), isIntention]
+has(X) : is_pleasant(eat(X)) & has(X) <- 			// still has X when event selected
	?agents(Anims);
	!share(X, Anims);
	.print("Shared: ", X, " with the others");
	!eat(X).

+has(X) : is_pleasant(eat(X)) & has(X)  <-			// still has X when event selected 
	!eat(X).
	
+has(wheat(seed)) <- 
	!!create_bread.

+self(has_purpose) <-
	.suspend(default_activity).

-self(has_purpose) <-
	.resume(default_activity).


/********************************************/
/***** Self-specifications  *****************/
/*****      Emotion management **************/
/********************************************/

+rejected_help_request(Req)[source(Name)] <-
	.appraise_emotion(anger, Name);
	.abolish(rejected_help_request(Req));
	-asking(Req, Name);
	if(not asking(Req, _)) {
		.resume(Req);
	}.
	
+accepted_help_request(Req)[source(Name)] <-
	.appraise_emotion(gratitude, Name);
	.abolish(accepted_help_request(Req));
	-asking(Req, Name);
	if(not asking(Req, _)) {
		.resume(Req);
	}.


/********************************************/
/*****      Personality *********************/
/********************************************/

@get_help[affect(personality(extraversion, high)), isIntention]
+!X[_] : is_work(X) & not already_asked(X) <-
	?agents(Animals);
	+already_asked(X);
	for (.member(Animal, Animals)) {
		.print("Asking ", Animal, " to help with ", X)
		.send(Animal, achieve, help_with(X));
		+asking(X, Animal);
	}
	.suspend(X);
	!X.

@default_activity__1[affect(personality(conscientiousness,high)), isIntention]
+!default_activity <-
	?obligation(X);
	!X;
	!default_activity.
	
@default_activity__2[affect(personality(conscientiousness,low)), isIntention]
+!default_activity <-
	!relax;
	!default_activity.

@default_activity__3[isIntention]
+!default_activity <-
	.random(R);
	if(R>0.5) {
		!relax;
	} else {
		?obligation(X);
		!X;
	}
	!default_activity.	

/********************************************/
/****** Mood  *******************************/
/********************************************/
+mood(hostile) <-
	?affect_target(Anims);
	!!punished(Anims).

//	   + relativised commitment
-mood(hostile) <-
	.succeed_goal(punished(_)).

// begin declarative goal  (p. 174; Bordini,2007)*/
+!punished(L) : punished(L) <- true.

// insert all actual punishment plans
@punish[atomic, isIntention]	
+!punished(_) : mood(hostile) & has(X) & is_pleasant(eat(X)) <-
	?affect_target(Anims);
	if (.empty(Anims)) {
		!eat(X);
		+punished(Anims);		
	} else {
		.send(Anims, achieve, eat(X));
		.print("Asked ", Anims, " to eat ", X, ". But not shareing necessary ressources. xoxo");
		!eat(X);
		+punished(Anims)
	}.
	
//	   +blind commitment
+!punished(_) : true <- 
	?affect_target(Anims);	
	!!punished(Anims).

+punished(L) : true <- 
	-punished(L);
	.succeed_goal(punished(_)).

/********************************************/
/***** Plans  *******************************/
/********************************************/

@create_bread[isIntention]
+!create_bread : has(wheat(seed)) <-
	+self(has_purpose);
	!plant(wheat);
	!tend(wheat);
	!harvest(wheat);
	!grind(wheat);
	!bake(bread);
	-self(has_purpose). 	

@reject_request[affect(personality(conscientiousness,low)),isIntention]
+!help_with(X)[source(Name)] : is_work(X) <-
	.print("can't help you! ", X, " is too much work for me!");
	.send(Name, tell, rejected_help_request(X)).

@accept_request[isIntention]
+!help_with(X)[source(Name)] <-
	.print("I'll help you with ", X, ", ", Name);
	.send(Name, tell, accepted_help_request(X));
	help(Name).
	

/********************************************/
/*****      Action Execution Goals **********/
/********************************************/
+!relax <-
	relax.
	
+!farm_work <-
	farm_work.

@plant[isIntention]
+!plant(wheat) <-
	plant(wheat).
	
@tend[isIntention]
+!tend(wheat) <-
	tend(wheat).
	
@harvest[isIntention]
+!harvest(wheat) <-
	harvest(wheat).

@grind[isIntention]
+!grind(wheat) <-
	grind(wheat).

@bake[isIntention]
+!bake(bread) <-
	bake(bread).

@eat__1[atomic,isIntention]	
+!eat(X) : has(X) <- 
	eat(X);
	-has(X);
	.succeed_goal(eat(X)).
	
@eat__2[isIntention]	
+!eat(X) <- 
	.print("Can't eat ", X, ", I don't have any! :( ");
	.appraise_emotion(disappointment);
	.suspend(eat(X)).
	
+!share(X, Anims) <-
	share(X, Anims).	