package com.robot.app.mapProcess
{
   import com.robot.app.fightNote.FightInviteManager;
   import com.robot.app.task.taskUtils.taskDialog.NpcTipDialog;
   import com.robot.core.aimat.AimatController;
   import com.robot.core.animate.AnimateManager;
   import com.robot.core.config.ClientConfig;
   import com.robot.core.config.xml.ItemXMLInfo;
   import com.robot.core.event.AimatEvent;
   import com.robot.core.event.RobotEvent;
   import com.robot.core.manager.LevelManager;
   import com.robot.core.manager.MainManager;
   import com.robot.core.manager.MapManager;
   import com.robot.core.manager.map.MapLibManager;
   import com.robot.core.manager.map.config.BaseMapProcess;
   import com.robot.core.mode.BasePeoleModel;
   import com.robot.core.mode.SpriteModel;
   import com.robot.core.mode.spriteModelAdditive.SpriteBloodBar;
   import com.robot.core.ui.alert.Alarm;
   import com.robot.core.ui.alert.ItemInBagAlert;
   import com.robot.core.utils.ArrayUtils;
   import com.robot.core.utils.NumberUtils;
   import com.robot.core.utils.TextFormatUtil;
   import flash.display.MovieClip;
   import flash.display.SimpleButton;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.geom.Point;
   import flash.media.Sound;
   import flash.media.SoundChannel;
   import flash.net.URLRequest;
   import flash.utils.ByteArray;
   import flash.utils.clearTimeout;
   import flash.utils.setTimeout;
   import gs.TweenLite;
   import gs.easing.Back;
   import org.taomee.events.SocketEvent;
   import org.taomee.manager.ToolTipManager;
   import org.taomee.utils.AlignType;
   import org.taomee.utils.DisplayUtil;
   
   public class MapProcess_329 extends BaseMapProcess
   {
      
      private var musicArr:Array = [0,0,0,1,2];
      
      private var pointArr:Array = [[{
         "x":407,
         "y":275
      },{
         "x":400,
         "y":317
      },{
         "x":390,
         "y":360
      }],[{
         "x":492,
         "y":275
      },{
         "x":492,
         "y":317
      },{
         "x":492,
         "y":360
      }],[{
         "x":574,
         "y":275
      },{
         "x":579,
         "y":317
      },{
         "x":587,
         "y":360
      }]];
      
      private var hp:int = 300;
      
      private var maxHp:int = 0;
      
      private var seerBloodBar:SpriteBloodBar;
      
      private var switchB:Boolean;
      
      private var switchMC:MovieClip;
      
      private var pearMC:MovieClip;
      
      private var seerMC:MovieClip;
      
      private var musicMC:MovieClip;
      
      private var isStop:Boolean;
      
      private var stopBtn:SimpleButton;
      
      private var _sound:Sound;
      
      private var _soundC:SoundChannel;
      
      private var isHit:Boolean = false;
      
      private var isHitPillar:Boolean;
      
      private var isHitPear:Boolean;
      
      private var isHitArr:Array = [];
      
      private var currentHitMC:MovieClip;
      
      private var hitCount:uint = 0;
      
      private var bloodBar:MovieClip;
      
      private var isHitedPillar:MovieClip;
      
      private var tempPillar:MovieClip;
      
      private var clickIng:Boolean = false;
      
      private var getMusicArr:Array = [];
      
      private var bossOut:Boolean = false;
      
      private var bigBossMC:MovieClip;
      
      public function MapProcess_329()
      {
         super();
      }
      
      private function playSound(param1:String) : void
      {
         if(Boolean(this._soundC))
         {
            this._soundC.stop();
            this._soundC = null;
            this._sound = null;
         }
         this._sound = new Sound();
         this._sound.load(new URLRequest(ClientConfig.getResPath("music/" + param1 + ".mp3")));
         this._soundC = this._sound.play();
      }
      
      private function onWalk(param1:RobotEvent) : void
      {
         var _loc2_:Point = MainManager.actorModel.sprite.localToGlobal(new Point());
         if(this.switchB && !this.isHit)
         {
            if(this.switchMC.hitTestPoint(_loc2_.x,_loc2_.y,true))
            {
               if(this.pearMC.currentFrame == 1 || this.pearMC.currentFrame == 35)
               {
                  this.pearMC.gotoAndPlay(2);
                  this.switchMC.gotoAndStop(2);
                  this.playSound("pearhit");
               }
               this.isHit = true;
            }
         }
         if(this.isHitPear || this.isHitPillar)
         {
            if(MainManager.actorInfo.superNono)
            {
               this.playHittedEffect(_loc2_);
            }
         }
      }
      
      private function onWalkEnd(param1:RobotEvent) : void
      {
         this.isHit = false;
      }
      
      override protected function init() : void
      {
         var _loc1_:Number = NaN;
         this.switchB = true;
         this.isStop = false;
         this.isHit = false;
         AimatController.addEventListener(AimatEvent.PLAY_END,this.onAimatHandler);
         MainManager.actorModel.addEventListener(RobotEvent.WALK_ENTER_FRAME,this.onWalk);
         MainManager.actorModel.addEventListener(RobotEvent.WALK_END,this.onWalkEnd);
         this.seerBloodBar = new SpriteBloodBar(MapLibManager.getMovieClip("BloodBar"),-50,-80);
         this.hp = 200;
         this.maxHp = 200;
         this.seerBloodBar.setHp(this.hp,this.maxHp);
         (MainManager.actorModel.sprite as SpriteModel).additive = [this.seerBloodBar];
         var _loc2_:Number = 0;
         while(_loc2_ < 6)
         {
            conLevel["music_" + _loc2_].addEventListener(MouseEvent.CLICK,this.onMusicMCFrameHandler);
            conLevel["music_" + _loc2_].buttonMode = true;
            _loc2_++;
         }
         var _loc3_:Number = 0;
         while(_loc3_ < 3)
         {
            _loc1_ = Number(NumberUtils.random(0,2));
            conLevel["pillarmc_" + _loc3_].x = this.pointArr[_loc3_][_loc1_].x;
            conLevel["pillarmc_" + _loc3_].y = this.pointArr[_loc3_][_loc1_].y;
            conLevel["pillarmc_" + _loc3_].addEventListener(Event.ENTER_FRAME,this.onPillarMCFrameHandler);
            _loc3_++;
         }
         this.switchMC = conLevel["switch_mc"];
         this.pearMC = conLevel["pear_mc"];
         topLevel.addEventListener(Event.ENTER_FRAME,this.onFrameHandler);
         this.seerMC = BasePeoleModel(MainManager.actorModel.sprite).skeleton.getSkeletonMC();
         this.musicMC = conLevel["music_btn"];
         this.musicMC.gotoAndStop(1);
         this.musicMC.buttonMode = true;
         ToolTipManager.add(this.musicMC,"解读琴谱路");
         this.musicMC.addEventListener(MouseEvent.CLICK,this.onMusicHandler);
         this.stopBtn = conLevel["stop_btn"];
         ToolTipManager.add(this.stopBtn,"暂停机关5秒钟");
         this.stopBtn.addEventListener(MouseEvent.CLICK,this.onStopHandler);
         topLevel["hittedEffect"].visible = false;
         NpcTipDialog.show("主人，宝盒里似乎有很多机关和陷阱！试试用头部射击去破坏它们或许会有意外的收获哦！",null,NpcTipDialog.NONO);
      }
      
      private function onStopHandler(param1:MouseEvent) : void
      {
         var t1:uint = 0;
         t1 = 0;
         var e:MouseEvent = param1;
         this.isStop = true;
         this.switchB = false;
         this.stopBtn.removeEventListener(MouseEvent.CLICK,this.onStopHandler);
         t1 = setTimeout(function():void
         {
            isStop = false;
            if(Boolean(switchMC))
            {
               switchB = true;
            }
            stopBtn.addEventListener(MouseEvent.CLICK,onStopHandler);
            clearTimeout(t1);
         },5000);
      }
      
      private function playHitEffect(param1:Point) : void
      {
      }
      
      private function playHittedEffect(param1:Point, param2:Boolean = false) : void
      {
         var pp:Point = param1;
         var b:Boolean = param2;
         topLevel["hittedEffect"].x = pp.x;
         topLevel["hittedEffect"].y = pp.y;
         if(b)
         {
            topLevel["hittedEffect"].visible = true;
            this.playSound("ishitted");
            AnimateManager.playMcAnimate(topLevel["hittedEffect"],1,"mc",function():void
            {
               topLevel["hittedEffect"].visible = false;
            });
         }
      }
      
      private function pillarMCHitTest() : void
      {
         var _loc1_:Point = null;
         var _loc2_:Point = null;
         var _loc3_:Number = 0;
         while(_loc3_ < 3)
         {
            _loc1_ = this.seerMC.localToGlobal(new Point());
            if(Boolean(conLevel["pillarmc_" + _loc3_]["mc"]))
            {
               _loc2_ = conLevel["pillarmc_" + _loc3_]["mc"].localToGlobal(new Point());
               if(Point.distance(_loc1_,_loc2_) < 30)
               {
                  if(!this.isHitPillar)
                  {
                     this.isHitPillar = true;
                     if(MainManager.actorInfo.superNono)
                     {
                        this.hp -= 20;
                        this.seerBloodBar.setHp(this.hp,this.maxHp,20);
                        this.playHittedEffect(_loc1_,true);
                     }
                     else
                     {
                        this.hp -= 30;
                        this.seerBloodBar.setHp(this.hp,this.maxHp,30);
                     }
                     TweenLite.to(this.seerMC,1.5,{
                        "alpha":0.3,
                        "ease":Back.easeOut,
                        "onComplete":this.revertAlpha
                     });
                  }
               }
            }
            _loc3_++;
         }
      }
      
      private function revertAlpha() : void
      {
         this.isHitPillar = false;
         this.isHitPear = false;
         TweenLite.to(this.seerMC,0.3,{
            "alpha":1,
            "ease":Back.easeIn
         });
      }
      
      private function pearHitTest() : void
      {
         var _loc1_:Point = null;
         var _loc2_:Point = this.seerMC.localToGlobal(new Point());
         var _loc3_:MovieClip = this.pearMC.getChildByName("pear") as MovieClip;
         if(Boolean(_loc3_))
         {
            _loc1_ = _loc3_["mc"].localToGlobal(new Point());
         }
         if(Point.distance(_loc2_,_loc1_) < 130)
         {
            if(!this.isHitPear)
            {
               this.isHitPear = true;
               if(MainManager.actorInfo.superNono)
               {
                  this.hp -= 30;
                  this.seerBloodBar.setHp(this.hp,this.maxHp,30);
                  this.playHittedEffect(_loc2_,true);
               }
               else
               {
                  this.hp -= 50;
                  this.seerBloodBar.setHp(this.hp,this.maxHp,50);
               }
               TweenLite.to(this.seerMC,1.5,{
                  "alpha":0.3,
                  "ease":Back.easeOut,
                  "onComplete":this.revertAlpha
               });
            }
         }
      }
      
      private function onPillarMCFrameHandler(param1:Event) : void
      {
         var mc:MovieClip = null;
         var t2:uint = 0;
         mc = null;
         var seedInt:Number = NaN;
         var index:uint = 0;
         t2 = 0;
         var e:Event = param1;
         mc = e.target as MovieClip;
         if(!this.isStop)
         {
            if(mc["mc"].currentFrame == mc["mc"].totalFrames)
            {
               seedInt = Number(NumberUtils.random(0,2));
               index = uint(mc.name.split("_")[1]);
               mc.x = this.pointArr[index][seedInt].x;
               mc.y = this.pointArr[index][seedInt].y;
            }
         }
         else
         {
            mc["mc"].gotoAndStop(1);
            t2 = setTimeout(function():void
            {
               clearTimeout(t2);
               mc["mc"].gotoAndPlay(2);
            },5000);
         }
      }
      
      private function onGetExpHandler(param1:SocketEvent) : void
      {
         var mc:MovieClip = null;
         mc = null;
         var e:SocketEvent = param1;
         var by:ByteArray = e.data as ByteArray;
         var exp:int = int(by.readUnsignedInt());
         var _str:String = TextFormatUtil.getRedTxt(String(exp));
         if(MainManager.actorInfo.superNono)
         {
            mc = MapLibManager.getMovieClip("SuperAlarm");
            mc["exp_txt"].htmlText = _str + "经验已经存入你的经验分配器中";
            mc["close_btn"].addEventListener(MouseEvent.CLICK,function():void
            {
               mc["close_btn"].removeEventListener(MouseEvent.CLICK,arguments.callee);
               DisplayUtil.removeForParent(mc);
               mc = null;
            });
            LevelManager.appLevel.addChild(mc);
            DisplayUtil.align(mc,null,AlignType.MIDDLE_CENTER);
         }
         else
         {
            Alarm.show(_str + "经验已经存入你的经验分配器中");
         }
      }
      
      private function onGetItemHandler(param1:SocketEvent) : void
      {
      }
      
      private function showAwardItem(param1:Array) : void
      {
         var arr:Array = null;
         arr = param1;
         var obj:Object = arr.shift();
         if(arr.length > 0)
         {
            ItemInBagAlert.show(obj.id,"<font color=\'#ff0000\'>" + obj.num + "</font>个<font color=\'#ff0000\'>" + ItemXMLInfo.getName(obj.id) + "</font>放入到你的背包中",function():void
            {
               showAwardItem(arr);
            });
         }
      }
      
      private function controlBloodBar(param1:int = 0, param2:int = 1, param3:Boolean = false) : void
      {
         var _loc4_:Point = null;
         if(param3)
         {
            if(Boolean(this.bloodBar))
            {
               DisplayUtil.removeForParent(this.bloodBar);
               this.bloodBar = null;
            }
            this.bloodBar = MapLibManager.getMovieClip("BloodBar");
            this.bloodBar["barMC"].gotoAndStop(1);
            _loc4_ = this.currentHitMC.localToGlobal(new Point(0,0));
            if(_loc4_.x > 600)
            {
               this.bloodBar.x = _loc4_.x - this.bloodBar.width / 2;
            }
            else
            {
               this.bloodBar.x = _loc4_.x;
            }
            this.bloodBar.y = _loc4_.y - 50;
            conLevel.addChild(this.bloodBar);
         }
         var _loc5_:int = int(this.bloodBar["barMC"].currentFrame);
         if(MainManager.actorInfo.superNono)
         {
            param1 *= param2;
         }
         this.bloodBar["barMC"].gotoAndStop(_loc5_ + param1);
         if(this.bloodBar["barMC"].currentFrame >= this.bloodBar["barMC"].totalFrames)
         {
            DisplayUtil.removeForParent(this.bloodBar);
         }
      }
      
      private function onAimatHandler(param1:AimatEvent) : void
      {
         var p:Point = null;
         var id:uint = 0;
         var i:uint = 0;
         var t3:uint = 0;
         var t4:uint = 0;
         t3 = 0;
         t4 = 0;
         var e:AimatEvent = param1;
         if(MainManager.actorID != e.info.userID)
         {
            return;
         }
         p = e.info.endPos;
         id = uint(e.info.id);
         i = 0;
         while(i < 3)
         {
            this.isHitedPillar = conLevel["pillarmc_" + i];
            if(Boolean(this.isHitedPillar["mc"]))
            {
               if(Boolean(this.isHitedPillar["mc"]["hit_mc"]))
               {
                  if(Boolean(this.isHitedPillar["mc"]["hit_mc"].hitTestPoint(p.x,p.y)))
                  {
                     this.playSound("hit");
                     if(Boolean(this.tempPillar))
                     {
                        if(this.tempPillar != this.isHitedPillar)
                        {
                           this.tempPillar.addEventListener(Event.ENTER_FRAME,this.onPillarMCFrameHandler);
                           this.tempPillar["mc"].gotoAndPlay(1);
                        }
                     }
                     this.tempPillar = this.isHitedPillar;
                     this.isHitedPillar.removeEventListener(Event.ENTER_FRAME,this.onPillarMCFrameHandler);
                     this.isHitedPillar["mc"].gotoAndStop(15);
                     if(Boolean(this.currentHitMC))
                     {
                        if(this.currentHitMC != this.isHitedPillar["mc"]["hit_mc"])
                        {
                           this.currentHitMC = this.isHitedPillar["mc"]["hit_mc"];
                           this.controlBloodBar(0,2,true);
                           this.hitCount = 0;
                        }
                     }
                     else
                     {
                        this.currentHitMC = this.isHitedPillar["mc"]["hit_mc"];
                        this.controlBloodBar(0,2,true);
                        this.hitCount = 0;
                     }
                     ++this.hitCount;
                     this.controlBloodBar(5,2);
                     if(MainManager.actorInfo.superNono)
                     {
                        if(this.hitCount >= 3)
                        {
                           this.hitCount = 0;
                           DisplayUtil.removeForParent(this.bloodBar);
                           this.bloodBar = null;
                           this.tempPillar = null;
                           this.isHitedPillar.gotoAndStop(2);
                           t3 = setTimeout(function():void
                           {
                              clearTimeout(t3);
                           },300);
                        }
                     }
                     else if(this.hitCount >= 6)
                     {
                        t4 = setTimeout(function():void
                        {
                           clearTimeout(t4);
                        },300);
                        this.hitCount = 0;
                        DisplayUtil.removeForParent(this.bloodBar);
                        this.bloodBar = null;
                        this.tempPillar = null;
                        this.isHitedPillar.gotoAndStop(2);
                     }
                  }
               }
            }
            i++;
         }
         if(Boolean(this.switchMC))
         {
            if(this.switchMC.hitTestPoint(p.x,p.y))
            {
               this.playSound("hitingswitch");
               if(Boolean(this.currentHitMC))
               {
                  if(this.currentHitMC != this.switchMC)
                  {
                     this.currentHitMC = this.switchMC;
                     this.controlBloodBar(0,6,true);
                     this.hitCount = 0;
                  }
               }
               else
               {
                  this.currentHitMC = this.switchMC;
                  this.controlBloodBar(0,6,true);
                  this.hitCount = 0;
               }
               ++this.hitCount;
               this.switchMC.gotoAndStop(2);
               this.controlBloodBar(6,5);
               if(MainManager.actorInfo.superNono)
               {
                  if(this.hitCount >= 1)
                  {
                     this.hitCount = 0;
                     DisplayUtil.removeForParent(this.bloodBar);
                     this.bloodBar = null;
                     this.switchMC.gotoAndStop(3);
                     this.switchMC = null;
                     this.switchB = false;
                     this.playSound("hitswitch");
                  }
               }
               else if(this.hitCount >= 5)
               {
                  this.hitCount = 0;
                  DisplayUtil.removeForParent(this.bloodBar);
                  this.bloodBar = null;
                  this.switchMC.gotoAndStop(3);
                  this.switchMC = null;
                  this.switchB = false;
                  this.playSound("hitswitch");
               }
            }
         }
         if(Boolean(this.bigBossMC))
         {
            if(this.bigBossMC.hitTestPoint(p.x,p.y))
            {
               this.playSound("hit");
               if(Boolean(this.currentHitMC))
               {
                  if(this.currentHitMC != this.bigBossMC)
                  {
                     this.currentHitMC = this.bigBossMC;
                     this.controlBloodBar(0,2,true);
                     this.hitCount = 0;
                  }
               }
               else
               {
                  this.currentHitMC = this.bigBossMC;
                  this.controlBloodBar(0,2,true);
                  this.hitCount = 0;
               }
               ++this.hitCount;
               this.controlBloodBar(3,2);
               if(MainManager.actorInfo.superNono)
               {
                  if(this.hitCount >= 5)
                  {
                     this.hitCount = 0;
                     DisplayUtil.removeForParent(this.bloodBar);
                     this.bloodBar = null;
                     this.currentHitMC = null;
                  }
               }
               else if(this.hitCount >= 10)
               {
                  this.hitCount = 0;
                  DisplayUtil.removeForParent(this.bloodBar);
                  this.bloodBar = null;
                  this.currentHitMC = null;
               }
            }
         }
      }
      
      private function onFrameHandler(param1:Event) : void
      {
         if(!this.isStop)
         {
            this.pillarMCHitTest();
            this.pearHitTest();
            if(this.hp <= 0)
            {
               topLevel.removeEventListener(Event.ENTER_FRAME,this.onFrameHandler);
               this.playOverEffect();
            }
         }
      }
      
      override public function destroy() : void
      {
         AimatController.removeEventListener(AimatEvent.PLAY_END,this.onAimatHandler);
         MainManager.actorModel.removeEventListener(RobotEvent.WALK_ENTER_FRAME,this.onWalk);
         MainManager.actorModel.removeEventListener(RobotEvent.WALK_END,this.onWalkEnd);
         topLevel.removeEventListener(Event.ENTER_FRAME,this.onFrameHandler);
         var _loc1_:Number = 0;
         while(_loc1_ < 3)
         {
            conLevel["pillarmc_" + _loc1_].removeEventListener(Event.ENTER_FRAME,this.onPillarMCFrameHandler);
            _loc1_++;
         }
         var _loc2_:Number = 0;
         while(_loc2_ < 6)
         {
            conLevel["music_" + _loc2_].removeEventListener(MouseEvent.CLICK,this.onMusicMCFrameHandler);
            _loc2_++;
         }
         this.seerBloodBar.destroy();
         this.getMusicArr = [];
         this.bossOut = false;
      }
      
      private function onMusicMCFrameHandler(param1:MouseEvent) : void
      {
         var mc:MovieClip = null;
         var t5:uint = 0;
         t5 = 0;
         var e:MouseEvent = param1;
         var effectFinish:Boolean = false;
         if(this.clickIng)
         {
            return;
         }
         mc = e.target as MovieClip;
         this.clickIng = true;
         t5 = setTimeout(function():void
         {
            clickIng = false;
            clearTimeout(t5);
         },800);
         if(this.getMusicArr.length == 5)
         {
            this.getMusicArr.shift();
         }
         switch(mc.name)
         {
            case "music_0":
               this.getMusicArr.push(0);
               this.playSound("1");
               AnimateManager.playMcAnimate(conLevel["music_mc"],1,"mc1",function():void
               {
                  musicResult();
               });
               break;
            case "music_1":
               this.getMusicArr.push(1);
               this.playSound("2");
               AnimateManager.playMcAnimate(conLevel["music_mc"],2,"mc2",function():void
               {
                  musicResult();
               });
               break;
            case "music_2":
               this.getMusicArr.push(2);
               this.playSound("3");
               AnimateManager.playMcAnimate(conLevel["music_mc"],3,"mc3",function():void
               {
                  musicResult();
               });
               break;
            case "music_3":
               this.getMusicArr.push(3);
               this.playSound("4");
               AnimateManager.playMcAnimate(conLevel["music_mc"],4,"mc4",function():void
               {
                  musicResult();
               });
               break;
            case "music_4":
               this.getMusicArr.push(4);
               this.playSound("5");
               AnimateManager.playMcAnimate(conLevel["music_mc"],5,"mc5",function():void
               {
                  musicResult();
               });
               break;
            case "music_5":
               this.getMusicArr.push(5);
               this.playSound("6");
               AnimateManager.playMcAnimate(conLevel["music_mc"],6,"mc6",function():void
               {
                  musicResult();
               });
         }
      }
      
      private function onFightBossHandler(param1:MouseEvent) : void
      {
         if(Boolean(MapManager.currentMap.id))
         {
            FightInviteManager.fightWithBoss("厄斯");
         }
      }
      
      private function musicResult() : void
      {
         if(this.getMusicArr.length == 5)
         {
            if(Boolean(ArrayUtils.eq(this.getMusicArr,this.musicArr)) && !this.bossOut)
            {
               this.playSound("boss1");
               AnimateManager.playMcAnimate(conLevel["monster_mc"],2,"smallBoss_mc",function():void
               {
                  bossOut = true;
                  var _loc1_:MovieClip = conLevel["monster_mc"]["smallBoss_mc"];
                  _loc1_["mc"].buttonMode = true;
                  _loc1_["mc"].addEventListener(MouseEvent.CLICK,onFightBossHandler);
               });
            }
         }
         if(this.getMusicArr.length == 3)
         {
            this.playSound("boss2");
            AnimateManager.playMcAnimate(conLevel["monster_mc"],3,"bigBoss_mc",function():void
            {
               bigBossMC = conLevel["monster_mc"]["bigBoss_mc"]["mc"];
               if(MainManager.actorInfo.superNono)
               {
                  hp -= 30;
                  seerBloodBar.setHp(hp,maxHp,30);
               }
               else
               {
                  hp -= 50;
                  seerBloodBar.setHp(hp,maxHp,50);
               }
               TweenLite.to(seerMC,1,{
                  "alpha":0.3,
                  "ease":Back.easeOut,
                  "onComplete":revertAlpha
               });
            });
         }
      }
      
      private function playOverEffect() : void
      {
         AnimateManager.playFullScreenAnimate(ClientConfig.getFullMovie("overeffect"),function():void
         {
            MapManager.changeMap(1);
         });
      }
      
      private function onMusicHandler(param1:MouseEvent) : void
      {
         var e:MouseEvent = param1;
         AnimateManager.playMcAnimate(conLevel["music_btn"],2,"mc",function():void
         {
         });
      }
   }
}

