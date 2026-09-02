import { Theme } from '../components/design-system/Theme'
import { ModeListCard } from '../components/math/ModeListCard'
import { CatalogItem } from '../models/MathModels'
import { MathBizService } from '../services/MathBizService'
import { MathCatalog } from '../services/MathCatalog'
import { MathDetailNav } from '../services/MathDetailNav'
import { MathLocalStore } from '../services/MathLocalStore'

@Component
export struct PracticePage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop @Watch('onRefreshTokenChange') refreshToken: number = 0
  @State modes: CatalogItem[] = []
  @State wrongCount: number = 0
  onStartMode: (mode: string) => void = (_m: string) => {}
  onStartChallenge: () => void = () => {}
  onOpenWrong: () => void = () => {}

  aboutToAppear(): void {
    this.modes = MathCatalog.modes()
    this.wrongCount = MathLocalStore.snapshot().wrongs.length
    void this.reload()
  }

  onRefreshTokenChange(): void {
    this.wrongCount = MathLocalStore.snapshot().wrongs.length
    void this.reload()
  }

  private async reload(): Promise<void> {
    const list = await MathBizService.loadModes()
    if (list.length > 0) {
      this.modes = list
    }
  }

  build() {
    Scroll() {
      Column({ space: Theme.space.s4 }) {
        Text('趣味训练')
          .fontSize(Theme.type.title2)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .width('100%')
          .padding({ top: Theme.space.s2 })

        ForEach(this.modes, (item: CatalogItem) => {
          ModeListCard({
            item: item,
            onTap: () => MathDetailNav.open('mode', item.id)
          })
        }, (item: CatalogItem) => item.id)

        ModeListCard({
          item: this.challengeItem(),
          onTap: () => MathDetailNav.open('challenge', 'km_ch_level')
        })

        Column({ space: Theme.space.s2 }) {
          Text('错题本')
            .fontSize(Theme.type.subtitleS)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            .width('100%')
          Text(this.wrongCount > 0 ? `有 ${this.wrongCount} 题可以再算一次` : '太棒啦！目前没有需要复习的题目')
            .fontSize(Theme.type.footnote)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
            .width('100%')
        }
        .width('100%')
        .padding(Theme.space.s5)
        .alignItems(HorizontalAlign.Start)
        .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
        .borderRadius(Theme.radius.xl)
        .onClick(() => this.onOpenWrong())
      }
      .padding({
        left: Theme.space.pageX,
        right: Theme.space.pageX,
        bottom: Theme.space.s10
      })
      .constraintSize({ maxWidth: 720 })
      .width('100%')
    }
    .width('100%')
    .height('100%')
    .align(Alignment.Top)
    .scrollBar(BarState.Off)
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }

  private challengeItem(): CatalogItem {
    const item = new CatalogItem()
    item.id = 'km_ch_level'
    item.title = '闯关挑战'
    item.subtitle = '每关 10 题'
    item.summary = '轻松闯关，完成后可再来一关'
    item.coverKey = 'cover_challenge'
    return item
  }
}
