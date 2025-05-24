import { StartupConfig, StartupConfigEntry } from '@kit.AbilityKit';
import { BusinessError } from '@ohos.base';

/**
 * @Author peerless2012
 * @Email peerless2012@126.com
 * @DateTime 2024/11/9 21:20
 * @Version V1.0
 * @Description
 */
export class AppStartupConfig extends StartupConfigEntry {

  private onCompleteCallback = (error: BusinessError<void>) => {
    console.log("AppStartupConfig: onComplete.")
  }

  onConfig(): StartupConfig {
    console.log("AppStartupConfig: onConfig.")
    let config: StartupConfig = {
      timeoutMs: 10000,
      startupListener: {onCompleted: this.onCompleteCallback}
    }
    return config
  }

}