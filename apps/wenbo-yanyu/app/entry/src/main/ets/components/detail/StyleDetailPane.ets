import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { DetailShell } from './DetailShell'
import { StyleGuideItem } from '../../models/LanguageCraftModels'
import { LanguageCraftMedia } from '../../services/LanguageCraftMedia'
import { LanguageCraftNav } from '../../services/LanguageCraftNav'

@Component
export struct StyleDetailPane {
  @StorageLink('darkModeOn') darkModeOn: boolean = false
  @Prop itemKey: string = 'formal'
  @Prop @Watch('onToken') refreshToken: number = 0
  @State item: StyleGuideItem = new StyleGuideItem()

  aboutToAppear(): void {
    this.reload()
  }

  onToken(): void {
    this.reload()
  }

  private reload(): void {
    this.item = StyleGuideItem.find(this.itemKey)
  }

  private applyStyle(): void {
    LanguageCraftNav.applyStyleToPolish(this.item.key, this.item.sample)
  }

  build() {
    DetailShell({ title: '风格说明', onClose: (): void => { LanguageCraftNav.closeStyle() } }) {
      Scroll() {
        Column({ space: Theme.space.s5 }) {
          Stack({ alignContent: Alignment.BottomStart }) {
            Image(LanguageCraftMedia.cover(this.item.coverKey))
              .width('100%')
              .height(200)
              .objectFit(ImageFit.Cover)
            Column()
              .width('100%')
              .height(110)
              .linearGradient({
                angle: 180,
                colors: [['rgba(26,26,46,0)', 0], ['rgba(26,26,46,0.78)', 1]]
              })
            Column({ space: 4 }) {
              Text(this.item.summary)
                .fontSize(Theme.type.caption)
                .fontColor(Theme.of(this.darkModeOn).brandAccent)
              Text(this.item.title)
                .fontSize(Theme.type.title2)
                .fontWeight(FontWeight.Medium)
                .fontColor('#F5F7FA')
            }
            .padding({ left: Theme.space.s4, right: Theme.space.s4, bottom: Theme.space.s4 })
            .alignItems(HorizontalAlign.Start)
            .width('100%')
          }
          .width('100%')
          .borderRadius(Theme.radius.lg)
          .clip(true)

          Column({ space: 8 }) {
            Text('适用场景')
              .fontSize(Theme.type.caption)
              .fontColor(Theme.of(this.darkModeOn).textTertiary)
              .width('100%')
            Text(this.item.body)
              .fontSize(Theme.type.body)
              .fontColor(Theme.of(this.darkModeOn).textPrimary)
              .lineHeight(26)
              .width('100%')
          }
          .width('100%')
          .padding(Theme.space.s4)
          .backgroundColor(Theme.of(this.darkModeOn).surfaceCard)
          .borderRadius(Theme.radius.lg)

          Column({ space: 8 }) {
            Text('可演示原文')
              .fontSize(Theme.type.caption)
              .fontColor(Theme.of(this.darkModeOn).textTertiary)
              .width('100%')
            Text(this.item.sample)
              .fontSize(Theme.type.footnote)
              .fontColor(Theme.of(this.darkModeOn).textSecondary)
              .width('100%')
          }
          .width('100%')
          .padding(Theme.space.s4)
          .backgroundColor(Theme.of(this.darkModeOn).surfaceSubtle)
          .borderRadius(Theme.radius.lg)

          AppButton({
            label: '用此风格润色样例',
            onTap: (): void => { this.applyStyle() }
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
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.Spring)
    }
  }
}
