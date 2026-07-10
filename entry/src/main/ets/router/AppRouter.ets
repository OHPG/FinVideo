import { FinItem, FinItemType, FinPerson } from '@ohpg/fin-core'
import { FinRepository, ProgressDialog } from '@ohpg/fin-framework'
import { Repository } from '../data/Repository'
import { PlayerArgs } from '../pages/player/PlayerArgs'
import { AppPlayerManager } from '../player/AppPlayerManager'
import { PersonArgs } from '../pages/detail/person/PersonArgs'
import { AVPlaybackManager } from '@ohpg/player'
import { PlayerRouter } from '@ohpg/widget'

export class AppRouter {

  public static goToHome(context: UIContext) {
    context.getRouter().replaceUrl({ url: 'pages/home/HomePage' })
  }

  public static async goToPlayer(context: UIContext, args?: PlayerArgs) {
    if (args) {
      let playerManager: AppPlayerManager = AppStorage.get(AVPlaybackManager.AV_PLAYER_MANAGER)!
      let dialog = new ProgressDialog(context)
      await dialog.show()
      let itemDtoArray: Array<FinItem>
      let itemIndex: number = 0
      try {
        let repository: Repository = AppStorage.get(FinRepository.REPOSITORY)!
        if (args.type === FinItemType.Movie) {
          let itemDto: FinItem = await repository.getMovie(args.id)
          itemDtoArray = new Array()
          itemDtoArray.push(itemDto)
        } else if (args.type === FinItemType.Episode) {
          let itemDto = await repository.getEpisode(args.id)
          if (itemDto.seriesId) {
            itemDtoArray = await repository.getEpisodes(itemDto.seriesId, itemDto.seasonId)
            itemIndex = itemDtoArray.findIndex((item) => item.id === args.id)
            itemIndex = itemIndex < 0 ? 0 : itemIndex
          } else {
            itemDtoArray = [itemDto]
          }
        } else {
          throw new Error('Unsupported type ' + args.type)
        }
      } catch (e) {
        context.getPromptAction().showToast({ message: (e as Error).message || '加载出错。' })
        await dialog.dismiss(true)
        return
      }
      await dialog.dismiss(true)
      if (!playerManager.playAll(itemDtoArray, itemIndex, args.preferredSourceId)) {
        context.getPromptAction().showToast({ message: $r('app.string.global_operation_busy') })
        return
      }
    }
    PlayerRouter.push(context)
  }

  public static goToPersonDetail(context: UIContext, person: FinPerson) {
    let args: PersonArgs = {
      id: person.id,
      name: person.name,
      role: person.role,
      image: person.image?.primary
    }
    context.getRouter().pushUrl({ url: 'pages/detail/person/PersonPage', params: args })
  }

  public static goToVideoSetting(context: UIContext) {
    context.getRouter().pushUrl({ url: 'pages/setting/VideoSettingPage' })
  }

  public static goToCodecSetting(context: UIContext) {
    context.getRouter().pushUrl({ url: 'pages/setting/CodecSettingPage' })
  }

  public static goToGestureSetting(context: UIContext) {
    context.getRouter().pushUrl({ url: 'pages/setting/GestureSettingPage' })
  }

  public static goToSubtitleSetting(context: UIContext) {
    context.getRouter().pushUrl({ url: 'pages/setting/SubtitleSettingPage' })
  }

  public static goBack(context: UIContext) {
    context.getRouter().back()
  }

}
