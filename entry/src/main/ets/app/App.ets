import { AbilityStage, Configuration, ConfigurationConstant } from "@kit.AbilityKit";
import { AppConfig } from "../config/AppConfig";
import { Repository } from "../data/Repository";
import { AppPrefer } from "../prefer/AppPrefer";
import { AVPlayerKit, AVPlayerFactory, AVPlayer, AVRenderType, AVCodecType } from '@ohpg/player'
import { AppPlayer } from '../player/AppPlayer'
import { AppMediaResolver } from '../player/AppMediaResolver'
import { Logger, ConsoleLogOutput } from '@ohpg/core'
import BuildProfile from 'BuildProfile'

/**
 * @Author peerless2012
 * @Email peerless2012@126.com
 * @DateTime 2024/11/7 21:01
 * @Version V1.0
 * @Description
 */
export class App extends AbilityStage {

  onCreate(): void {
    // https://developer.huawei.com/consumer/cn/doc/harmonyos-guides-V5/arkts-light-dark-color-adaptation-V5#section1421172621111
    this.context.getApplicationContext().setColorMode(ConfigurationConstant.ColorMode.COLOR_MODE_NOT_SET);
    const appContext = this.context.getApplicationContext()
    // 初始化播放器库
    AVPlayerKit.init(appContext, new AppPlayerFactoryImpl())
    // Logger
    const logger = new Logger(Logger.DEFAULT_BUFFER_CAPACITY, BuildProfile.DEBUG)
    logger.addOutput(new ConsoleLogOutput())
    AppStorage.setOrCreate(Logger.LOGGER_KEY, logger)
    AppStorage.setOrCreate(AppPrefer.PREFER, new AppPrefer(appContext))
    AppStorage.setOrCreate(AppConfig.CONFIG, new AppConfig(appContext))
    const repository = new Repository(appContext)
    AppStorage.setOrCreate(Repository.REPOSITORY, repository)
    // MediaResolver（全局注册，用于解析播放 URL）
    AVPlayerKit.setMediaResolver(new AppMediaResolver(repository))
  }

  onConfigurationUpdate(newConfig: Configuration): void {
  }

}

class AppPlayerFactoryImpl implements AVPlayerFactory {
  create(context: Context, render: AVRenderType, codec?: AVCodecType): AVPlayer {
    return new AppPlayer(context, render, codec)
  }
}