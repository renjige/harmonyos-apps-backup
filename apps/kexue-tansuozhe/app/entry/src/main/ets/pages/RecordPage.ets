import { Theme } from '../components/design-system/Theme'
import { AppHeader } from '../components/design-system/AppHeader'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { AppButton } from '../components/design-system/AppButton'
import { UserDiscovery } from '../models/ExplorationModels'
import { ExplorationStore } from '../services/ExplorationStore'
import { ExploreNav } from '../services/ExploreNav'
import { LayoutConstants } from '../components/design-system/LayoutConstants'
import { SectionHeader } from '../components/explore/SectionHeader'
import { ExploreListCard } from '../components/explore/ExploreListCard'
import { CategoryEmojiUtil } from '../utils/CategoryEmojiUtil'

@Component
export struct RecordPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @StorageProp('progressRev') @Watch('onRev') progressRev: number = 0
  @State items: UserDiscovery[] = []
  @State hasSamples: boolean = false

  aboutToAppear(): void {
    this.reload()
  }

  onRev(): void {
    this.reload()
  }

  private reload(): void {
    this.items = ExplorationStore.snapshot().discoveries
    let samples = false
    for (const d of this.items) {
      if (d.isSample) samples = true
    }
    this.hasSamples = samples
  }

  build() {
    Column() {
      AppHeader({ title: '探索记录', subtitle: '你的发现与观察' })
      if (this.items.length === 0) {
        Column({ space: Theme.space.s4 }) {
          AppEmpty({
            title: '还没有记录',
            description: '从今天注意到的一件小事开始',
            actionLabel: '新建发现',
            onAction: (): void => { ExploreNav.openNewRecord() }
          })
            .layoutWeight(1)
        }
        .width('100%')
        .layoutWeight(1)
      } else {
        Scroll() {
          Column({ space: Theme.space.s3 }) {
            if (this.hasSamples) {
              Row({ space: Theme.space.s2 }) {
                Text('含示例记录，可一键清除')
                  .fontSize(Theme.type.footnote)
                  .fontColor(Theme.colors().textSecondary)
                  .layoutWeight(1)
                AppButton({
                  label: '清除示例',
                  variant: 'secondary',
                  onTap: (): void => { void ExplorationStore.dismissSamples() }
                })
              }
              .width('100%')
            }
            AppButton({
              label: '新建探索发现',
              onTap: (): void => { ExploreNav.openNewRecord() }
            })
            ForEach(this.items, (d: UserDiscovery) => {
              ExploreListCard({
                title: d.title,
                summary: d.description,
                category: d.category,
                coverKey: d.atlasRefId,
                badge: d.isSample ? '示例' : '',
                meta: `${CategoryEmojiUtil.chipLabel(d.category)} · ${d.dateKey}`,
                onTap: (): void => { ExploreNav.openRecordDetail(d.id) }
              })
            }, (d: UserDiscovery) => `${d.id}_${d.updatedAt}_${this.progressRev}`)
          }
          .padding({
            left: Theme.space.pageX,
            right: Theme.space.pageX,
            bottom: Theme.space.s10 + LayoutConstants.tabBarInset()
          })
          .width('100%')
        }
        .layoutWeight(1)
        .scrollBar(BarState.Off)
        .edgeEffect(EdgeEffect.Spring)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Theme.colors().surfacePage)
  }
}
