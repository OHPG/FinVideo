import { BaseItemDto } from "@ohpg/jellyfin";

export interface ShowInfo {

  show: BaseItemDto

  nextUp?: BaseItemDto

  seasons?: Array<BaseItemDto>
}