import { Theme } from '../components/design-system/Theme'
import { DetailShell } from '../components/detail/DetailShell'
import { ExploreBadgeBank, ExploreBadgeDef } from '../data/ExploreBadgeBank'
import { ExplorationStore } from '../services/ExplorationStore'
import { ExploreNav } from '../services/ExploreNav'

@Component
export struct BadgesOverlay {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @StorageLink('progressRev') @Watch('onRev') progressRev: number = 0
  @State earned: string[] = []

  aboutToAppear(): void {
    this.reload()
  }

  onRev(): void {
    this.reload()
  }

  private reload(): void {
    this.earned = ExplorationStore.snapshot().badgeIds
  }

  private isEarned(id: string): boolean {
    return this.earned.indexOf(id) >= 0
  }

  build() {
    DetailShell({
      title: '探索徽章',
      onClose: (): void => { ExploreNav.closeBadges() }
    }) {
      Scroll() {
        Column({ space: Theme.space.s3 }) {
          ForEach(ExploreBadgeBank.all(), (b: ExploreBadgeDef) => {
            Row({ space: Theme.space.s3 }) {
              Column({ space: 4 }) {
                Text(b.title)
                  .fontSize(Theme.type.subhead)
                  .fontWeight(FontWeight.Medium)
                  .fontColor(this.isEarned(b.id) ?
                    Theme.colors().textPrimary : Theme.colors().textSecondary)
                  .width('100%')
                Text(b.summary)
                  .fontSize(Theme.type.footnote)
                  .fontColor(Theme.colors().textSecondary)
                  .width('100%')
              }
              .alignItems(HorizontalAlign.Start)
              .layoutWeight(1)
              Text(this.isEarned(b.id) ? '已获得' : '未解锁')
                .fontSize(Theme.type.caption)
                .fontColor(this.isEarned(b.id) ?
                  Theme.colors().brandAccent : Theme.colors().textSecondary)
            }
            .width('100%')
            .padding(Theme.space.s4)
            .backgroundColor(Theme.colors().surfaceCard)
            .borderRadius(Theme.radius.md)
            .opacity(this.isEarned(b.id) ? 1 : 0.72)
          }, (b: ExploreBadgeDef) => b.id)
        }
        .padding({
          left: Theme.space.pageX,
          right: Theme.space.pageX,
          bottom: Theme.space.s10
        })
        .width('100%')
      }
      .scrollBar(BarState.Off)
      .width('100%')
      .height('100%')
    }
  }
}
