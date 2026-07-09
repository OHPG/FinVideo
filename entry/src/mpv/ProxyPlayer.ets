import { MPVLib, MpvPlayer } from "@ohpg/mpv";
import { AVCodecType, AVRenderType } from "@ohpg/player";
import BuildProfile from "entry/BuildProfile";

/**
 * @Author peerless2012
 * @Email peerless2012@126.com
 * @DateTime 2026/3/31 21:46
 * @Version V1.0
 * @Description
 */
export class ProxyPlayer extends MpvPlayer {
  constructor(context: Context, type: AVRenderType, codecPrefer?: AVCodecType) {
    super(context, type, codecPrefer)
    MPVLib.DEBUG = BuildProfile.DEBUG
  }
}