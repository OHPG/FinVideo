import { AbilityStage, Configuration, ConfigurationConstant } from "@kit.AbilityKit";
import { AppPrefer } from "../prefer/AppPrefer";

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
    AppStorage.setOrCreate(AppPrefer.PREFER, new AppPrefer(this.context.getApplicationContext()))
  }

  onConfigurationUpdate(newConfig: Configuration): void {
  }

}