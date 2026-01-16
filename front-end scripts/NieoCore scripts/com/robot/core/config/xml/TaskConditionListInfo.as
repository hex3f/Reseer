package com.robot.core.config.xml
{
   import flash.utils.getDefinitionByName;
   
   public class TaskConditionListInfo
   {
      
      private var _fun:String;
      
      private var _args:String;
      
      private var _xml:XML;
      
      private var _error:String;
      
      public function TaskConditionListInfo(param1:XML)
      {
         super();
         this._xml = param1;
         this._fun = param1.@fun;
         this._args = param1.@arg;
         this._error = param1;
      }
      
      public function getClass() : Class
      {
         if(this._xml["class"] != "")
         {
            return getDefinitionByName(this._xml.attribute["class"]) as Class;
         }
         return getDefinitionByName("com.robot.app.taskPanel.TaskCondition") as Class;
      }
      
      public function get fun() : String
      {
         return this._fun;
      }
      
      public function get args() : String
      {
         return this._args;
      }
      
      public function get error() : String
      {
         return this._error;
      }
   }
}

