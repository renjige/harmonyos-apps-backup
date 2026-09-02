import { Theme } from '../design-system/Theme'
import { AppIcon } from '../design-system/AppIcon'
import { RenoMedia } from '../../services/RenoMedia'

@Component
export struct DetailShell {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop title: string = '详情'
  @Prop coverKey: string = 'home_hero'
  onBack: () => void = () => {}
  @BuilderParam content: () => void

  build() {
    Column() {
      Stack() {
        Image(RenoMedia.cover(this.coverKey))
          .width('100%')
          .height(220)
          .objectFit(ImageFit.Cover)
        Column()
          .width('100%')
          .height(220)
          .linearGradient({
            angle: 180,
            colors: [['#00000000', 0.35], ['#CC111827', 1.0]]
          })
        Column() {
          Row() {
            Row({ space: 4 }) {
              AppIcon({ name: 'close', iconSize: Theme.icon.md, color: '#FFFFFF' })
              Text('返回')
                .fontSize(Theme.type.body)
                .fontColor('#FFFFFF')
            }
            .height(44)
            .onClick(() => this.onBack())
          }
          .width('100%')
          .padding({ left: Theme.space.pageX, right: Theme.space.pageX, top: 12 })
          Blank()
          Text(this.title)
            .fontSize(Theme.type.title2)
            .fontWeight(FontWeight.Bold)
            .fontColor('#FFFFFF')
            .width('100%')
            .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: 20 })
        }
        .width('100%')
        .height(220)
      }
      .width('100%')
      .height(220)

      Scroll() {
        Column() {
          this.content()
        }
        .width('100%')
        .padding({
          left: Theme.space.pageX,
          right: Theme.space.pageX,
          top: Theme.space.s5,
          bottom: Theme.space.s10
        })
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)
      .align(Alignment.Top)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }
}
