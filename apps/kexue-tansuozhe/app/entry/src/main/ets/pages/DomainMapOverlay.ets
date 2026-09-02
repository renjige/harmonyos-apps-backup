import { Theme } from '../components/design-system/Theme'
import { DetailShell } from '../components/detail/DetailShell'
import { DomainStat } from '../models/ExplorationModels'
import { ExplorationStore } from '../services/ExplorationStore'
import { ExploreNav } from '../services/ExploreNav'

@Component
export struct DomainMapOverlay {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @StorageLink('progressRev') @Watch('onRev') progressRev: number = 0
  @State domains: DomainStat[] = []

  aboutToAppear(): void {
    this.domains = ExplorationStore.domainStats()
  }

  onRev(): void {
    this.domains = ExplorationStore.domainStats()
  }

  build() {
    DetailShell({
      title: '领域地图',
      onClose: (): void => { ExploreNav.closeDomainMap() }
    }) {
      Scroll() {
        Column({ space: Theme.space.s4 }) {
          Text('五个领域点亮你的探索版图：自然、生活、科学、人文、趣味。')
            .fontSize(Theme.type.body)
            .fontColor(Theme.colors().textSecondary)
            .width('100%')
          ForEach(this.domains, (d: DomainStat) => {
            Column({ space: Theme.space.s2 }) {
              Row() {
                Text(d.label)
                  .fontSize(Theme.type.title3)
                  .fontWeight(FontWeight.Medium)
                  .fontColor(Theme.colors().textPrimary)
                  .layoutWeight(1)
                Text(`${Math.round(d.count * 100 / Math.max(d.total, 1))}%`)
                  .fontSize(Theme.type.subhead)
                  .fontColor(Theme.colors().brandPrimary)
              }
              .width('100%')
              Stack({ alignContent: Alignment.Start }) {
                Column()
                  .width(`${Math.min(100, Math.round(d.count * 100 / Math.max(d.total, 1)))}%`)
                  .height(8)
                  .backgroundColor(Theme.colors().brandAccent)
                  .borderRadius(Theme.radius.pill)
              }
              .width('100%')
              .height(8)
              .backgroundColor(Theme.colors().surfaceSubtle)
              .borderRadius(Theme.radius.pill)
              Text(`已探索 ${d.count} / 图鉴 ${d.total} 项`)
                .fontSize(Theme.type.caption)
                .fontColor(Theme.colors().textSecondary)
                .width('100%')
            }
            .width('100%')
            .padding(Theme.space.s4)
            .backgroundColor(Theme.colors().surfaceCard)
            .borderRadius(Theme.radius.md)
          }, (d: DomainStat) => d.category)
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
