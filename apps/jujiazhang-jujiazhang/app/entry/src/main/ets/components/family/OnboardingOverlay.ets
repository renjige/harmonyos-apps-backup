import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { AppIcon, AppIconName } from '../design-system/AppIcon'
import { TaskMedia } from '../../services/TaskMedia'

class OnboardSlide {
  title: string = ''
  body: string = ''
  icon: AppIconName = 'home'
}

@Component
export struct OnboardingOverlay {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @State step: number = 0
  onFinish: () => void = () => {}

  private slides(): OnboardSlide[] {
    const out: OnboardSlide[] = []
    const s0 = new OnboardSlide()
    s0.title = '打开即见生活发现'
    s0.body = '底栏第一个 Tab 就是「发现」：8 大场景、居家指南与维护模板，不是简单记待办。'
    s0.icon = 'home'
    out.push(s0)
    const s1 = new OnboardSlide()
    s1.title = '发现 Tab · 生活场景包'
    s1.body = '底栏「发现」直达 8 大场景、居家指南与维护模板，一键生成清单 + 计划 + 备忘。'
    s1.icon = 'check'
    out.push(s1)
    const s2 = new OnboardSlide()
    s2.title = '搜索 · 收藏 · 成长'
    s2.body = '跨模块全局搜索；常用内容收藏；时间轴、成就与周报告回顾。'
    s2.icon = 'search'
    out.push(s2)
    const s3 = new OnboardSlide()
    s3.title = '家人协作'
    s3.body = '轮值盖章、物品到期提醒、计划月历与家庭目标，一起把家管好。'
    s3.icon = 'user'
    out.push(s3)
    return out
  }

  private current(): OnboardSlide {
    const list = this.slides()
    if (this.step < 0 || this.step >= list.length) {
      return list[0]
    }
    return list[this.step]
  }

  private next(): void {
    const last = this.slides().length - 1
    if (this.step >= last) {
      this.onFinish()
      return
    }
    this.step += 1
  }

  build() {
    Column() {
      Blank().layoutWeight(1)
      Image(TaskMedia.cover('home_hero'))
        .width(100)
        .height(100)
        .borderRadius(24)
        .objectFit(ImageFit.Cover)
      AppIcon({ name: this.current().icon, iconSize: 28, color: Theme.colors().brandPrimary })
        .margin({ top: 20 })
      Text(this.current().title)
        .fontSize(Theme.type.titleM)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
        .margin({ top: 16 })
      Text(this.current().body)
        .fontSize(Theme.type.body)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
        .margin({ top: 10, left: 28, right: 28 })
        .textAlign(TextAlign.Center)
      Row({ space: 6 }) {
        ForEach(this.slides(), (_s: OnboardSlide, idx: number) => {
          Column()
            .width(idx === this.step ? 18 : 6)
            .height(6)
            .borderRadius(3)
            .backgroundColor(idx === this.step ? Theme.colors().brandPrimary : Theme.colors().strokeHairline)
        }, (_s: OnboardSlide, idx: number) => `dot_${idx}`)
      }
      .margin({ top: 24 })
      Blank().layoutWeight(1)
      AppButton({
        label: this.step >= this.slides().length - 1 ? '进入工作台' : '下一步',
        variant: 'primary',
        onTap: (): void => { this.next() }
      })
        .width('100%')
        .margin({ bottom: 28 })
    }
    .width('100%')
    .height('100%')
    .padding({ left: 28, right: 28, top: 48, bottom: 24 })
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }
}
