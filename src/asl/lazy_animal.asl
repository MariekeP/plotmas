// Agent lazy_animal in project little_red_hen

/* Initial beliefs and goals */

is_lazy(self).

is_work(create_bread).
is_work(plant(_)).
is_work(tend(_)).
is_work(harvest(_)).
is_work(grind(_)).
is_work(bake(_)).

is_pleasant(eat(bread)).

!cazzegiare.

/* Initial rules */

+has(bread) <- 	
	!eat(bread).


// lazy agents don't do things that
// are work
+!X[_] : is_lazy(self) & is_work(X) <-
	.print(X, " is too much work for me!");
	.suspend(X).
	

// TODO: I belief this is a misuse of tell!
// But how do we otherwise inform of such
// a rejection
+!help_with(X)[source(Name)]
	: is_lazy(self) & is_work(X) <-
	.print("can't help you! ", X, " is too much work for me!");
	.send(Name, tell, rejected_help_request(X)).

+!help_with(X)[source(Name)] <-
	.print("I'll help you with ", X, ", ", Name);
	help(Name).

+!share_in(X)[source(Name)]
	: is_pleasant(X) <-
	.print("I'll gladly join you for ", X, " ", Name);
	X.

/* Plans */
+!cazzegiare : is(silence, gold) 
	<- !cazzegiare.

+!cazzegiare : true	<- 	
	.print("I'm doing sweet nothing.");
	+is(silence, gold);
	!cazzegiare.


+!create_bread : has(wheat(seed)) <- 	
	!plant(wheat);
	!tend(wheat);
	!harvest(wheat);
	!grind(wheat);
	!bake(bread).   

// action-execution goals
+!plant(wheat) <-
	plant(wheat).
	
+!tend(wheat) <-
	tend(wheat).
	
+!harvest(wheat) <-
	harvest(wheat).

+!grind(wheat) <-
	grind(wheat).

+!bake(bread) <-
	break(bread).
	
+!eat(X) : has(X) <- 
	.my_name(Name);
	eat(Name, X).
	
+!eat(X) <- 
	.suspend(eat(X)).