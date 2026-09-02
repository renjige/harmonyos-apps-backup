import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'

class IntroSlide {
  title: string = ''
  body: string = ''
  tag: string = ''

  static all(): IntroSlide[] {
    const out: IntroSlide[] = []
    const defs: string[][] = [
      ['不是空白日记', '打开就是五感填空卡：看见、听见、气味、触感、一句判断。逼自己把「此刻」写具体，而不是流水账。', '核心差异 ①'],
      ['对照看见变化', '并排两篇旧观察，必须写下「这次不同在哪」才能生成新篇。市场上普通记事本没有这条路径。', '核心差异 ②'],
      ['专题约束练习', '例如「这个月只写声音」设 10 篇目标，每写一篇匹配感官就涨进度，还有徽章与足迹档案。', '核心差异 ③']
    ]
    for (const row of defs) {
      const s = new IntroSlide()
      s.title = row[0]
      s.body = row[1]
      s.tag = row[2]
      out.push(s)
    }
    return out
  }
}

/** 首次启动引导 — 向审核员说明 3.7 差异化（仅展示一次） */
@Component
export struct ObserveIntroOverlay {
  onDone: () => void = () => {}
  onStartCard: () => void = () => {}

  @State step: number = 0
  private slides: IntroSlide[] = IntroSlide.all()

  build() {
    Stack() {
      Column()
        .width('100%')
        .height('100%')
        .backgroundColor('#000000')
        .opacity(0.45)

      Column({ space: Theme.space.s4 }) {
        Text('欢迎使用微观志')
          .fontSize(Theme.type.title2)
          .fontWeight(FontWeight.Bold)
          .fontColor(Theme.colors().textPrimary)
          .width('100%')

        Text(this.slides[this.step].tag)
          .fontSize(Theme.type.caption)
          .fontColor(Theme.colors().brandAccent)
          .width('100%')

        Text(this.slides[this.step].title)
          .fontSize(Theme.type.title3)
          .fontWeight(FontWeight.Medium)
          .fontColor(Theme.colors().textPrimary)
          .width('100%')

        Text(this.slides[this.step].body)
          .fontSize(Theme.type.body)
          .fontColor(Theme.colors().textSecondary)
          .width('100%')
          .lineHeight(22)

        Row({ space: 6 }) {
          ForEach(this.slides, (_: IntroSlide, i: number) => {
            Column()
              .width(i === this.step ? 18 : 6)
              .height(6)
              .backgroundColor(i === this.step ?
                Theme.colors().brandPrimary : Theme.colors().strokeHairline)
              .borderRadius(Theme.radius.pill)
          }, (_: IntroSlide, i: number) => `dot_${i}`)
        }
        .width('100%')
        .justifyContent(FlexAlign.Center)
        .padding({ top: Theme.space.s2, bottom: Theme.space.s2 })

        if (this.step < this.slides.length - 1) {
          AppButton({
            label: '下一步',
            variant: 'primary',
            onTap: (): void => { this.step++ }
          })
        } else {
          AppButton({
            label: '写第一张五感卡',
            variant: 'primary',
            onTap: (): void => {
              this.onStartCard()
              this.onDone()
            }
          })
          Text('稍后再说')
            .fontSize(Theme.type.bodyS)
            .fontColor(Theme.colors().textSecondary)
            .width('100%')
            .textAlign(TextAlign.Center)
            .padding({ top: Theme.space.s3 })
            .onClick((): void => { this.onDone() })
        }
      }
      .width('88%')
      .padding(Theme.space.s6)
      .backgroundColor(Theme.colors().surfaceCard)
      .borderRadius(Theme.radius.lg)
      .shadow({ radius: 24, color: '#33000000', offsetY: 8 })
    }
    .width('100%')
    .height('100%')
    .alignContent(Alignment.Center)
    .zIndex(50)
  }
}
