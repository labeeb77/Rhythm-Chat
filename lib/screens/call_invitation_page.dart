import 'package:talk_hub/api/apis.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';
import 'package:zego_uikit_signaling_plugin/zego_uikit_signaling_plugin.dart';

class Zego {
 static void initZego(){
  ZegoUIKitPrebuiltCallInvitationService().init(
    appID: 822532266 /*input your AppID*/,
    appSign: 'e1e8a1102581070d2332bbea0191c44eaf64f139be738979a3dfd1b57f4ee469' /*input your AppSign*/,
    userID: APIs.me.id,
    userName: APIs.me.name,
    plugins: [ZegoUIKitSignalingPlugin()],
   
  );

 }
}