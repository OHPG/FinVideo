import { FinItem } from "@ohpg/fin-core";

export interface ShowInfo {

  show: FinItem

  nextUp?: FinItem

  seasons?: Array<FinItem>
}