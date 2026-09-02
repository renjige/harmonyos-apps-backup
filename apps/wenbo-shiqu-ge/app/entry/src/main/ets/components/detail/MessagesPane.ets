import { Theme } from '../design-system/Theme'
import { AppEmpty } from '../design-system/AppEmpty'
import { DetailShell } from './DetailShell'
import { MsgWire } from '../../models/PavilionModels'
import { PavilionBizService } from '../../services/PavilionBizService'
import { PavilionDetailNav } from '../../services/PavilionDetailNav'

@Component
export struct MessagesPane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @StorageLink('darkModeOn') darkModeOn: boolean = false
  @Prop @Watch('onRefreshTokenChange') refreshToken: number = 0
  @State items: MsgWire[] = []

  aboutToAppear(): void {
    void this.reload()
  }

  onRefreshTokenChange(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    this.items = await PavilionBizService.loadMessages()
  }

  build() {
    DetailShell({ title: '机构通知', onClose: (): void => { PavilionDetailNav.close() } }) {
      if (this.items.length === 0) {
        AppEmpty({
          title: '暂无通知',
          description: '机构广播会显示在这里。',
          actionLabel: '重新加载',
          onAction: (): void => { void this.reload() }
        })
      } else {
        Scroll() {
          Column({ space: Theme.space.s3 }) {
            ForEach(this.items, (m: MsgWire) => {
              Column({ space: 6 }) {
                Text(m.title)
                  .fontSize(Theme.type.subtitleS)
                  .fontWeight(FontWeight.Medium)
                  .fontColor(Theme.textMain(this.themeEpoch, this.darkModeOn))
                  .width('100%')
                Text(m.body)
                  .fontSize(Theme.type.footnote)
                  .fontColor(Theme.textSub(this.themeEpoch, this.darkModeOn))
                  .width('100%')
              }
              .width('100%')
              .padding(Theme.space.s4)
              .backgroundColor(Theme.cardBg(this.themeEpoch, this.darkModeOn))
              .borderRadius(Theme.radius.card)
            }, (m: MsgWire) => m.id)
          }
          .padding({
            left: Theme.space.pageX,
            right: Theme.space.pageX,
            bottom: Theme.space.s10
          })
          .width('100%')
        }
        .width('100%')
        .layoutWeight(1)
        .scrollBar(BarState.Off)
      }
    }
  }
}
