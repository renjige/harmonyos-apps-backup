import { Theme } from '../components/design-system/Theme'
import { AppButton } from '../components/design-system/AppButton'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { AppStatCard } from '../components/design-system/AppStatCard'
import { ObserveImage } from '../components/guanwu/ObserveImage'
import { WeeklyPlanCard } from '../components/guanwu/WeeklyPlanCard'
import { CategoryOption, ObserveSubject } from '../models/ObserveCatalog'
import { ObserveAtlasStore } from '../services/ObserveAtlasStore'
import { ObserveStore } from '../services/ObserveStore'
import { ObserveMedia } from '../services/ObserveMedia'
import { ObserveWeeklyPlanService } from '../services/ObserveWeeklyPlanService'
import { PlanItem } from '../services/ObservePlanService'

@Component
export struct AtlasTabPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop @Watch('onRefreshTokenChange') refreshToken: number = 0
  @Prop bottomInset: number = 76
  onCreateSubject: () => void = () => {}
  onOpenSubject: (id: string) => void = () => {}
  @State filterKey: string = 'all'
  @State items: ObserveSubject[] = []
  @State atlasCount: number = 0
  @State timelineCount: number = 0
  @State weeklyItems: PlanItem[] = []

  aboutToAppear(): void {
    void this.reload()
  }

  onRefreshTokenChange(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    this.items = await ObserveAtlasStore.filterByCategory(this.filterKey)
    const all = await ObserveAtlasStore.loadAll()
    this.atlasCount = all.length
    let linked = 0
    for (const s of all) {
      const notes = await ObserveStore.notesForSubject(s.id)
      if (notes.length >= 2) {
        linked++
      }
    }
    this.timelineCount = linked
    this.weeklyItems = await ObserveWeeklyPlanService.loadWeek()
  }

  private async toggleWeekly(id: string): Promise<void> {
    this.weeklyItems = await ObserveWeeklyPlanService.toggle(id)
  }

  @Builder
  CatChip(key: string, label: string) {
    Text(label)
      .fontSize(Theme.type.bodyS)
      .fontColor(this.filterKey === key ? Theme.colors().brandOnPrimary : Theme.colors().textSecondary)
      .padding({ left: 12, right: 12, top: 8, bottom: 8 })
      .backgroundColor(this.filterKey === key ? Theme.colors().brandPrimary : Theme.colors().surfaceSubtle)
      .borderRadius(Theme.radius.pill)
      .onClick((): void => {
        this.filterKey = key
        void this.reload()
      })
  }

  build() {
    Column() {
      Scroll() {
        Column({ space: Theme.space.s4 }) {
          Text('物品图鉴')
            .fontSize(Theme.type.title2)
            .fontWeight(FontWeight.Medium)
            .fontColor(Theme.colors().textPrimary)
            .width('100%')

          Text('为植物、收藏、家庭物件建档，多次观察形成成长时间轴')
            .fontSize(Theme.type.bodyS)
            .fontColor(Theme.colors().textSecondary)
            .width('100%')

          Row({ space: Theme.space.s3 }) {
            Column() {
              AppStatCard({ label: '图鉴条目', value: `${this.atlasCount}` })
            }.layoutWeight(1)
            Column() {
              AppStatCard({ label: '成长对比', value: `${this.timelineCount}` })
            }.layoutWeight(1)
          }
          .width('100%')

          WeeklyPlanCard({
            items: this.weeklyItems,
            onToggle: (id: string): void => { void this.toggleWeekly(id) }
          })

          AppButton({
            label: '＋ 新建图鉴条目',
            variant: 'primary',
            onTap: (): void => this.onCreateSubject()
          })

          Scroll() {
            Row({ space: Theme.space.s2 }) {
              this.CatChip('all', '全部')
              ForEach(CategoryOption.all(), (c: CategoryOption) => {
                this.CatChip(c.key, c.label)
              }, (c: CategoryOption) => c.key)
            }
          }
          .scrollable(ScrollDirection.Horizontal)
          .width('100%')

          if (this.items.length === 0) {
            AppEmpty({
              title: '还没有图鉴',
              description: '记录时填写物品名称会自动建档；也可手动新建',
              actionLabel: '立即新建',
              onAction: (): void => this.onCreateSubject()
            })
          } else {
            ForEach(this.items, (s: ObserveSubject) => {
              Row({ space: Theme.space.s3 }) {
                if (s.coverPath.length > 0) {
                  ObserveImage({ path: s.coverPath, imgWidth: 72, imgHeight: 72, radius: Theme.radius.md })
                } else {
                  Image(ObserveMedia.hero())
                    .width(72)
                    .height(72)
                    .borderRadius(Theme.radius.md)
                    .objectFit(ImageFit.Cover)
                }
                Column({ space: 4 }) {
                  Text(s.name)
                    .fontSize(Theme.type.body)
                    .fontWeight(FontWeight.Medium)
                    .fontColor(Theme.colors().textPrimary)
                  Text(CategoryOption.labelOf(s.categoryKey))
                    .fontSize(Theme.type.caption)
                    .fontColor(Theme.colors().brandPrimary)
                  Text(s.traits.length > 0 ? s.traits : '点击查看成长时间轴')
                    .fontSize(Theme.type.caption)
                    .fontColor(Theme.colors().textSecondary)
                    .maxLines(2)
                }
                .layoutWeight(1)
                .alignItems(HorizontalAlign.Start)
              }
              .width('100%')
              .padding(Theme.space.s4)
              .backgroundColor(Theme.colors().surfaceCard)
              .borderRadius(Theme.radius.md)
              .onClick((): void => this.onOpenSubject(s.id))
            }, (s: ObserveSubject) => s.id)
          }
        }
        .padding({ left: Theme.space.s4, right: Theme.space.s4, top: Theme.space.s4, bottom: this.bottomInset })
      }
      .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }
}
