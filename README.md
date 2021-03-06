# plotmas
Plotmas is a system for generating narratives, which is using an extended version of the [Jason multi-agent framework](https://github.com/cartisan/jason/tree/o3a).

## Setup
1. Make sure to have [Java 8](http://www.oracle.com/technetwork/java/javase/downloads/jdk8-downloads-2133151.html) (be sure to pick the right 32/64bit version) or later, and preferably [Eclipse](http://www.eclipse.org/), installed
1. Check out this repository (see: [checking out git repositories using Eclipse](https://github.com/collab-uniba/socialcde4eclipse/wiki/How-to-import-a-GitHub-project-into-Eclipse))
1. Import the plotmas project in Eclipse
1. Test that the system is running properly by executing the example simulation, that is, execute the main method of `RedHenLauncher`
1. You can also test running Jason's debug mode by passing `RedHenLauncher` the parameter `"-debug"`. 
In Eclipse: Create a new "Run Configuration" (called e.g. "Red Hen [debug]") `Run -> Run Configurations... -> Java Applications -> right click -> New`, under the tab "Arguments" you can enter the parameter `"-debug"` under "Program arguments".

## Implementing your own story 
To implement your own story and explore it using plotmas you need to extend several classes and implement custom agent reasoning. An example story can be found in the `plotmas.little_red_hen` package.<br>
<i>Note: It is advisable to first get familiar with the basics of Jason programming, using for instance this [getting started guide](http://jason.sourceforge.net/mini-tutorial/getting-started/#_an_example_with_environment) or [this tutorial](http://jason.sourceforge.net/Jason.pdf). You can play around with the tutorials in the `lab_rotations` branch. To check out this branch in Eclipse: `Right-click on plotmas -> Team -> Switch To -> Lab Rotation`. </i>

1. Implement a your custom AgentSpeak reasoning code in a custom `src/asl/agentXYZ.asl`
1. Create a new sub-package `plotmas.XYZ` under `src/java` for your story, all your Java classes should be located here
1. Subclass `Model` to create a custom representation of the story world
   1. Implement a method for each ASL action that your agents use
1. Subclass `PlotEnvironment` to create a custom environment responsible for managing the communication between agents and model
   1. Override `initialize(List<LauncherAgent> agents)` and at least execute the super-class initializer and set instance variable `Model model` to an instance of your custom model class
   1. Override `public boolean executeAction(String agentName, Structure action)` to implement which ASL actions are handled by which model method. For example:
	
    ```java
    public class YourEnvironment extends PlotEnvironment<YourModel> {
        @Override
        public void initialize(List<LauncherAgent> agents) {
          super.initialize(agents);
            YourModel model = new YourModel(agents, this);
            this.setModel(model);
        }
        @Override
        public boolean executeAction(String agentName, Structure action) {
          boolean result = super.executeAction(agentName, action);
          StoryworldAgent agent = getModel().getAgent(agentName);

          if (action.getFunctor().equals("farm_work")) {
            result = getModel().farmWork(agent);
          }
          pauseOnRepeat(agentName, action);
          return result;
        }
    }
    ```
    
1. Subclass `PlotLauncher` to create a custom class responsible for setting up and starting your simulation. Implement a static main method, which needs to do several things:
   1. Set the static variable `ENV_CLASS` to the class of your custom environment implementation
   1. Instantiate the launcher
   1. Create a list of `LauncherAgent`s that can contain personality definitions, initial beliefs and goals for each agent of your simulation
   1. `run` the launcher using your custom `agentXYZ` agent implementation. For example:
   
	```java
	public static void main(String[] args) throws JasonException {
    	ENV_CLASS = YourEnvironment.class;
    	runner = new YourLauncher();

		ImmutableList<LauncherAgent> agents = ImmutableList.of(
      		runner.new LauncherAgent("hen",
        		new Personality(0,  1, 0.7,  0.3, 0.0)
      		),
      		runner.new LauncherAgent("dog",
        		new Personality(0, -1, 0, -0.7, -0.8)
      		)
    	);

		runner.run(args, agents, "agentXYZ");
	}
    ```
    
## Affective reasoning
Plotmas uses the affective reasoning capabilities of a custom [extension of Jason](https://github.com/cartisan/jason/tree/o3a). First an overview of agent-side reasoning over emotions, mood and personality will be given. Then each of the three affective phenomena--and their interactions--will be introduced in detail.

### Reasoning using affect
An agent has access to its own affective state via beliefs: it always has a mood/1 belief that specifies which type of mood the agent is currently in e.g. `mood(relaxed)`. 
Whenever the agent appraises an emotion, an emotion/1 belief is added, e.g.`emotion(joy)`. Multiple emotion beliefs can be present at the same time. If an emotion is directed at another agent, its target is noted in the annotations, e.g. `emotion(anger)[target(cow)]`. If an emotion that has a target contributes to a mood (i.e. is located in the same octant as the new mood after update) than the target gets preserved, so the agent know who is responsible for its mood. For this purpose, an agent has always an affect\_target/1 belief, that contains a (potentially empty) list of target agents e.g. `affect_target([cow])`. These beliefs are automatically generated by the architecture and can be used like all other beliefs in AgentSpeak.

Affect can be used to modify Jason's default plan selection. To specify that a plan can be used only with certain a personality profile or during a certain mood, an `affect` predicate needs to be added to the plan's annotations. This predicate can contain a variable number of personality/2 and mood/2 predicates, which are interpreted to be in conjunction. For instance `@share_food_plan[affect(personality(agreeableness,medium), mood(pleasure,high))]` specifies that the following plan can only be executed if the agent's agreeableness trait is medium, and its current mood is high on pleasure. The possible boundaries are: `positive`, `negative`, `high` (>=0.7), `low` (<=0.7) and `medium` (between high and low).

During plan selection preference is given to the first plan with a fitting annotation. Agents that don't fit a plan's affect annotation can not select this plan.

An exhaustive example of affective reasoning capabilities can be found in `agent.asl`.


### Personality
Each agent has a personality represented on the Big-5 Personality traits scale. To set up an agents personality, define it in your custom Launcher using the `LauncherAgent` class:
`runner.new LauncherAgent("hen", new Personality(0,  1, 0.7,  0.3, 0.0))`. The traits are commonly abbreviated as OCEAN: Openness (to Experience), Conscientiousness, Extraversion, Agreeableness, Neuroticism.
These traits are defined on a floating point scale: [-1.0, 1.0]. 

An agents personality is used to compute its default mood. The value of its N trait also determines how strongly it is affected by emotions.
As seen above, plan selection can be modified to take into account an agent's personality traits. 

### Emotions
Emotions are used to appraise perceived events, their only effect is that they change an agent's current mood. Emotions are represented using the 22 emotions from the OCC catalog. You can find a current list of implemented emotions in `jason.asSemantics.Emotion`.

Primary emotions are automatic reactions to the environment that do not depend on deliberation and are similar among agents. They are defined by the Model, that is on the Java side, when the model creates a new percept. For instance:
`this.environment.addEventPerception(agentName,"received(bread)[emotion(joy, self)]")` adds a new perception for `agentName` that the agent received some bread (which should be also represented on the Model side by adding an instance of bread to the agent's inventory). This is a positive event, so the primary emotion `joy` is added, and the target if this emotion is the agent itself.
Emotions here are added as ASL Annotations to a perception literal. They are represented as ground 2-valued predicates of form `emotion(EMNAME, TARGET)`.

Secondary emotions are deliberative and thus have to be implemented on the ASL side as part of planning. For this, the internal action `appraise_emotion` is provided. For instance: `.appraise_emotion(anger, Name);` The syntax is again of the form `.appraise_emotion(EMNAME, TARGET);`

### Mood
Mood can be seen as an aggregated subjective representation of context, and its interaction with an agent's pre-dispositions. A mood is represented as a point in a 3-dimensional space with the axis: Pleasure-Arousal-Dominance (PAD) on a floating point scale: [-1.0, 1.0]. The default mood of a characters can be calculated from its personality traits, e.g. P = 0.21*E + 0.59*A - 0.19*N according to Gebhard (2005). You can find the other equations in `jason.asSemantics.Personality.defaultMood()`. The type of the mood depends on the octant of the PAD space it is located in. See `jason.asSematics.Affect` for the mapping.

Emotions affect the current mood. Each reasoning cycle all emotions that are active in an agent are collected, transfered into the PAD space according to a mapping suggested by Gebhard. The centroid of the emotion cluster is computed, and the current mood gets updated using this centroid. For this, the location of the default mood on each axis moves further towards the maximum of the octant in which the centroid is located on the respective axis (see `jason.asSemantics.Mood.updateMood(List<Emotion> emotions, Personality personality)`.
The length of the update step is dependent on two factors. One is a constant length (atm the defined in such a way that 5 update steps in the same direction are required in order to cover the maximal possible distance in PAD space). The other is the agent's value on the neuroticism scale, according to its personality. The higher the N value, the bigger the step, the more volatile the agent's mood.

Each reasoning cycle that doesn't have any active emotions, the current mood decays in the direction of the default mood. The length of the decay step is dependent on two factors. A constant length that is defined in such a way that 50 update steps in the same direction are required in order to cover the maximal possible distance in PAD space, and the agent's value on the neuroticism scale. The higher N, the slower the mood returns to normal.

As seen above, plan selection can be modified to take into account an agent's current mood. 

## Architecture
![UML class diagram](/overview_class-diagram.jpg)
