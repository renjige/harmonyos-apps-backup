import { ReadDetailPane } from './ReadDetailPane'
import { FeaturedDetailPane } from './FeaturedDetailPane'
import { ThoughtDetailPane } from './ThoughtDetailPane'
import { QuoteDetailPane } from './QuoteDetailPane'
import { TopicDetailPane } from './TopicDetailPane'

@Component
export struct WisdomDetailHost {
  @Prop detailKind: string = ''
  @Prop detailId: string = ''
  @Prop refreshToken: number = 0
  onRequireAuth: () => void = () => {}

  build() {
    Column() {
      if (this.detailKind === 'read') {
        ReadDetailPane({
          itemId: this.detailId,
          refreshToken: this.refreshToken,
          onRequireAuth: (): void => { this.onRequireAuth() }
        })
      } else if (this.detailKind === 'featured') {
        FeaturedDetailPane({
          itemId: this.detailId,
          refreshToken: this.refreshToken,
          onRequireAuth: (): void => { this.onRequireAuth() }
        })
      } else if (this.detailKind === 'thought') {
        ThoughtDetailPane({
          itemId: this.detailId,
          refreshToken: this.refreshToken,
          onRequireAuth: (): void => { this.onRequireAuth() }
        })
      } else if (this.detailKind === 'quote') {
        QuoteDetailPane({
          itemId: this.detailId,
          refreshToken: this.refreshToken
        })
      } else if (this.detailKind === 'topic') {
        TopicDetailPane({
          itemId: this.detailId,
          refreshToken: this.refreshToken
        })
      }
    }
    .width('100%')
    .height('100%')
  }
}
