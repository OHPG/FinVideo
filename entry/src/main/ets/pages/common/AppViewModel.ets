import { FinViewModel } from '@ohpg/fin-framework'
import { Repository } from '../../data/Repository'

/**
 * @Author peerless2012
 * @Email peerless2012@126.com
 * @DateTime 2024/12/6 23:28
 * @Version V1.0
 * @Description
 */
export class AppViewModel extends FinViewModel<Repository> {

  constructor(context: Context) {
    super(context)
  }

}