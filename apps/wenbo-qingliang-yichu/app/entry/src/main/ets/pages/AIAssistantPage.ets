import { OutfitPage } from './OutfitPage'

@Component
export struct AIAssistantPage {
  @Prop quickCommands: string[] = []
  onRequireAuth?: () => void

  build() {
    OutfitPage({
      onRequireAuth: this.onRequireAuth
    })
  }
}
