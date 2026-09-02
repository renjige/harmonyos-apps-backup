import { Theme } from '../components/design-system/Theme'
import { AppButton } from '../components/design-system/AppButton'
import { AppIcon } from '../components/design-system/AppIcon'
import { PhotoHeroStack } from '../components/design-system/PhotoHeroStack'

/** 独有玩法中枢 — 审核 3.7：与「简单阅读记录」明确区隔 */
@Component
export struct StudioPlayPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop embedded: boolean = false
  @Prop appName: string = '读书札语'
  @Prop tagline: string = ''
  onClose: () => void = () => {}
  onOpenLamp: () => void = () => {}
  onOpenDialogue: () => void = () => {}
  onOpenBookAsk: () => void = () => {}
  onOpenChain: () => void = () => {}

  build() {
    Column() {
      if (this.embedded) {
        Row({ space: 12 }) {
          Image($r('app.media.app_icon'))
            .width(44)
            .height(44)
            .borderRadius(12)
            .objectFit(ImageFit.Cover)
          Column({ space: 4 }) {
            Text(this.appName)
              .fontSize(Theme.type.title2)
              .fontWeight(FontWeight.Bold)
              .fontColor(Theme.colors().textPrimary)
              .width('100%')
            Text(this.tagline.length > 0 ? this.tagline :
              '三种强制思考交互 · 不是摘抄本')
              .fontSize(Theme.type.footnote)
              .fontColor(Theme.colors().textSecondary)
              .maxLines(2)
              .width('100%')
          }
          .layoutWeight(1)
          .alignItems(HorizontalAlign.Start)
        }
        .width('100%')
        .padding({
          left: Theme.space.pageX,
          right: Theme.space.pageX,
          top: Theme.space.s2
        })
      } else {
        Row({ space: Theme.space.s2 }) {
          Column() {
            AppIcon({ name: 'close', iconSize: Theme.icon.md })
          }
          .width(44)
          .height(44)
          .justifyContent(FlexAlign.Center)
          .onClick((): void => { this.onClose() })
          Text('书房玩法')
            .fontSize(Theme.type.title3)
            .fontWeight(FontWeight.Medium)
            .fontColor(Theme.colors().textPrimary)
            .layoutWeight(1)
        }
        .width('100%')
        .padding({ left: Theme.space.pageX - 8, right: Theme.space.pageX, top: Theme.space.s2 })
      }

      Scroll() {
        Column({ space: Theme.space.s4 }) {
          if (this.embedded) {
            PhotoHeroStack({
              coverKey: 'hero_dialogue_books',
              heroHeight: 140,
              title: '强制思考，不是记录',
              subtitle: '未完成思考动作，无法产生核心产出'
            })
          }

          this.CompareTable()

          AppCardPlain({
            title: '核心产品：三种独有交互',
            body: '底栏「札语链」仅展示下列玩法产出。书架、计划等管理项在「我的 → 辅助工具」，非主路径。'
          })

          this.ModeCard(
            '① 灯下共读',
            '选 15/25/45 分钟陪读 → 倒计时结束 → 必须写下「今日一句」才记入打卡与札语',
            'lamp_session',
            '开始共读',
            (): void => { this.onOpenLamp() }
          )
          this.ModeCard(
            '② 对读札',
            '从金句库选两句 → 写它们为何能互相发明 → 保存为对照短文（非再摘第三句）',
            'dialogue_pair',
            '开始对读',
            (): void => { this.onOpenDialogue() }
          )
          this.ModeCard(
            '③ 问书三札',
            '选一本在读书 → 依次回答三个固定追问 → 形成结构化读书反思（非自由笔记）',
            'hero_dialogue_books',
            '开始问书',
            (): void => { this.onOpenBookAsk() }
          )

          if (this.embedded) {
            AppButton({
              label: '查看我的札语链',
              variant: 'secondary',
              onTap: (): void => { this.onOpenChain() }
            })
          }
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
    .width('100%')
    .height('100%')
    .backgroundColor(Theme.colors().surfacePage)
  }

  @Builder
  CompareTable() {
    Column({ space: Theme.space.s2 }) {
      Text('与同类阅读 App 的差异')
        .fontSize(Theme.type.subhead)
        .fontWeight(FontWeight.Medium)
        .fontColor(Theme.colors().textPrimary)
        .width('100%')
      this.CompareRow('计时打卡', '点按钮即完成', '灯下共读须写今日一句')
      this.CompareRow('金句摘录', '再抄一句进列表', '对读札：两句对照思考')
      this.CompareRow('自由笔记', '空白页随便写', '问书三札：三问模板必填')
    }
    .width('100%')
    .padding(Theme.space.s4)
    .backgroundColor(Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.lg)
    .border({ width: 1, color: Theme.colors().strokeHairline })
  }

  @Builder
  CompareRow(topic: string, generic: string, ours: string) {
    Column({ space: 4 }) {
      Text(topic)
        .fontSize(Theme.type.caption)
        .fontWeight(FontWeight.Medium)
        .fontColor(Theme.colors().textPrimary)
        .width('100%')
      Text(`同类常见：${generic}`)
        .fontSize(Theme.type.caption)
        .fontColor(Theme.colors().textSecondary)
        .width('100%')
      Text(`读书札语：${ours}`)
        .fontSize(Theme.type.caption)
        .fontColor(Theme.linkForeground())
        .width('100%')
    }
    .width('100%')
    .padding({ top: 6, bottom: 6 })
  }

  @Builder
  ModeCard(title: string, steps: string, coverKey: string, cta: string, onTap: () => void) {
    Column({ space: Theme.space.s3 }) {
      PhotoHeroStack({
        coverKey: coverKey,
        heroHeight: 120,
        title: title,
        compactTitle: true,
        cornerRadius: Theme.radius.lg
      })
      Text(steps)
        .fontSize(Theme.type.caption)
        .fontColor(Theme.colors().textSecondary)
        .width('100%')
        .lineHeight(20)
      AppButton({ label: cta, onTap: (): void => { onTap() } })
    }
    .width('100%')
    .padding(Theme.space.s4)
    .backgroundColor(Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.xl)
    .border({ width: 1, color: Theme.colors().strokeHairline })
  }
}

@Component
struct AppCardPlain {
  @Prop title: string = ''
  @Prop body: string = ''

  build() {
    Column({ space: 6 }) {
      Text(this.title)
        .fontSize(Theme.type.subhead)
        .fontWeight(FontWeight.Medium)
        .fontColor(Theme.colors().textPrimary)
        .width('100%')
      Text(this.body)
        .fontSize(Theme.type.caption)
        .fontColor(Theme.colors().textSecondary)
        .width('100%')
        .lineHeight(20)
    }
    .width('100%')
    .padding(Theme.space.s4)
    .backgroundColor(Theme.colors().surfaceSubtle)
    .borderRadius(Theme.radius.lg)
    .border({ width: 1, color: Theme.colors().strokeStrong })
  }
}
