package com.robot.core.npc
{
   import com.robot.core.config.xml.EmotionXMLInfo;
   import com.robot.core.manager.LevelManager;
   import com.robot.core.manager.TaskIconManager;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.events.MouseEvent;
   import flash.geom.Point;
   import org.taomee.component.containers.Box;
   import org.taomee.component.containers.VBox;
   import org.taomee.component.control.MLabel;
   import org.taomee.component.control.MLabelButton;
   import org.taomee.component.control.MLoadPane;
   import org.taomee.component.layout.FlowLayout;
   import org.taomee.component.layout.FlowWarpLayout;
   import org.taomee.manager.ResourceManager;
   import org.taomee.utils.AlignType;
   import org.taomee.utils.DisplayUtil;
   
   public class NpcDialog
   {
      
      private static var _npcMc:Sprite;
      
      private static var _dialogA:Array;
      
      private static var _questionA:Array;
      
      private static var _handlerA:Array;
      
      private static var _bgMc:Sprite;
      
      private static var _prevBtn:MovieClip;
      
      private static var _nextBtn:MovieClip;
      
      private static var _curNpcPath:String;
      
      private static var txtBox:Box;
      
      private static var btnBox:VBox;
      
      private static var mcL:MLoadPane;
      
      private static const MAX:uint = 3;
      
      private static var _curIndex:uint = 0;
      
      private static var _btnA:Array = [];
      
      setup();
      
      public function NpcDialog()
      {
         super();
      }
      
      public static function setup() : void
      {
         _bgMc = TaskIconManager.getIcon("NPC_BG_MC") as Sprite;
         _nextBtn = _bgMc["nextBtn"];
         _prevBtn = _bgMc["prevBtn"];
         _prevBtn.gotoAndStop(1);
         _prevBtn.visible = false;
         txtBox = new Box();
         txtBox.x = 144;
         txtBox.y = 20;
         txtBox.setSizeWH(520,112);
         txtBox.layout = new FlowWarpLayout(FlowWarpLayout.LEFT,FlowWarpLayout.BOTTOM,-3,-2);
         btnBox = new VBox(2);
         btnBox.x = 144;
         btnBox.y = 32;
         btnBox.setSizeWH(520,112);
         btnBox.valign = FlowLayout.BOTTOM;
         _bgMc.addChild(btnBox);
         _bgMc.addChild(txtBox);
         _bgMc.addChild(_nextBtn);
         _bgMc.addChild(_prevBtn);
      }
      
      public static function show(param1:uint, param2:Array, param3:Array = null, param4:Array = null) : void
      {
         var _loc5_:int = 0;
         LevelManager.closeMouseEvent();
         if(_curNpcPath != "")
         {
            ResourceManager.cancelURL(_curNpcPath);
         }
         if(Boolean(_npcMc))
         {
            DisplayUtil.removeForParent(_npcMc);
            _npcMc = null;
         }
         if(_btnA.length > 0)
         {
            _loc5_ = 0;
            while(_loc5_ < _btnA.length)
            {
               (_btnA[_loc5_] as MLabelButton).removeEventListener(MouseEvent.CLICK,onTxtBtnClickHandler);
               _btnA[_loc5_] = null;
               _loc5_++;
            }
         }
         _btnA = new Array();
         txtBox.removeAll();
         btnBox.removeAll();
         _curNpcPath = NPC.getDialogNpcPathById(param1);
         _curIndex = 0;
         _dialogA = param2;
         _questionA = param3;
         _handlerA = param4;
         _prevBtn.visible = false;
         _prevBtn.gotoAndStop(1);
         if(_dialogA.length <= 1)
         {
            _nextBtn.visible = false;
            _nextBtn.gotoAndStop(1);
         }
         else
         {
            _nextBtn.visible = true;
            _nextBtn.play();
         }
         addTxtBtn();
         shwoTxt(_curIndex);
         addEvent();
         LevelManager.appLevel.addChild(_bgMc);
         DisplayUtil.align(_bgMc,null,AlignType.BOTTOM_CENTER,new Point(0,-60));
         ResourceManager.getResource(_curNpcPath,onComHandler);
      }
      
      private static function addTxtBtn() : void
      {
         var _loc1_:int = 0;
         var _loc2_:MLabelButton = null;
         if(_questionA != null)
         {
            _loc1_ = 0;
            while(_loc1_ < _questionA.length)
            {
               _loc2_ = new MLabelButton(_questionA[_loc1_]);
               _loc2_.overColor = 65535;
               _loc2_.outColor = 16776960;
               _loc2_.underLine = true;
               _loc2_.buttonMode = true;
               btnBox.append(_loc2_);
               _loc2_.name = "btn" + _loc1_;
               _loc2_.addEventListener(MouseEvent.CLICK,onTxtBtnClickHandler);
               _btnA.push(_loc2_);
               _loc1_++;
            }
         }
      }
      
      private static function onTxtBtnClickHandler(param1:MouseEvent) : void
      {
         hide();
         LevelManager.openMouseEvent();
         var _loc2_:String = (param1.currentTarget as MLabelButton).name;
         var _loc3_:uint = uint(_loc2_.slice(3,_loc2_.length));
         if(Boolean(_handlerA))
         {
            if(_handlerA[_loc3_] != null && _handlerA[_loc3_] != undefined)
            {
               (_handlerA[_loc3_] as Function)();
            }
         }
      }
      
      private static function onComHandler(param1:DisplayObject) : void
      {
         if(Boolean(mcL))
         {
            DisplayUtil.removeForParent(mcL);
            mcL.destroy();
            mcL = null;
         }
         _npcMc = param1 as Sprite;
         DisplayUtil.stopAllMovieClip(_npcMc as MovieClip);
         mcL = new MLoadPane(_npcMc);
         if(_npcMc.width > _npcMc.height)
         {
            mcL.fitType = MLoadPane.FIT_WIDTH;
         }
         else
         {
            mcL.fitType = MLoadPane.FIT_HEIGHT;
         }
         mcL.setSizeWH(160,170);
         mcL.x = -15;
         mcL.y = -18;
         _bgMc.addChild(mcL);
      }
      
      private static function addEvent() : void
      {
         _nextBtn.addEventListener(MouseEvent.CLICK,onNextClickHandler);
         _prevBtn.addEventListener(MouseEvent.CLICK,onPrevClickHandler);
      }
      
      private static function removeEvent() : void
      {
         _nextBtn.removeEventListener(MouseEvent.CLICK,onNextClickHandler);
         _prevBtn.removeEventListener(MouseEvent.CLICK,onPrevClickHandler);
      }
      
      private static function onNextClickHandler(param1:MouseEvent) : void
      {
         ++_curIndex;
         if(_curIndex >= _dialogA.length)
         {
            _nextBtn.visible = false;
            _nextBtn.stop();
            _prevBtn.visible = true;
            _prevBtn.play();
         }
         else
         {
            shwoTxt(_curIndex);
            if(_curIndex == _dialogA.length - 1)
            {
               _nextBtn.visible = false;
               _nextBtn.stop();
               _prevBtn.visible = true;
               _prevBtn.play();
            }
         }
      }
      
      private static function onPrevClickHandler(param1:MouseEvent) : void
      {
         --_curIndex;
         if(_curIndex < 0)
         {
            _nextBtn.visible = true;
            _nextBtn.play();
            _prevBtn.visible = false;
            _prevBtn.stop();
         }
         else
         {
            shwoTxt(_curIndex);
            if(_curIndex == 0)
            {
               _nextBtn.visible = true;
               _nextBtn.play();
               _prevBtn.visible = false;
               _prevBtn.stop();
            }
         }
      }
      
      private static function hide() : void
      {
         DisplayUtil.removeForParent(_bgMc);
         txtBox.removeAll();
         btnBox.removeAll();
      }
      
      private static function shwoTxt(param1:uint) : void
      {
         var _loc2_:* = null;
         var _loc3_:Number = 0;
         var _loc4_:String = null;
         var _loc5_:MLabel = null;
         var _loc6_:MLoadPane = null;
         txtBox.removeAll();
         var _loc7_:String = "    " + _dialogA[param1];
         var _loc8_:ParseDialogStr = new ParseDialogStr(_loc7_);
         var _loc9_:Number = 0;
         for each(_loc2_ in _loc8_.strArray)
         {
            _loc3_ = 0;
            while(_loc3_ < _loc2_.length)
            {
               _loc4_ = _loc2_.charAt(_loc3_);
               _loc5_ = new MLabel(_loc4_);
               _loc5_.textColor = uint("0x" + _loc8_.getColor(_loc9_));
               _loc5_.cacheAsBitmap = true;
               txtBox.append(_loc5_);
               _loc3_++;
            }
            _loc9_++;
            if(_loc8_.getEmotionNum(_loc9_) != -1)
            {
               _loc6_ = new MLoadPane(EmotionXMLInfo.getURL("#" + _loc8_.getEmotionNum(_loc9_)),MLoadPane.FIT_NONE,MLoadPane.MIDDLE,MLoadPane.MIDDLE);
               _loc6_.setSizeWH(45,40);
               txtBox.append(_loc6_);
            }
         }
      }
   }
}

