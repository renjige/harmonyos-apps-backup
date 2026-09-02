import { Theme } from '../design-system/Theme'
import { PresetPack } from '../../models/TuceModels'
import { PresetLibrary } from '../../services/PresetLibrary'
import { TuceNav } from '../../services/TuceNav'
import { TuceMedia } from '../../services/TuceMedia'
import { MoveLibrary } from '../../services/MoveLibrary'

@Component
export struct PresetListPane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop filterIds: string = ''
  @State scene: string = '全部'
  @State items: PresetPack[] = []

  aboutToAppear(): void {
    this.applyFilter()
  }

  private applyFilter(): void {
    if (this.filterIds.indexOf('scene:') === 0) {
      this.scene = this.filterIds.substring(6)
      this.items = PresetLibrary.byScene(this.scene)
      return
    }
    if (this.filterIds.length > 0 && this.filterIds.indexOf('|') >= 0) {
      const want = this.filterIds.split('|')
      const out: PresetPack[] = []
      for (const id of want) {
        const p = PresetLibrary.find(id)
        if (p !== undefined) {
          out.push(p)
        }
      }
      this.items = out
      return
    }
    this.items = PresetLibrary.byScene(this.scene)
  }

  private pickScene(s: string): void {
    if (this.filterIds.length > 0 && this.filterIds.indexOf('|') >= 0) {
      return
    }
    this.scene = s
    this.applyFilter()
  }

  build() {
    Scroll() {
      Column({ space: Theme.space.s3 }) {
        Text(this.filterIds.indexOf('|') >= 0 ? '根据体能自测为你推荐的精选课' :
          '12 套场景化精选课，可跟练、可保存为方案，覆盖居家/办公/户外等日常场景。')
          .fontSize(Theme.type.bodyS)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          .width('100%')

        if (this.filterIds.indexOf('|') < 0) {
          Scroll() {
            Row({ space: Theme.space.s2 }) {
              ForEach(PresetLibrary.scenes(), (s: string) => {
                Text(s)
                  .fontSize(Theme.type.caption)
                  .fontColor(this.scene === s ? Theme.colors().brandOnPrimary : Theme.colors().textSecondary)
                  .padding({ left: 12, right: 12, top: 8, bottom: 8 })
                  .backgroundColor(this.scene === s ? Theme.colors().brandPrimary : Theme.colors().surfaceSubtle)
                  .borderRadius(Theme.radius.pill)
                  .onClick((): void => { this.pickScene(s) })
              }, (s: string) => s)
            }
          }
          .scrollable(ScrollDirection.Horizontal)
          .scrollBar(BarState.Off)
          .width('100%')
        }

        ForEach(this.items, (p: PresetPack) => {
          Row({ space: Theme.space.s3 }) {
            Image(TuceMedia.cover(p.coverKey))
              .width(72)
              .height(72)
              .objectFit(ImageFit.Cover)
              .borderRadius(Theme.radius.sm)
            Column({ space: 4 }) {
              Text(p.name)
                .fontSize(Theme.type.body)
                .fontWeight(FontWeight.Medium)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                .width('100%')
              Text(`${p.scene} · ${p.minutes} 分钟 · ${p.level}`)
                .fontSize(Theme.type.caption)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                .width('100%')
              Text(MoveLibrary.namesOf(p.moveIds))
                .fontSize(Theme.type.overline)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                .maxLines(1)
                .width('100%')
            }
            .layoutWeight(1)
            .alignItems(HorizontalAlign.Start)
          }
          .width('100%')
          .padding(Theme.space.s3)
          .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
          .borderRadius(Theme.radius.md)
          .onClick((): void => { TuceNav.open('preset', p.id) })
        }, (p: PresetPack) => p.id)
      }
      .width('100%')
      .padding({
        left: Theme.space.pageX,
        right: Theme.space.pageX,
        top: Theme.space.s2,
        bottom: Theme.space.s10
      })
    }
    .width('100%')
    .height('100%')
    .edgeEffect(EdgeEffect.Spring)
    .scrollBar(BarState.Auto)
  }
}
