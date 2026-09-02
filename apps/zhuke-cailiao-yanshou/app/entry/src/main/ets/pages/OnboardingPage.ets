import { Theme } from '../components/design-system/Theme'
import { AppButton } from '../components/design-system/AppButton'
import { InspectLocalStore } from '../services/InspectLocalStore'

class GuidePage {
  title: string = ''
  body: string = ''
}

@Component
export struct OnboardingPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @State index: number = 0
  onDone: () => void = () => {}

  private pages(): GuidePage[] {
    const out: GuidePage[] = []
    const a = new GuidePage()
    a.title = '工点批次一次记清'
    a.body = '材料到场后填写工点、批次、名称与规格，完成进场登记。'
    out.push(a)
    const b = new GuidePage()
    b.title = '按品类核对应查项'
    b.body = '打开品类要点，对照外观、资料与专项检查，再拍现场照片留痕。'
    out.push(b)
    const c = new GuidePage()
    c.title = '异常跟进可闭环'
    c.body = '不通过或待处理可写整改说明、发起复验，记录按日期筛选可查。'
    out.push(c)
    return out
  }

  private current(): GuidePage {
    const list = this.pages()
    let i = 0
    for (const p of list) {
      if (i === this.index) {
        return p
      }
      i += 1
    }
    const empty = new GuidePage()
    return empty
  }

  private async finish(): Promise<void> {
    await InspectLocalStore.setOnboardingDone()
    this.onDone()
  }

  private next(): void {
    if (this.index >= 2) {
      void this.finish()
      return
    }
    this.index = this.index + 1
  }

  build() {
    Column() {
      Blank().layoutWeight(1)
      Image($r('app.media.empty_inspect'))
        .width(220)
        .height(140)
        .objectFit(ImageFit.Contain)
      Text(this.current().title)
        .fontSize(Theme.type.title1)
        .fontWeight(FontWeight.Medium)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
        .margin({ top: 24 })
      Text(this.current().body)
        .fontSize(Theme.type.body)
        .fontColor(Theme.colors().textPrimary)
        .textAlign(TextAlign.Center)
        .margin({ top: 12, left: 32, right: 32 })
      Blank().layoutWeight(1)
      AppButton({
        label: this.index >= 2 ? '开始使用' : '继续',
        onTap: () => this.next()
      })
      if (this.index < 2) {
        AppButton({
          label: '跳过',
          variant: 'ghost',
          onTap: (): void => { void this.finish() }
        })
      }
    }
    .width('100%')
    .height('100%')
    .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s8 })
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }
}
