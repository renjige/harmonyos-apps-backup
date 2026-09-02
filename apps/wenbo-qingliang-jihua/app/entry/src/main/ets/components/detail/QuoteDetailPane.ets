import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { AppEmpty } from '../design-system/AppEmpty'
import { AppLoading } from '../design-system/AppLoading'
import { SymbolHero } from '../design-system/SymbolVisual'
import { DetailShell } from './DetailShell'
import { QuoteItem } from '../../models/CoolPlanModels'
import { CoolPlanBizService } from '../../services/CoolPlanBizService'
import { CoolPlanNav } from '../../services/CoolPlanNav'

@Component
export struct QuoteDetailPane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop @Watch('onQuoteIdChange') quoteId: string = ''
  @Prop @Watch('onQuoteIdChange') refreshToken: number = 0
  @State item: QuoteItem | undefined = undefined
  @State loading: boolean = true

  aboutToAppear(): void {
    void this.reload()
  }

  onQuoteIdChange(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    this.loading = true
    this.item = await CoolPlanBizService.findQuote(this.quoteId)
    this.loading = false
  }

  build() {
    if (this.loading) {
      Column() { AppLoading({ label: '打开语录' }) }
        .width('100%').height('100%').justifyContent(FlexAlign.Center)
        .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
    } else if (this.item === undefined) {
      DetailShell({ title: '智慧语录', onClose: (): void => CoolPlanNav.close() }) {
        AppEmpty({ title: '语录不存在', iconName: 'book', emojiMark: '📖' })
      }
    } else {
      DetailShell({
        title: this.item.title,
        contentKey: this.quoteId,
        onClose: (): void => CoolPlanNav.close()
      }) {
        Column({ space: Theme.space.s4 }) {
          SymbolHero({
            category: '语录',
            coverKey: this.item.coverKey.length > 0 ? this.item.coverKey : 'hero_mist_lake',
            overline: '✨ 早安智慧',
            title: this.item.title,
            bannerHeight: 200
          })

          Column({ space: 8 }) {
            if (this.item.author.length > 0) {
              Text(`— ${this.item.author}`)
                .fontSize(Theme.type.footnote)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
                .width('100%')
            }
            Text(this.item.summary)
              .fontSize(Theme.type.body)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
              .width('100%')
            Text(this.item.body)
              .fontSize(Theme.type.footnote)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
              .width('100%')
          }
          .padding({ left: Theme.space.pageX, right: Theme.space.pageX })

          Column({ space: Theme.space.s3 }) {
            AppButton({
              label: '开始智慧呼吸',
              onTap: (): void => {
                CoolPlanNav.switchTabBreathFromOverlay()
              }
            })
          }
          .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
        }
        .width('100%')
      }
    }
  }
}
