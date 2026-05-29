import { AVCodecType, AVPlayer, AVPlayerFactory, AVRenderType } from "@ohpg/player";
import { AppPlayer } from "./AppPlayer";

export class AppPlayerFactory implements AVPlayerFactory {
  create(context: Context, render: AVRenderType, codec?: AVCodecType): AVPlayer {
    return new AppPlayer(context, render, codec)
  }
}