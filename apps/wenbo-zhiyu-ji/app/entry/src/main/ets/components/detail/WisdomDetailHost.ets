import { QuoteDetailPane } from './QuoteDetailPane'

@Component
export struct WisdomDetailHost {
  @Prop detailKind: string = ''
  @Prop detailId: string = ''
  @Prop refreshToken: number = 0

  build() {
    Column() {
      if (this.detailKind === 'quote') {
        QuoteDetailPane({
          itemId: this.detailId,
          refreshToken: this.refreshToken
        })
      }
    }
    .width('100%')
    .height('100%')
  }
}
