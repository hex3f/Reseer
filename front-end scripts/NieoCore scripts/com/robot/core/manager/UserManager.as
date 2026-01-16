package com.robot.core.manager
{
   import com.robot.core.event.PeopleActionEvent;
   import com.robot.core.mode.BasePeoleModel;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import org.taomee.ds.HashMap;
   import org.taomee.utils.DisplayUtil;
   
   public class UserManager
   {
      
      private static var instance:EventDispatcher;
      
      private static var _listDic:HashMap = new HashMap();
      
      public static var isShow:Boolean = true;
      
      public function UserManager()
      {
         super();
      }
      
      public static function get length() : int
      {
         return _listDic.length;
      }
      
      public static function addUser(param1:uint, param2:BasePeoleModel) : BasePeoleModel
      {
         return _listDic.add(param1,param2);
      }
      
      public static function removeUser(param1:uint) : BasePeoleModel
      {
         return _listDic.remove(param1);
      }
      
      public static function getUserModel(param1:uint) : BasePeoleModel
      {
         if(param1 == MainManager.actorID)
         {
            return MainManager.actorModel;
         }
         return _listDic.getValue(param1);
      }
      
      public static function clear() : void
      {
         var _loc1_:Sprite = null;
         for each(_loc1_ in getUserModelList())
         {
            DisplayUtil.removeForParent(_loc1_);
         }
         _listDic.clear();
      }
      
      public static function getUserIDList() : Array
      {
         return _listDic.getKeys();
      }
      
      public static function getUserModelList() : Array
      {
         return _listDic.getValues();
      }
      
      public static function contains(param1:uint) : Boolean
      {
         return _listDic.containsKey(param1);
      }
      
      public static function getInstance() : EventDispatcher
      {
         if(instance == null)
         {
            instance = new EventDispatcher();
         }
         return instance;
      }
      
      public static function addActionListener(param1:uint, param2:Function) : void
      {
         getInstance().addEventListener(param1.toString(),param2,false,0,false);
      }
      
      public static function removeActionListener(param1:uint, param2:Function) : void
      {
         getInstance().removeEventListener(param1.toString(),param2,false);
      }
      
      public static function dispatchAction(param1:uint, param2:String, param3:Object) : void
      {
         if(hasActionListener(param1))
         {
            getInstance().dispatchEvent(new PeopleActionEvent(param1.toString(),param2,param3));
         }
      }
      
      public static function hasActionListener(param1:uint) : Boolean
      {
         return getInstance().hasEventListener(param1.toString());
      }
      
      public static function addEventListener(param1:String, param2:Function, param3:Boolean = false, param4:int = 0, param5:Boolean = false) : void
      {
         getInstance().addEventListener(param1,param2,param3,param4,param5);
      }
      
      public static function removeEventListener(param1:String, param2:Function, param3:Boolean = false) : void
      {
         getInstance().removeEventListener(param1,param2,param3);
      }
      
      public static function dispatchEvent(param1:Event) : void
      {
         getInstance().dispatchEvent(param1);
      }
      
      public static function hasEventListener(param1:String) : Boolean
      {
         return getInstance().hasEventListener(param1);
      }
      
      public static function willTrigger(param1:String) : Boolean
      {
         return getInstance().willTrigger(param1);
      }
   }
}

