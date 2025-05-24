import { AbilityConstant, UIAbility, Want } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { window } from '@kit.ArkUI';
import { BreakpointSystem } from '@ohpg/fin-core';
import { AvoidAreaSystem } from '@ohpg/fin-core';
import { DeviceUtil } from '@ohpg/fin-framework';

export default class EntryAbility extends UIAbility {

  private breakpointSystem: BreakpointSystem = new BreakpointSystem();

  private avoidAreaSystem: AvoidAreaSystem = new AvoidAreaSystem();

  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onCreate');
  }

  onDestroy(): void {
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onDestroy');
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    // Main window is created, set main page for this ability
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onWindowStageCreate');
    let window = windowStage.getMainWindowSync()
    DeviceUtil.initWindow(window)
    window.setImmersiveModeEnabledState(true)
    this.avoidAreaSystem.register(windowStage.getMainWindowSync())
    windowStage.loadContent('pages/splash/SplashPage', (err) => {
      if (err.code) {
        hilog.error(0x0000, 'testTag', 'Failed to load the content. Cause: %{public}s', JSON.stringify(err) ?? '');
        return;
      }
      this.breakpointSystem.register(window);
      hilog.info(0x0000, 'testTag', 'Succeeded in loading the content.');
    });
  }

  onWindowStageDestroy(): void {
    DeviceUtil.initWindow(undefined)
    this.avoidAreaSystem.unregister()
    this.breakpointSystem.unregister()
    // Main window is destroyed, release UI related resources
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onWindowStageDestroy');
  }

  onForeground(): void {
    // Ability has brought to foreground
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onForeground');
  }

  onBackground(): void {
    // Ability has back to background
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onBackground');
  }
}
