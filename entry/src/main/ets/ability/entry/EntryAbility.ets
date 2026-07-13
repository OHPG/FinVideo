import { AbilityConstant, UIAbility, Want } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { window } from '@kit.ArkUI';
import { BreakpointSystem, AvoidAreaSystem } from '@ohpg/fin-core';

import { DeviceUtil } from '@ohpg/fin-framework';
import { AVPlayerKit, AVPlaybackManager } from '@ohpg/player';
import { AppPlayerManager } from '../../player/AppPlayerManager';
import { AppMediaResolver } from '../../player/AppMediaResolver';
import { Repository } from '../../data/Repository';
import { AppPrefer } from '../../prefer/AppPrefer';

export default class EntryAbility extends UIAbility {

  private windowStage?: window.WindowStage

  private breakpointSystem: BreakpointSystem = new BreakpointSystem();

  private avoidAreaSystem: AvoidAreaSystem = new AvoidAreaSystem();

  private playerManager?: AppPlayerManager

  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onCreate');
  }

  onDestroy(): void {
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onDestroy');
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    // Main window is created, set main page for this ability
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onWindowStageCreate');
    this.windowStage = windowStage
    let mainWindow = windowStage.getMainWindowSync()
    DeviceUtil.initWindow(mainWindow)
    mainWindow.setImmersiveModeEnabledState(true)
    this.avoidAreaSystem.register(mainWindow)
    windowStage.loadContent('pages/splash/SplashPage', (err) => {
      if (err.code) {
        hilog.error(0x0000, 'testTag', 'Failed to load the content. Cause: %{public}s', JSON.stringify(err) ?? '');
        return;
      }
      this.playerManager = new AppPlayerManager(mainWindow.getUIContext())
      AppStorage.setOrCreate(AVPlaybackManager.AV_PLAYER_MANAGER, this.playerManager)
      // 注册 MediaResolver（需要 UIContext 用于版本选择弹框）
      const repository = AppStorage.get<Repository>(Repository.REPOSITORY)!
      const appPrefer = AppStorage.get<AppPrefer>(AppPrefer.PREFER)!
      AVPlayerKit.setMediaResolver(new AppMediaResolver(mainWindow.getUIContext(), repository, appPrefer))
      this.breakpointSystem.register(mainWindow);
      hilog.info(0x0000, 'testTag', 'Succeeded in loading the content.');
    });
  }

  onWindowStageWillDestroy(windowStage: window.WindowStage): void {
    AVPlayerKit.setMediaResolver(undefined)
    this.windowStage = undefined
    DeviceUtil.initWindow(undefined)
    this.avoidAreaSystem.unregister()
    this.breakpointSystem.unregister()
    this.playerManager?.release()
  }

  onWindowStageDestroy(): void {
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
