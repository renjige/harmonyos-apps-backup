import { Theme } from '../components/design-system/Theme'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { AppError } from '../components/design-system/AppError'
import { AppIcon } from '../components/design-system/AppIcon'
import { AppLoading } from '../components/design-system/AppLoading'
import { QuoteListCard } from '../components/cool/QuoteListCard'
import { QuoteItem, QuoteListPayload } from '../models/CoolPlanModels'
import { CoolPlanBizService } from '../services/CoolPlanBizService'
import { HttpClient } from '../services/HttpClient'
import { CoolPlanNav } from '../services/CoolPlanNav'

@Component
export struct QuoteListPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @State items: QuoteItem[] = []
  @State loading: boolean = false
  @State loadFailed: boolean = false

  aboutToAppear(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    this.loading = true
    this.loadFailed = false
    const res = await HttpClient.get<QuoteListPayload>('/biz/cool-plan/quotes')
    if (res.code === 0 && res.data !== undefined && res.data.list !== undefined) {
      const out: QuoteItem[] = []
      for (const w of res.data.list) {
        out.push(QuoteItem.fromWire(w))
      }
      this.items = out
      this.loadFailed = false
    } else {
      this.items = []
      this.loadFailed = true
    }
    this.loading = false
  }

  build() {
    Column() {
      Row({ space: Theme.space.s2 }) {
        Column() {
          AppIcon({ name: 'chevron', iconSize: Theme.icon.md, color: Theme.colors().textPrimary })
        }
        .width(44)
        .height(44)
        .justifyContent(FlexAlign.Center)
        .rotate({ angle: 180 })
        .onClick((): void => { CoolPlanNav.close() })
        Column({ space: 2 }) {
          Text('📖 智慧语录')
            .fontSize(Theme.type.title3)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          Text('52 条精选 · 点击阅读全文')
            .fontSize(Theme.type.caption)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)
      }
      .width('100%')
      .padding({ left: Theme.space.pageX - 8, right: Theme.space.pageX, top: Theme.space.s2 })

      if (this.loading && this.items.length === 0) {
        AppLoading({ label: '读取语录' }).layoutWeight(1)
      } else if (this.loadFailed) {
        AppError({
          message: '语录加载失败',
          retryLabel: '重试',
          onRetry: (): void => { void this.reload() }
        }).layoutWeight(1)
      } else if (this.items.length === 0) {
        AppEmpty({
          title: '暂无语录',
          description: '请检查网络后重试',
          iconName: 'book',
          emojiMark: '📖',
          actionLabel: '重新加载',
          onAction: (): void => { void this.reload() }
        }).layoutWeight(1)
      } else {
        Refresh({ refreshing: this.loading, offset: 64, friction: 100 }) {
          List({ space: Theme.space.s3 }) {
            ForEach(this.items, (q: QuoteItem) => {
              ListItem() {
                QuoteListCard({
                  item: q,
                  onTap: (): void => { CoolPlanNav.openQuote(q.id) }
                })
              }
            }, (q: QuoteItem) => q.id)
          }
          .layoutWeight(1)
          .padding({
            left: Theme.space.pageX,
            right: Theme.space.pageX,
            top: Theme.space.s3,
            bottom: Theme.space.s10
          })
          .edgeEffect(EdgeEffect.Spring)
        }
        .layoutWeight(1)
        .onRefreshing((): void => { void this.reload() })
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }
}
