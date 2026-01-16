package gs.utils.tween
{
   public class FilterVars extends SubVars
   {
      
      public var index:int;
      
      public var addFilter:Boolean;
      
      public var remove:Boolean;
      
      public function FilterVars(param1:Boolean = false, param2:int = -1, param3:Boolean = false)
      {
         super();
         this.remove = param1;
         if(param2 > -1)
         {
            this.index = param2;
         }
         this.addFilter = param3;
      }
   }
}

