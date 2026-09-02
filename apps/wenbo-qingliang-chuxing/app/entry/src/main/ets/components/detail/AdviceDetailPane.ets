import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { AppEmpty } from '../design-system/AppEmpty'
import { AppLoading } from '../design-system/AppLoading'
import { DetailShell } from './DetailShell'
import { AdviceItem } from '../../models/CoolModels'
import { CoolBizService } from '../../services/CoolBizService'
import { CoolDetailNav } from '../../services/CoolDetailNav'
import { CoolMedia } from '../../services/CoolMedia'

@Component
export struct AdviceDetailPane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop @Watch('onAdviceIdChange') adviceId: string = ''
  @Prop @Watch('onAdviceIdChange') refreshToken: number = 0
  @State item: AdviceItem | undefined = undefined
  @State loading: boolean = true

  aboutToAppear(): void {
    void this.reload()
  }

  onAdviceIdChange(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    this.loading = true
    this.item = await CoolBizService.findAdvice(this.adviceId)
    this.loading = false
  }

  private goRoutes(): void {
    CoolDetailNav.switchTabRoutes()
    CoolDetailNav.close()
  }

  build() {
    if (this.loading) {
      Column() { AppLoading({ label: '打开建议' }) }
        .width('100%').height('100%').justifyContent(FlexAlign.Center)
        .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
    } else if (this.item === undefined) {
      DetailShell({ title: '出行建议', onClose: () => CoolDetailNav.close() }) {
        AppEmpty({ title: '建议不存在' })
      }
    } else {
      DetailShell({ title: this.item.title, contentKey: this.adviceId, onClose: () => CoolDetailNav.close() }) {
        Column({ space: Theme.space.s4 }) {
          Stack({ alignContent: Alignment.BottomStart }) {
            Image(CoolMedia.resource(this.item !== undefined ? this.item.coverKey : 'advice_dress'))
              .width('100%').height(200).objectFit(ImageFit.Cover)
            Column()
              .width('100%').height(96)
              .linearGradient({
                angle: 180,
                colors: [['rgba(11,42,54,0)', 0], ['rgba(11,42,54,0.82)', 1]]
              })
            Text(this.item !== undefined ? this.item.title : '')
              .fontSize(Theme.type.title2)
              .fontWeight(FontWeight.Bold)
              .fontColor('#FFFFFF')
              .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: 16 })
          }
          .width('100%').height(200)

          Column({ space: 8 }) {
            Text(`${this.item !== undefined ? this.item.categoryLabel() : ''} · ${this.item !== undefined ? this.item.condition : ''}`)
              .fontSize(Theme.type.footnote).fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary).width('100%')
            Text(this.item !== undefined ? this.item.summary : '')
              .fontSize(Theme.type.body).fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary).width('100%')
            Text(this.item !== undefined ? this.item.body : '')
              .fontSize(Theme.type.footnote).fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary).width('100%')
            Text('天气与穿衣建议仅供出行参考，不替代气象台预警。')
              .fontSize(Theme.type.caption).fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary).width('100%')
          }
          .padding({ left: Theme.space.pageX, right: Theme.space.pageX })

          Column({ space: Theme.space.s3 }) {
            AppButton({ label: '去对比清凉路线', onTap: (): void => this.goRoutes() })
            AppButton({
              label: '做一次出行自检',
              variant: 'secondary',
              onTap: (): void => CoolDetailNav.openDiagnose()
            })
          }
          .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
        }
        .width('100%')
      }
    }
  }
}
