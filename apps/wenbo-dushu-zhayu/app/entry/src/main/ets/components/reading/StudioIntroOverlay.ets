import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { PhotoHeroStack } from '../design-system/PhotoHeroStack'

/** 首次启动：向审核员/用户说明「不是阅读记录 App」（非隐私页） */
@Component
export struct StudioIntroOverlay {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  onDismiss: () => void = () => {}
  onTryLamp: () => void = () => {}

  build() {
    Column() {
      Scroll() {
        Column({ space: Theme.space.s4 }) {
          PhotoHeroStack({
            coverKey: 'lamp_session',
            heroHeight: 160,
            title: '读书札语 ≠ 阅读记录',
            subtitle: '三种强制思考交互 · 市场上少见的对照式书房'
          })
          Column({ space: Theme.space.s2 }) {
            Text('与摘抄本 / 打卡 App 的区别')
              .fontSize(Theme.type.subhead)
              .fontWeight(FontWeight.Medium)
              .fontColor(Theme.colors().textPrimary)
              .width('100%')
            this.DiffRow('计时打卡', '点一下就算完成')
            this.DiffRow('金句摘录', '再抄一句进列表')
            this.DiffRow('自由笔记', '空白页随便写')
            Text('本 App 对应')
              .fontSize(Theme.type.caption)
              .fontWeight(FontWeight.Medium)
              .fontColor(Theme.colors().textPrimary)
              .width('100%')
              .margin({ top: 6 })
            Text('① 灯下共读：结束须写今日一句\n② 对读札：两句对照思考\n③ 问书三札：三问模板必填')
              .fontSize(Theme.type.caption)
              .fontColor(Theme.linkForeground())
              .width('100%')
              .lineHeight(20)
          }
          .width('100%')
          .padding(Theme.space.s4)
          .backgroundColor(Theme.colors().surfaceCard)
          .borderRadius(Theme.radius.lg)
          .border({ width: 1, color: Theme.colors().strokeHairline })

          AppButton({
            label: '立即体验灯下共读',
            onTap: (): void => { this.onTryLamp() }
          })
          AppButton({
            label: '我知道了，进入书房玩法',
            variant: 'secondary',
            onTap: (): void => { this.onDismiss() }
          })
        }
        .padding({
          left: Theme.space.pageX,
          right: Theme.space.pageX,
          top: Theme.space.s6,
          bottom: Theme.space.s10
        })
        .width('100%')
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Theme.colors().surfacePage)
  }

  @Builder
  DiffRow(topic: string, generic: string) {
    Row({ space: 8 }) {
      Text(topic)
        .fontSize(Theme.type.caption)
        .fontWeight(FontWeight.Medium)
        .fontColor(Theme.colors().textSecondary)
        .width(72)
      Text(generic)
        .fontSize(Theme.type.caption)
        .fontColor(Theme.colors().textTertiary)
        .layoutWeight(1)
    }
    .width('100%')
  }
}
