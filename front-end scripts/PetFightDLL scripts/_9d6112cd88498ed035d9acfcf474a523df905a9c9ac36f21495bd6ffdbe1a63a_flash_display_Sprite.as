package
{
   import flash.display.Sprite;
   import flash.system.Security;
   
   [ExcludeClass]
   public class _9d6112cd88498ed035d9acfcf474a523df905a9c9ac36f21495bd6ffdbe1a63a_flash_display_Sprite extends Sprite
   {
      
      public function _9d6112cd88498ed035d9acfcf474a523df905a9c9ac36f21495bd6ffdbe1a63a_flash_display_Sprite()
      {
         super();
      }
      
      public function allowDomainInRSL(... rest) : void
      {
         Security.allowDomain.apply(null,rest);
      }
      
      public function allowInsecureDomainInRSL(... rest) : void
      {
         Security.allowInsecureDomain.apply(null,rest);
      }
   }
}

