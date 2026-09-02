import { Theme } from '../components/design-system/Theme'
import { AppButton } from '../components/design-system/AppButton'
import { JigsawItem } from '../models/JigsawModels'
import { JigsawBizService } from '../services/JigsawBizService'
import { JigsawMedia } from '../services/JigsawMedia'
import { JigsawNav } from '../services/JigsawNav'
import { ProgressStore } from '../services/ProgressStore'

@Component
export struct JigsawDetailOverlay {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @State item: JigsawItem = new JigsawItem()
  @State pieces: number = 4
  @State collab: boolean = false
  @StorageLink('jigTick') tick: number = 0

  aboutToAppear(): void {
    this.pieces = ProgressStore.defaultPieces()
    this.collab = JigsawNav.collab()
    void this.reload()
  }

  async reload(): Promise<void> {
    const list = await JigsawBizService.loadJigsaws()
    const found = JigsawBizService.findJigsaw(list, JigsawNav.jigId())
    if (found !== undefined) {
      this.item = found
    }
  }

  private bodyText(): string {
    if (this.item.description.length > 0) {
      return this.item.description
    }
    return this.item.body
  }

  build() {
    Column() {
      Row() {
        Text('返回')
          .fontSize(16)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
          .onClick(() => { JigsawNav.close() })
      }
      .width('100%')
      .padding({ left: 16, top: 12, bottom: 8 })

      Scroll() {
        Column({ space: Theme.space.s4 }) {
          Stack({ alignContent: Alignment.BottomStart }) {
            Image(JigsawMedia.cover(this.item.coverKey))
              .width('100%')
              .height(220)
              .objectFit(ImageFit.Cover)
            Column()
              .width('100%')
              .height(220)
              .linearGradient({
                angle: 180,
                colors: [['rgba(42,36,28,0.02)', 0], ['rgba(42,36,28,0.78)', 1]]
              })
            Column({ space: 6 }) {
              Text(this.item.themeLabel)
                .fontSize(13)
                .fontColor('#FFFFFF')
              Text(this.item.title)
                .fontSize(24)
                .fontWeight(FontWeight.Bold)
                .fontColor('#FFFFFF')
            }
            .padding({ left: 16, right: 16, bottom: 16 })
          }
          .width('100%')
          .clip(true)

          Column({ space: 8 }) {
            Text('这幅图在讲什么')
              .fontSize(15)
              .fontWeight(FontWeight.Medium)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
              .width('100%')
            Text(this.item.summary)
              .fontSize(15)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
              .width('100%')
              .lineHeight(22)
          }
          .width('100%')
          .padding(16)
          .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
          .borderRadius(20)

          Text(this.bodyText())
            .fontSize(15)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
            .width('100%')
            .lineHeight(24)

          Text('选择块数')
            .fontSize(15)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            .width('100%')
          Row({ space: 10 }) {
            this.PieceChip(4, '入门 4 块')
            this.PieceChip(9, '进阶 9 块')
            this.PieceChip(16, '挑战 16 块')
          }
          .width('100%')

          Row({ space: 10 }) {
            Text(this.collab ? '亲子轮流：开' : '亲子轮流：关')
              .fontSize(15)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
              .layoutWeight(1)
            Toggle({ type: ToggleType.Switch, isOn: this.collab })
              .selectedColor(Theme.colors().brandAccent)
              .onChange((v: boolean) => { this.collab = v })
          }
          .width('100%')
          .padding(12)
          .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
          .borderRadius(16)

          AppButton({
            label: this.collab ? '一起开始拼' : '开始拼图',
            onTap: (): void => {
              JigsawNav.openPlay(this.item.id, this.pieces, this.collab)
            }
          })
        }
        .padding({
          left: Theme.space.pageX,
          right: Theme.space.pageX,
          bottom: Theme.space.s10
        })
        .width('100%')
      }
      .layoutWeight(1)
      .align(Alignment.Top)
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.Spring)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }

  @Builder
  PieceChip(n: number, label: string) {
    Text(label)
      .fontSize(14)
      .fontWeight(FontWeight.Medium)
      .fontColor(this.pieces === n ? Theme.colors().brandOnPrimary : Theme.colors().textPrimary)
      .padding({ left: 12, right: 12, top: 10, bottom: 10 })
      .backgroundColor(this.pieces === n ? Theme.colors().brandPrimary : Theme.colors().surfaceCard)
      .borderRadius(Theme.radius.pill)
      .constraintSize({ minHeight: 44 })
      .onClick(() => { this.pieces = n })
  }
}
