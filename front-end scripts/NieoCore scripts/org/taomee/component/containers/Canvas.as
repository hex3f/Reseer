package org.taomee.component.containers
{
   import org.taomee.component.Container;
   
   public class Canvas extends Container
   {
      
      public function Canvas()
      {
         super();
      }
      
      public function get horizontalList() : Array
      {
         return compList.sortOn("x",Array.NUMERIC);
      }
      
      public function get verticalList() : Array
      {
         return compList.sortOn("y",Array.NUMERIC);
      }
   }
}

