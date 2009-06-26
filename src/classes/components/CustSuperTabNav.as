package classes.components
{
 
	import flash.events.MouseEvent;
	
	import flexlib.containers.SuperTabNavigator;
	
	import mx.controls.Alert;
	import mx.events.FlexEvent;
	
	/**
	 * Workaround class for a bug in flex <a href='http://bugs.adobe.com/jira/browse/SDK-15974'>http://bugs.adobe.com/jira/browse/SDK-15974</a>
	 * 
	 * <p>Overrides the <code>commitSelectedIndex()</code> method to avoid the bug occurance.
	 * 
	 * @author Eric Belair (bug submitter)
	 */
	public class CustSuperTabNav extends SuperTabNavigator
	{
		
		
		public function CustSuperTabNav()
		{
			super(); 
			
		}
		
        override protected function commitSelectedIndex(newIndex:int):void
        {
        	super.commitSelectedIndex(newIndex);
        	
        	// Select the corresponding Tab in the Tab Bar (this fixes a bug in Flex)
        	tabBar.selectedIndex = newIndex;
           
           
        }
        
	}
}