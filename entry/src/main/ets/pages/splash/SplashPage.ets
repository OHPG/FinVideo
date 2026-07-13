import { PrivacyDialog } from '@ohpg/fin-framework'
import { Repository } from '../../data/Repository'
import { AppPrefer } from '../../prefer/AppPrefer'
import { AppRouter } from '../../router/AppRouter'

@Entry
@Component
struct SplashPage {

  private appPrefer: AppPrefer = AppStorage.get(AppPrefer.PREFER)!

  private privacyDialog: PrivacyDialog = new PrivacyDialog(this.getUIContext())

  aboutToAppear(): void {
    if (this.appPrefer.isPrivacyGrant()) {
      this.initAndWait()
    } else {
      let resourceManager = getContext().resourceManager
      let privacyUrl = resourceManager.getStringSync($r('app.string.privacy'))
      this.privacyDialog.setAppInfo(privacyUrl)
      this.privacyDialog.setPrivacyCallback(() => {
        this.appPrefer.setPrivacyGrant()
        this.privacyDialog.dismiss(true)
        this.initAndWait()
      })
      this.privacyDialog.show()
    }
  }

  build() {

    Stack() {
      Image($r('app.media.foreground'))
        .size({
          width: 100,
          height: 100
        })
    }
    .width('100%')
    .height('100%')

  }

  onBackPress(): boolean | void {
    // Avoid back press
    return true
  }

  private async initAndWait() {
    try {
      let repository: Repository = AppStorage.get(Repository.REPOSITORY)!
      await repository.init()
    } catch (error) {
    }
    setTimeout(() => {
      AppRouter.goToHome(this.getUIContext())
    }, 1000)
  }

}