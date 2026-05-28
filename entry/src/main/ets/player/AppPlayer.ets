import { AVCodecType, AVRenderType } from '@ohpg/player'
import { ProxyPlayer } from 'entry/ProxyPlayer'

export class AppPlayer extends ProxyPlayer {

  constructor(context: Context, type: AVRenderType, codecPrefer?: AVCodecType) {
    super(context, type, codecPrefer)
  }

}
