import { FinSubSource } from "./FinSubSource"

export interface FinItemSource {

  url: string

  sdr: boolean

  sub?: Array<FinSubSource>

}