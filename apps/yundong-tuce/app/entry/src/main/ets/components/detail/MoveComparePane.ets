import { Theme } from '../design-system/Theme'
import { MoveItem } from '../../models/TuceModels'
import { MoveLibrary } from '../../services/MoveLibrary'
import { TuceMedia } from '../../services/TuceMedia'
import { TuceNav } from '../../services/TuceNav'

@Component
export struct MoveComparePane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @State catalog: MoveItem[] = []
  @State leftId: string = 'm01'
  @State rightId: string = 'm10'

  aboutToAppear(): void {
    this.catalog = MoveLibrary.all()
  }

  private leftMove(): MoveItem | undefined {
    return MoveLibrary.find(this.leftId)
  }

  private rightMove(): MoveItem | undefined {
    return MoveLibrary.find(this.rightId)
  }

  private cycleLeft(): void {
    let idx = 0
    for (let i = 0; i < this.catalog.length; i++) {
      if (this.catalog[i].id === this.leftId) {
        idx = i
      }
    }
    const next = (idx + 1) % this.catalog.length
    this.leftId = this.catalog[next].id
  }

  private cycleRight(): void {
    let idx = 0
    for (let i = 0; i < this.catalog.length; i++) {
      if (this.catalog[i].id === this.rightId) {
        idx = i
      }
    }
    const next = (idx + 1) % this.catalog.length
    this.rightId = this.catalog[next].id
  }

  build() {
    Scroll() {
      Column({ space: Theme.space.s4 }) {
        Text('左右对照两个动作的部位、难度与要点，帮助编排更合理的训练顺序。')
          .fontSize(Theme.type.bodyS)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          .width('100%')

        Row({ space: Theme.space.s3 }) {
          this.MovePane('动作 A', this.leftMove(), (): void => { this.cycleLeft() })
          this.MovePane('动作 B', this.rightMove(), (): void => { this.cycleRight() })
        }
        .width('100%')

        Column({ space: Theme.space.s2 }) {
          this.CompareLine('分类', this.leftMove()?.category ?? '—', this.rightMove()?.category ?? '—')
          this.CompareLine('部位', this.leftMove()?.bodyPart ?? '—', this.rightMove()?.bodyPart ?? '—')
          this.CompareLine('难度', this.leftMove()?.level ?? '—', this.rightMove()?.level ?? '—')
          this.CompareLine('建议时长', `${this.leftMove()?.minutes ?? 0} 分`, `${this.rightMove()?.minutes ?? 0} 分`)
        }
        .width('100%')
        .padding(Theme.space.s4)
        .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
        .borderRadius(Theme.radius.md)

        Text('点击卡片切换动作 · 点名称可进详情')
          .fontSize(Theme.type.caption)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          .width('100%')
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
  }

  @Builder
  MovePane(label: string, move: MoveItem | undefined, onCycle: () => void) {
    Column({ space: Theme.space.s2 }) {
      Text(label)
        .fontSize(Theme.type.caption)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
      if (move !== undefined) {
        Image(TuceMedia.cover(move.coverKey))
          .width('100%')
          .height(100)
          .objectFit(ImageFit.Cover)
          .borderRadius(Theme.radius.sm)
        Text(move.name)
          .fontSize(Theme.type.bodyS)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .maxLines(2)
          .onClick((): void => { TuceNav.open('move', move.id) })
      }
      Text('切换')
        .fontSize(Theme.type.caption)
        .fontColor(Theme.colors().brandPrimary)
        .onClick(onCycle)
    }
    .layoutWeight(1)
    .padding(Theme.space.s3)
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceSubtle : Theme.colors().surfaceSubtle)
    .borderRadius(Theme.radius.md)
  }

  @Builder
  CompareLine(label: string, left: string, right: string) {
    Row() {
      Text(label)
        .fontSize(Theme.type.caption)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
        .width(56)
      Text(left)
        .fontSize(Theme.type.bodyS)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
        .layoutWeight(1)
      Text(right)
        .fontSize(Theme.type.bodyS)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
        .layoutWeight(1)
        .textAlign(TextAlign.End)
    }
    .width('100%')
  }
}
