package com.robot.app.protectSys
{
   import com.robot.core.config.xml.PetXMLInfo;
   import com.robot.core.manager.UIManager;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.text.TextFormatAlign;
   import org.taomee.component.containers.HBox;
   import org.taomee.component.containers.VBox;
   import org.taomee.component.control.MText;
   import org.taomee.component.layout.FlowLayout;
   import org.taomee.utils.AlignType;
   import org.taomee.utils.DisplayUtil;
   
   public class KillPluginPanel extends Sprite
   {
      
      public static const WRONG:String = "wrong";
      
      public static const RIGHT:String = "right";
      
      private var bg:Sprite;
      
      private var mainBox:VBox;
      
      private var petBox:HBox;
      
      private var DIR_TYPE:uint;
      
      private var STR_LIST:Array = ["背面","正面","侧面"];
      
      public function KillPluginPanel()
      {
         super();
         this.petBox = new HBox(15);
         this.petBox.halign = FlowLayout.CENTER;
         this.petBox.valign = FlowLayout.MIDLLE;
         this.petBox.setSizeWH(410,130);
         this.bg = UIManager.getSprite("Panel_Background");
         this.bg.width = 475;
         this.bg.height = 292;
         addChild(this.bg);
         var _loc1_:Sprite = UIManager.getSprite("Panel_Background_5");
         _loc1_.width = 424;
         _loc1_.height = 240;
         DisplayUtil.align(_loc1_,this.getRect(this),AlignType.MIDDLE_CENTER);
         addChild(_loc1_);
         this.mainBox = new VBox();
         this.mainBox.halign = FlowLayout.CENTER;
         this.mainBox.valign = FlowLayout.MIDLLE;
         this.mainBox.setSizeWH(410,225);
         DisplayUtil.align(this.mainBox,this.getRect(this),AlignType.MIDDLE_CENTER);
         addChild(this.mainBox);
         this.mainBox.append(this.petBox);
         this.DIR_TYPE = Math.floor(Math.random() * 3);
         var _loc2_:MText = new MText();
         _loc2_.align = TextFormatAlign.CENTER;
         _loc2_.setSizeWH(410,30);
         _loc2_.text = "请选择<b><font color=\'#0000ff\'>" + this.STR_LIST[this.DIR_TYPE] + "</font><font color=\'#ff0000\'>朝向你</font></b>的精灵！";
         this.mainBox.append(_loc2_);
         this.getPet();
      }
      
      private function getPet() : void
      {
         var _loc1_:* = 0;
         var _loc2_:SinglePetBox = null;
         var _loc3_:* = 0;
         var _loc4_:uint = Math.floor(Math.random() * 4);
         var _loc5_:Number = 0;
         while(_loc5_ < 4)
         {
            _loc1_ = Math.floor(Math.random() * 500);
            if(_loc5_ == _loc4_)
            {
               _loc2_ = new SinglePetBox(PetXMLInfo.getIdList()[_loc1_],this.DIR_TYPE);
            }
            else
            {
               if(this.DIR_TYPE == SinglePetBox.DOWN)
               {
                  _loc3_ = SinglePetBox.UP;
               }
               else if(this.DIR_TYPE == SinglePetBox.LEFT)
               {
                  _loc3_ = SinglePetBox.UP;
               }
               else if(this.DIR_TYPE == SinglePetBox.UP)
               {
                  _loc3_ = SinglePetBox.DOWN;
               }
               _loc2_ = new SinglePetBox(PetXMLInfo.getIdList()[_loc1_],_loc3_);
            }
            _loc2_.buttonMode = true;
            _loc2_.mouseChildren = true;
            _loc2_.addEventListener(MouseEvent.CLICK,this.clickSinglePet);
            this.petBox.append(_loc2_);
            _loc5_++;
         }
      }
      
      private function clickSinglePet(param1:MouseEvent) : void
      {
         var _loc2_:SinglePetBox = param1.currentTarget as SinglePetBox;
         if(_loc2_.dirType == this.DIR_TYPE)
         {
            dispatchEvent(new Event(RIGHT));
         }
         else
         {
            dispatchEvent(new Event(WRONG));
         }
      }
      
      public function destroy() : void
      {
         DisplayUtil.removeForParent(this);
         this.mainBox.destroy();
         this.mainBox = null;
         this.petBox = null;
      }
   }
}

