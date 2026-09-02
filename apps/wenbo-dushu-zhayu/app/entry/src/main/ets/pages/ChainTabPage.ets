import { Theme } from '../components/design-system/Theme'
import { AppHeader } from '../components/design-system/AppHeader'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { AppButton } from '../components/design-system/AppButton'
import { InspirationItem } from '../models/ReadingModels'
import { AuthService } from '../services/AuthService'
import { ReadingBizService } from '../services/ReadingBizService'
import { ReadingDetailNav } from '../services/ReadingDetailNav'

/** 独有玩法产出链 — 独立 Tab，非普通阅读记录列表 */
@Component
export struct ChainTabPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop @Watch('onRefreshTokenChange') refreshToken: number = 0
  onOpenLamp: () => void = () => {}
  onOpenDialogue: () => void = () => {}
  onOpenBookAsk: () => void = () => {}
  @State chainItems: InspirationItem[] = []
  @State loading: boolean = true

  aboutToAppear(): void {
    void this.reload()
  }

  onRefreshTokenChange(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    this.loading = true
    if (!AuthService.isLoggedIn()) {
      this.chainItems = []
      this.loading = false
      return
    }
    const all = await ReadingBizService.loadInspirations('')
    const filtered: InspirationItem[] = []
    for (const item of all) {
      if (this.isUniqueTag(item.tags)) {
        filtered.push(item)
      }
    }
    this.chainItems = filtered
    this.loading = false
  }

  private isUniqueTag(tags: string[]): boolean {
    for (const t of tags) {
      if (t === '灯下共读' || t === '对读札' || t === '问书三札') {
        return true
      }
    }
    return false
  }

  private tagLabel(tags: string[]): string {
    for (const t of tags) {
      if (t === '灯下共读' || t === '对读札' || t === '问书三札') {
        return t
      }
    }
    return '玩法产出'
  }

  build() {
    Column() {
      AppHeader({
        title: '札语链',
        subtitle: '仅串联灯下共读、对读札、问书三札产出 — 不是摘抄列表'
      })
      Scroll() {
        Column({ space: Theme.space.s4 }) {
          if (this.loading) {
            Text('加载思考链…')
              .fontSize(Theme.type.body)
              .fontColor(Theme.colors().textSecondary)
              .width('100%')
              .padding(Theme.space.s6)
          } else if (this.chainItems.length === 0) {
            AppEmpty({
              title: AuthService.isLoggedIn() ? '还没有玩法产出' : '登录后体验三种独有交互',
              description: '完成灯下共读、对读札或问书三札，思考会在这里按时间串联',
              actionLabel: '去体验灯下共读',
              onAction: (): void => { this.onOpenLamp() }
            })
            Row({ space: Theme.space.s3 }) {
              AppButton({
                label: '对读札',
                variant: 'secondary',
                onTap: (): void => { this.onOpenDialogue() }
              }).layoutWeight(1)
              AppButton({
                label: '问书三札',
                variant: 'secondary',
                onTap: (): void => { this.onOpenBookAsk() }
              }).layoutWeight(1)
            }
            .width('100%')
          } else {
            ForEach(this.chainItems, (item: InspirationItem) => {
              Column({ space: 6 }) {
                Text(this.tagLabel(item.tags))
                  .fontSize(Theme.type.caption)
                  .fontWeight(FontWeight.Medium)
                  .fontColor(Theme.tagForeground())
                  .padding({ left: 10, right: 10, top: 4, bottom: 4 })
                  .backgroundColor(Theme.tagBackground())
                  .borderRadius(Theme.radius.pill)
                Text(item.title)
                  .fontSize(Theme.type.subhead)
                  .fontWeight(FontWeight.Medium)
                  .fontColor(Theme.colors().textPrimary)
                  .width('100%')
                Text(item.content.length > 120 ? `${item.content.slice(0, 120)}…` : item.content)
                  .fontSize(Theme.type.caption)
                  .fontColor(Theme.colors().textSecondary)
                  .width('100%')
                  .maxLines(4)
                  .lineHeight(20)
              }
              .width('100%')
              .padding(Theme.space.s4)
              .backgroundColor(Theme.colors().surfaceCard)
              .borderRadius(Theme.radius.lg)
              .border({ width: 1, color: Theme.colors().strokeHairline })
              .onClick((): void => { ReadingDetailNav.openInspiration(item.id) })
            }, (item: InspirationItem) => item.id)
          }
        }
        .padding({
          left: Theme.space.pageX,
          right: Theme.space.pageX,
          bottom: Theme.space.s10
        })
        .width('100%')
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.Spring)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Theme.colors().surfacePage)
  }
}
