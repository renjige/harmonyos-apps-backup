import { Theme } from '../components/design-system/Theme'
import { AppIcon } from '../components/design-system/AppIcon'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { ContentCard } from '../components/ContentCard'
import { FactItem, SceneChip } from '../models/CommonSenseModels'
import { CommonSenseBizService } from '../services/CommonSenseBizService'
import { CommonSenseDetailNav } from '../services/CommonSenseDetailNav'

@Component
export struct ScenesPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @State facts: FactItem[] = []
  @State filtered: FactItem[] = []
  @State scene: string = 'all'
  private chips: SceneChip[] = SceneChip.all()

  aboutToAppear(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    const list = await CommonSenseBizService.loadFacts()
    this.facts = list
    this.apply()
  }

  private apply(): void {
    this.filtered = CommonSenseBizService.filterByScene(this.facts, this.scene)
  }

  private sceneLabel(): string {
    return SceneChip.labelOf(this.scene)
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
        .onClick((): void => { CommonSenseDetailNav.close() })
        Text('生活场景知识库')
          .fontSize(Theme.type.title3)
          .fontWeight(FontWeight.Medium)
          .fontColor(Theme.colors().textPrimary)
      }
      .width('100%')
      .padding({ left: Theme.space.pageX - 8, right: Theme.space.pageX, top: Theme.space.s2 })

      Text('按真实生活场景筛选用得上的常识，点进去可收藏、笔记、加入清单。')
        .fontSize(Theme.type.footnote)
        .fontColor(Theme.colors().textSecondary)
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: 8 })
        .width('100%')

      Scroll() {
        Row({ space: 8 }) {
          ForEach(this.chips, (chip: SceneChip) => {
            Text(chip.label)
              .fontSize(12)
              .fontColor(this.scene === chip.key ?
                Theme.colors().brandOnPrimary : Theme.colors().textSecondary)
              .padding({ left: 12, right: 12, top: 8, bottom: 8 })
              .backgroundColor(this.scene === chip.key ?
                Theme.colors().brandPrimary : Theme.colors().surfaceCard)
              .borderRadius(Theme.radius.pill)
              .onClick((): void => {
                this.scene = chip.key
                this.apply()
              })
          }, (chip: SceneChip) => chip.key)
        }
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
      }
      .scrollable(ScrollDirection.Horizontal)
      .scrollBar(BarState.Off)

      if (this.scene !== 'all') {
        Text(`打开「${this.sceneLabel()}」使用指南`)
          .fontSize(Theme.type.footnote)
          .fontColor(Theme.colors().brandPrimary)
          .padding({ left: Theme.space.pageX, top: 8, bottom: 4 })
          .onClick((): void => { CommonSenseDetailNav.openSceneGuide(this.scene) })
      }

      if (this.filtered.length === 0) {
        AppEmpty({
          title: '这个场景暂时没有条目',
          description: '换一个场景，或去分类浏览搜索。'
        })
      } else {
        Scroll() {
          Column({ space: Theme.space.s3 }) {
            ForEach(this.filtered, (row: FactItem) => {
              ContentCard({
                item: row,
                compact: false,
                onOpen: (): void => { CommonSenseDetailNav.openFact(row.id) }
              })
            }, (row: FactItem) => row.id)
          }
          .padding({
            left: Theme.space.pageX,
            right: Theme.space.pageX,
            bottom: Theme.space.s10,
            top: Theme.space.s3
          })
        }
        .layoutWeight(1)
        .scrollBar(BarState.Off)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }
}
