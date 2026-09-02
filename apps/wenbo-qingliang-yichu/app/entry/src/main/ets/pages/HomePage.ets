import { WardrobePage } from './WardrobePage'
import { WardrobeItemModel } from '../models/WardrobeModels'

@Component
export struct HomePage {
  @Prop company: string = '魏文波'
  @Prop appName: string = '清凉衣橱'
  @Prop tagline: string = '整理衣物，也整理每天的心情'
  onOpenMessages: () => void = () => {}
  onNavigateToOutfitWithItem?: (item: WardrobeItemModel) => void

  build() {
    WardrobePage({
      company: this.company,
      appName: this.appName,
      tagline: this.tagline,
      onOpenMessages: () => this.onOpenMessages(),
      onNavigateToOutfitWithItem: this.onNavigateToOutfitWithItem
    })
  }
}
