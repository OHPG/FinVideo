import { AVPlayerContextFactory } from "@ohpg/player"
import { Repository } from "../data/Repository"
import { AppPlayerContext } from "./AppPlayerContext"

export class AppPlayerContextFactory implements AVPlayerContextFactory {
  create(context: UIContext): AppPlayerContext {
    let repository = AppStorage.get<Repository>(Repository.REPOSITORY)!
    return new AppPlayerContext(context, repository)
  }
}