import { OutfitPage } from './OutfitPage'

@Component
export struct CoreBizPage {
  @Prop pageTitle: string = '智慧穿搭'
  onRequireAuth?: () => void

  build() {
    OutfitPage({
      onRequireAuth: this.onRequireAuth
    })
  }
}
