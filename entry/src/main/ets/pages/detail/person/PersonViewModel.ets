import { FinItem, FinItemType, LoadType } from "@ohpg/fin-core"
import { SimpleRepository } from "@ohpg/fin-framework"
import { AppViewModel } from "../../common/AppViewModel"
import { PersonArgs } from "./PersonArgs"

export interface PersonData {
  args: PersonArgs
  overview?: string
  items: Array<FinItem>
  movies: Array<FinItem>
  series: Array<FinItem>
}

export class PersonViewModel extends AppViewModel implements SimpleRepository {

  private readonly args: PersonArgs

  constructor(context: Context, args: PersonArgs) {
    super(context)
    this.args = args
  }

  async loadData(type: LoadType): Promise<Object> {
    let results = await Promise.all([
      this.repository.getPersonDetail(this.args.id),
      this.repository.getPersonItems(this.args.id)
    ])
    let detail = results[0] as FinItem
    let items = results[1] as Array<FinItem>
    let movies = items.filter((item) => item.type === FinItemType.Movie)
    let series = items.filter((item) => item.type === FinItemType.Series)
    let data: PersonData = {
      args: this.args,
      overview: detail.overview,
      items: items,
      movies: movies,
      series: series
    }
    return data
  }

}
