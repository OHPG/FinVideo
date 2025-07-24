import { common, StartupTask } from "@kit.AbilityKit";
import { FinVideoApi } from "../api/FinVideoApi";
import { Repository } from "../data/Repository";

/**
 * @Author peerless2012
 * @Email peerless2012@126.com
 * @DateTime 2024/11/10 1:04
 * @Version V1.0
 * @Description
 */
@Sendable
export class AppStartupTask extends StartupTask {

  public async init(context: common.AbilityStageContext): Promise<void> {
    let finVideoApi = new FinVideoApi(context.getApplicationContext(), "FinVideo")
    AppStorage.setOrCreate(FinVideoApi.FIN_API, finVideoApi)
    let repository = new Repository(context.getApplicationContext(), finVideoApi)
    AppStorage.setOrCreate(Repository.REPOSITORY, repository)
    try {
      await repository.init()
    } catch (error) {
      console.error("AppStartupTask: init error " + error['message'])
    }
  }

}