
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:permission_handler/permission_handler.dart';

class AgoraService {
  static const String appId = '8c11498e87284ee583132469e6005f54'; // ← Agora console'dan

  static RtcEngine? _engine;

  static Future<void> init() async {
    await Permission.microphone.request();

    _engine = createAgoraRtcEngine();
    
    await _engine!.initialize(RtcEngineContext(appId: appId));

    await _engine!.enableAudio();
    await _engine!.setClientRole(role: ClientRoleType.clientRoleBroadcaster);
    await _engine!.setAudioProfile(
      profile: AudioProfileType.audioProfileSpeechStandard, 
      scenario: AudioScenarioType.audioScenarioMeeting, 
    );
  }

  static Future<void> joinChannel(String channelId) async {
    await _engine!.adjustRecordingSignalVolume(100);
    await _engine!.adjustPlaybackSignalVolume(100);
    await _engine!.joinChannel(
      token: '',
      channelId: channelId,
      uid: 0,
      options: const ChannelMediaOptions(
        autoSubscribeAudio: true,
        publishMicrophoneTrack: true,
        clientRoleType: ClientRoleType.clientRoleBroadcaster,
      ),
    );
  }

  static Future<void> leaveChannel() async {
    await _engine!.leaveChannel();
  }

  static Future<void> dispose() async {
    await _engine!.release();
    _engine = null;
  }

  static Future<void> muteLocalAudio(bool mute) async {
    await _engine!.muteLocalAudioStream(mute);
  }

  static Future<void> setLoudspeaker(bool enable) async {
    await _engine!.setEnableSpeakerphone(enable);
  }
}