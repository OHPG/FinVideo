import { FinItem, LoadType } from "@ohpg/fin-core"
import { SimpleRepository } from "@ohpg/fin-framework"
import { AppViewModel } from "../../common/AppViewModel"
import { PersonArgs } from "./PersonArgs"

export interface PersonData {
  args: PersonArgs
  items: Array<FinItem>
}

export class PersonViewModel extends AppViewModel implements SimpleRepository {

  private readonly args: PersonArgs

  constructor(context: Context, args: PersonArgs) {
    super(context)
    this.args = args
  }

  async loadData(type: LoadType): Promise<Object> {
    let items = await this.repository.getPersonItems(this.args.id)
    let data: PersonData = {
      args: this.args,
      items: items
    }
    return data
  }

}
