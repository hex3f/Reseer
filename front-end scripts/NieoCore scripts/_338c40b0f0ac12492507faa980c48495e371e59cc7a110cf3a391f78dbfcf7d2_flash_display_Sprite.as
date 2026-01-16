package
{
   import flash.display.Sprite;
   import flash.system.Security;
   
   [ExcludeClass]
   public class _338c40b0f0ac12492507faa980c48495e371e59cc7a110cf3a391f78dbfcf7d2_flash_display_Sprite extends Sprite
   {
      
      public function _338c40b0f0ac12492507faa980c48495e371e59cc7a110cf3a391f78dbfcf7d2_flash_display_Sprite()
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

