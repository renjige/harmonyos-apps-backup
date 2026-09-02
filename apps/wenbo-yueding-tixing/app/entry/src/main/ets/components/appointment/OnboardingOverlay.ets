import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'

class GuidePage {
  title: string = ''
  body: string = ''

  static all(): GuidePage[] {
    const a = new GuidePage()
    a.title = '记下就要守约'
    a.body = '会议、接送、学习、账单……创建约定时自动分类，并带上会前准备清单。'
    const b = new GuidePage()
    b.title = '简报 · 空档 · 逾期'
    b.body = '今日简报可复制出发时间；找空档扫描 7 天；逾期台可批量改到明天。'
    const c = new GuidePage()
    c.title = '粘贴导入与再约'
    c.body = '多行文本一次导入。详情可打卡到达、再约明天。冲突时推荐空闲时段。'
    return [a, b, c]
  }
}

@Component
export struct OnboardingOverlay {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @State index: number = 0
  private pages: GuidePage[] = GuidePage.all()
  onFinish: () => void = () => {}

  build() {
    Column() {
      Blank().height(48)
      Stack({ alignContent: Alignment.BottomStart }) {
        Image($r('app.media.hero_appointment'))
          .width('100%')
          .height(220)
          .objectFit(ImageFit.Cover)
          .borderRadius(Theme.radius.sheet)
        Column()
          .width('100%')
          .height(220)
          .linearGradient({
            angle: 180,
            colors: [['rgba(17,24,39,0.1)', 0], ['rgba(17,24,39,0.72)', 1]]
          })
          .borderRadius(Theme.radius.sheet)
      }
      .width('100%')
      .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
      Column({ space: Theme.space.s3 }) {
        Text(this.pages[this.index].title)
          .fontSize(Theme.type.title1)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .width('100%')
        Text(this.pages[this.index].body)
          .fontSize(Theme.type.body)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          .width('100%')
      }
      .padding({ left: Theme.space.s7, right: Theme.space.s7, top: Theme.space.s7 })
      Row({ space: 8 }) {
        ForEach([0, 1, 2], (i: number) => {
          Circle()
            .width(this.index === i ? 18 : 8)
            .height(8)
            .fill(this.index === i ? Theme.colors().brandPrimary : Theme.colors().brandPrimaryContainer)
            .borderRadius(Theme.radius.pill)
        }, (i: number) => `${i}`)
      }
      .margin({ top: Theme.space.s6 })
      Blank()
      Column() {
        AppButton({
          label: this.index >= 2 ? '开始使用' : '继续',
          onTap: (): void => {
            if (this.index >= 2) {
              this.onFinish()
            } else {
              this.index += 1
            }
          }
        })
      }
      .padding({
        left: Theme.space.s7,
        right: Theme.space.s7,
        bottom: Theme.space.s8
      })
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }
}
