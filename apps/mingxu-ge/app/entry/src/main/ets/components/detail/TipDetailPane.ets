import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { AppCard } from '../design-system/AppCard'
import { XuTipItem } from '../../models/XuModels'
import { XuBizService } from '../../services/XuBizService'
import { XuMedia } from '../../services/XuMedia'
import { XuDetailNav } from '../../services/XuDetailNav'

@Component
export struct TipDetailPane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop @Watch('onIdChange') tipId: string = ''
  @State item: XuTipItem = new XuTipItem()

  aboutToAppear(): void {
    void this.reload()
  }

  onIdChange(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    const found = await XuBizService.findTip(this.tipId)
    if (found !== undefined) {
      this.item = found
    }
  }

  build() {
    Scroll() {
      Column({ space: Theme.space.s4 }) {
        Stack({ alignContent: Alignment.BottomStart }) {
          Image(XuMedia.forCover(this.item.coverKey))
            .width('100%')
            .height(180)
            .objectFit(ImageFit.Cover)
          Column() {
            Text(`约 ${this.item.readMinutes} 分钟`)
              .fontSize(Theme.type.caption)
              .fontColor('#FFFFFF')
            Text(this.item.title)
              .fontSize(Theme.type.title2)
              .fontWeight(FontWeight.Bold)
              .fontColor('#FFFFFF')
          }
          .width('100%')
          .padding(Theme.space.s4)
          .linearGradient({
            angle: 180,
            colors: [['rgba(26,42,58,0)', 0], ['rgba(26,42,58,0.82)', 1]]
          })
        }
        .width('100%')
        .borderRadius(Theme.radius.xl)
        .clip(true)

        AppCard({ title: '导语' }) {
          Text(this.item.summary)
            .fontSize(Theme.type.body)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            .width('100%')
        }
        AppCard({ title: '正文' }) {
          Text(this.item.body.length > 0 ? this.item.body : this.item.summary)
            .fontSize(Theme.type.body)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            .width('100%')
        }
        AppButton({
          label: '去日程里落实一件事',
          onTap: (): void => {
            XuDetailNav.closeTip()
            XuDetailNav.openAgendaEditor('')
          }
        })
        Column().height(Theme.space.s10)
      }
      .padding({ left: Theme.space.pageX, right: Theme.space.pageX, top: Theme.space.s3 })
      .width('100%')
    }
    .width('100%')
    .height('100%')
    .align(Alignment.Top)
  }
}
