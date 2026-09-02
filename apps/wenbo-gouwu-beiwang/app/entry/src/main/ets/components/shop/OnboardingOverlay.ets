import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { BrandIdentity } from '../../config/BrandIdentity'

class GuidePage {
  title: string = ''
  body: string = ''

  static all(): GuidePage[] {
    const a = new GuidePage()
    a.title = BrandIdentity.appName()
    a.body = `开发者：${BrandIdentity.developer()}。看到想买的东西，打开应用马上记下。只需要一个名称。`
    const b = new GuidePage()
    b.title = '整理得更清楚'
    b.body = '物品会按食品、日用品等分类排好，出门勾选更从容。'
    const c = new GuidePage()
    c.title = '提醒你别忘记'
    c.body = '给今天或明天设一个温和提醒，少一点遗漏，多一点从容。'
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
      Image($r('app.media.home_hero'))
        .width('100%')
        .height(220)
        .objectFit(ImageFit.Cover)
        .borderRadius(Theme.radius.sheet)
        .margin({ left: Theme.space.pageX, right: Theme.space.pageX })
      Column({ space: Theme.space.s3 }) {
        Text(this.pages[this.index].title)
          .fontSize(Theme.type.title1)
          .fontWeight(FontWeight.Bold)
          .fontColor(Theme.paint(this.themeEpoch).textPrimary)
          .width('100%')
        Text(this.pages[this.index].body)
          .fontSize(Theme.type.body)
          .fontColor(Theme.paint(this.themeEpoch).textSecondary)
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
    .backgroundColor(Theme.paint(this.themeEpoch).surfacePage)
  }
}
