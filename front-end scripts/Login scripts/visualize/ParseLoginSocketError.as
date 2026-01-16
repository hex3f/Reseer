package visualize
{
   import flash.events.Event;
   import org.taomee.manager.EventManager;
   import register.RegisterManage;
   import tip.TipPanel;
   
   public class ParseLoginSocketError
   {
      
      public static const LOGIN_SEER_ERRORS:String = "login_seer_errors";
      
      public function ParseLoginSocketError()
      {
         super();
      }
      
      public static function parse(param1:int) : void
      {
         var _loc2_:String = null;
         trace("错误码————————————————————————————————",param1);
         switch(param1)
         {
            case 5001:
               _loc2_ = "系统错误";
               break;
            case 5002:
               _loc2_ = "号码已被注册";
               RegisterManage.curEmail = "";
               break;
            case 5003:
               _loc2_ = "密码错误";
               break;
            case 5004:
               _loc2_ = "号码尚未激活";
               break;
            case 5005:
               _loc2_ = "号码不存在";
               break;
            case 5006:
               _loc2_ = "号码被永久封停";
               break;
            case 5007:
               _loc2_ = "号码被24小时封停";
               break;
            case 5008:
               _loc2_ = "协议不对";
               break;
            case 5009:
               _loc2_ = "密码输错次数太多";
               break;
            case 5010:
               _loc2_ = "不合法的昵称";
               EventManager.dispatchEvent(new Event("name_error"));
               break;
            case 5011:
               _loc2_ = "服务器维护";
               break;
            case 5012:
               _loc2_ = "非法的邀请码";
               break;
            case 2003:
               _loc2_ = "系统错误";
               break;
            case 1301:
               _loc2_ = "你的电子邮箱已经注册过";
               RegisterManage.curEmail = "";
               break;
            case -20012:
               _loc2_ = "你今天注册的米米号太多了";
               RegisterManage.curEmail = "";
               break;
            case 20002:
               _loc2_ = "邀请码有误，请重新输入。";
               RegisterManage.curEmail = "";
               break;
            case 5013:
               _loc2_ = "你的号码被永久封停";
               break;
            case 5014:
               _loc2_ = "你的号码被24小时封停";
               break;
            case 5015:
               _loc2_ = "你的号码被7天封停";
               break;
            case 5016:
               _loc2_ = "你的号码被14天封停";
               break;
            case 6000:
               _loc2_ = "邮箱已存在";
               break;
            case 6001:
               _loc2_ = "验证码已发送";
               break;
            case 6002:
               _loc2_ = "验证码错误";
               break;
            case 700002:
               _loc2_ = "正在保存存档, 请稍后";
               break;
            case 700003:
               _loc2_ = "暂不支持此邮箱注册,请检查是否为正确邮箱！";
               break;
            case 700004:
               _loc2_ = "邮箱包含非法字符";
               break;
            default:
               _loc2_ = param1.toString();
         }
         TipPanel.createTipPanel(_loc2_);
      }
   }
}

