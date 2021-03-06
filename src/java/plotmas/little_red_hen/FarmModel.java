package plotmas.little_red_hen;

import java.util.List;
import java.util.logging.Logger;

import plotmas.PlotLauncher.LauncherAgent;
import plotmas.storyworld.Item;
import plotmas.storyworld.Model;
import plotmas.storyworld.StoryworldAgent;


/**
 * Custom model of the story-world of the "Tale of the Little Red Hen".
 * @author Leonid Berov
 */
public class FarmModel extends Model{
	
	public static enum WHEAT_STATE {SEED, GROWING, RIPE, HARVESTED, FLOUR;}
	static Logger logger = Logger.getLogger(FarmModel.class.getName());

	public Wheat wheat;

	private int actionCount;
		private boolean wheatFound;
	
	
	public FarmModel(List<LauncherAgent> agents, FarmEnvironment env) {
		super(agents, env);

		this.actionCount = 0;
		this.wheat = null;
		this.wheatFound = false;
	}

	
	public boolean farmWork(StoryworldAgent agent) {
		this.actionCount += 1;
		logger.info("Some farming activity was performed");
		
		if ((!wheatFound) && (this.actionCount >= 3) && (agent.name == "hen")) {
			this.wheat = new Wheat();
			agent.addToInventory(this.wheat);					//also: [emotion(joy),emotion(gratitude)]
			this.environment.addEventPerception(agent.name, "found(wheat)[emotion(joy)]");  
			this.wheatFound = true;
			logger.info(agent.name + " found wheat grains");
		}
		
		return true;
	}
	
	public boolean plantWheat(StoryworldAgent agent) {
		Wheat wheatItem = (Wheat) agent.get(Wheat.itemName);
		if (!(wheatItem == null)) {
				if (wheatItem.state == WHEAT_STATE.SEED) {
					this.wheat.state = WHEAT_STATE.GROWING;
					this.environment.addEventPerception(agent.name, "planted(wheat)[emotion(pride)]");
					logger.info("Wheat planted");
					return true;
				}
		}
		
		return false;
	}
	
	public boolean tendWheat(StoryworldAgent agent) {
		if ((this.wheat.state == WHEAT_STATE.GROWING)){
			this.wheat.state = WHEAT_STATE.RIPE;
			logger.info("Wheat has grown and is ripe now");
			this.environment.addEventPerception(agent.name, "tended(wheat)[emotion(pride)]");
			return true;
		}
		
		return false;
	}
	
	public boolean harvestWheat(StoryworldAgent agent) {
		if ((this.wheat.state == WHEAT_STATE.RIPE)){
			this.wheat.state = WHEAT_STATE.HARVESTED;
			logger.info("Wheat was harvested");
			this.environment.addEventPerception(agent.name, "harvested(wheat)[emotion(pride)]");
			return true;
		}
		
		return false;
	}
	
	public boolean grindWheat(StoryworldAgent agent) {
		if ((this.wheat.state == WHEAT_STATE.HARVESTED)){
			this.wheat.state = WHEAT_STATE.FLOUR;
			logger.info("Wheat was ground to flour");
			this.wheat = null;
			this.environment.addEventPerception(agent.name, "ground(wheat)[emotion(pride)]");
			return true;
		}
		return false;
	}

	public boolean bakeBread(StoryworldAgent agent) {
		Wheat wheatItem = (Wheat) agent.get(Wheat.itemName);
		if((!(wheatItem == null)) & (wheatItem.state == WHEAT_STATE.FLOUR)) {
			agent.addToInventory(new Bread());
			agent.removeFromInventory(wheatItem);
			
			logger.info(agent.name + ": baked some bread.");
			this.environment.addEventPerception(agent.name, "baked(bread)[emotion(pride),emotion(joy)]");
			return true;
		}
		
		return false;
	}
	

	
	/****** helper classes *******/
	
	public class Wheat extends Item {
		static final String itemName = "wheat";
		public WHEAT_STATE state = WHEAT_STATE.SEED;
		
		@Override
		public String literal() {
			if (state == WHEAT_STATE.SEED) {
				return "wheat(seed)";
			}
			
			if (state == WHEAT_STATE.GROWING) {
				return "wheat(growing)";
			}

			if (state == WHEAT_STATE.RIPE) {
				return "wheat(ripe)";
			}
			
			if (state == WHEAT_STATE.HARVESTED) {
				return "wheat(harvested)";
			}
			
			if (state == WHEAT_STATE.FLOUR) {
				return "wheat(flour)";
			}
		
			return null;
		}

		@Override
		public String getItemName() {
			return itemName;
		}

	}
	
	class Bread extends Item {
		static final String itemName = "bread";
		
		@Override
		public String getItemName() {
			return itemName;
		}
		
		public String literal() {
			return "bread";
		}
		
		public boolean isEdible() {
			return true;
		}
		
	}
	
}
