package com.robot.core.aimat
{
   import com.robot.core.config.xml.AimatXMLInfo;
   import com.robot.core.info.AimatInfo;
   import com.robot.core.mode.IAimatSprite;
   import org.taomee.ds.HashMap;
   import org.taomee.manager.TickManager;
   import org.taomee.utils.Utils;
   
   public class AimatStateManamer
   {
      
      private static const PATH:String = "com.robot.app.aimat.state.AimatState_";
      
      private var _list:HashMap = new HashMap();
      
      private var _obj:IAimatSprite;
      
      public function AimatStateManamer(param1:IAimatSprite)
      {
         super();
         this._obj = param1;
         TickManager.addListener(this.loop);
      }
      
      public function execute(param1:AimatInfo) : void
      {
         var _loc2_:Class = null;
         var _loc3_:IAimatState = null;
         var _loc4_:IAimatState = this._list.remove(param1.id);
         if(Boolean(_loc4_))
         {
            _loc4_.destroy();
            _loc4_ = null;
         }
         var _loc5_:uint = AimatXMLInfo.getIsStage(param1.id);
         if(_loc5_ != 0)
         {
            _loc2_ = Utils.getClass(PATH + _loc5_);
         }
         else
         {
            _loc2_ = Utils.getClass(PATH + param1.id.toString());
         }
         if(Boolean(_loc2_))
         {
            _loc3_ = new _loc2_();
            this._list.add(param1.id,_loc3_);
            _loc3_.execute(this._obj,param1);
         }
      }
      
      public function isType(param1:uint) : Boolean
      {
         return this._list.containsKey(param1);
      }
      
      public function clear() : void
      {
         this._list.eachValue(function(param1:IAimatState):void
         {
            param1.destroy();
            param1 = null;
         });
         this._list.clear();
      }
      
      public function destroy() : void
      {
         TickManager.removeListener(this.loop);
         this.clear();
         this._list = null;
         this._obj = null;
      }
      
      private function loop() : void
      {
         if(this._list.isEmpty())
         {
            return;
         }
         this._list.each2(function(param1:uint, param2:IAimatState):void
         {
            if(param2.isFinish)
            {
               _list.remove(param1);
               param2.destroy();
               param2 = null;
            }
         });
      }
   }
}

