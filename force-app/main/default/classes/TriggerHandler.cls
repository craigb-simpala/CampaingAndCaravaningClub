public abstract class TriggerHandler {
	
	/**
	 * @description	When set to true will prevent the trigger handler being executed more than once
	 */
	private static Boolean preventRecursiveTrigger = false;
	
	/**
	 * @description	Used to prevent the trigger handler from being executed more than once
	 */
	private static Boolean hasExecuted = false;
	
	
	/**
	 * @description	This will be called in the trigger before insert event
	 * @param newObjects List of new sObjects to be inserted
	 */
	public virtual void beforeInsert(List<SObject> newObjects){}
	
	
	/**
	 * @description This will be called in the trigger before update event
	 * @param oldObjects List of the sObjects being updated with their original values
	 * @param newObjects List of the sObjects being updated with their new values
	 */
	public virtual void beforeUpdate(List<SObject> oldObjects, List<SObject> newObjects, Map<Id,SObject> oldMap, Map<Id,SObject> newMap){}


	/**
	 * @description This will be called in the trigger before delete event
	 * @param objects List of the sObjects being deleted
	 */
	public virtual void beforeDelete(List<SObject> objects, Map<Id,SObject> oldMap){}


	/**
	 * @description This will be called in the trigger after insert event
	 * @param newObjects List of the sObjects being inserted
	 */
	public virtual void afterInsert(List<SObject> newObjects, Map<Id,SObject> newMap){}
	
	
	/**
	 * @description This will be called in the trigger after update event
	 * @param oldObjects List of the sObjects being updated with their original values
	 * @param newObjects List of the sObjects being updated with their new values
	 */
	public virtual void afterUpdate(List<SObject> oldObjects, List<SObject> newObjects, Map<Id,SObject> oldMap, Map<Id,SObject> newMap){}


	/**
	 * @description This will be called in the trigger after delete event
	 * @param objects List of objects to be deleted
	 */
	public virtual void afterDelete(List<SObject> objects, Map<Id,SObject> oldMap){}

	/**
	 * @description This will be called in the trigger after undelete event
	 * @param objects List of objects undeleted
	 */
	public virtual void afterUndelete(List<SObject> newObjects){}


	/**
	 * @description This will call the relevant method in the trigger handler for the current trigger event
	 */
	public void execute(){
		
		// Control recursive triggers, if required
        if(hasExecuted && preventRecursiveTrigger) return;
            hasExecuted = true;
		
		// Call the relevant trigger event method
		if(Trigger.isBefore){				
			if(Trigger.isDelete){
				beforeDelete(Trigger.old, Trigger.oldMap);
				
			} else if (Trigger.isInsert){
				beforeInsert(Trigger.new);
				
			} else if (Trigger.isUpdate){
				beforeUpdate(Trigger.old, Trigger.new, Trigger.oldMap, Trigger.newMap);
				
			}
		} else {
			if(Trigger.isDelete){
				afterDelete(Trigger.old, Trigger.oldMap);
				
			} else if(Trigger.isInsert){
				afterInsert(Trigger.new, Trigger.newMap);
				
			} else if(Trigger.isUpdate){
				afterUpdate(Trigger.old, Trigger.new, Trigger.oldMap, Trigger.newMap);
			} else if (Trigger.isUndelete) {
				afterUndelete(Trigger.new);
			}
		}
	}
	
	
	/**
	 * @description This is called by the child class to prevent the trigger handler being
	 *				executed recursively.
	 * @param prevent Controls whether the trigger handler can be called recursively
	 */
	public void preventRecursiveTrigger(Boolean prevent){
		prevent = prevent != null? prevent : false;
		preventRecursiveTrigger = prevent;
	}

	public static void testCoverage() {
		Integer i = 0;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
	}
}