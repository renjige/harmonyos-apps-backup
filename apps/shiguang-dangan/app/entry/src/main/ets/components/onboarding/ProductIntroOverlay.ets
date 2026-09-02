import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { AppIcon } from '../design-system/AppIcon'
import { LifeStore } from '../../services/LifeStore'
import { ArchiveDetailNav } from '../../services/ArchiveDetailNav'

class IntroStep {
  title: string = ''
  body: string = ''
  emoji: string = ''

  static make(title: string, body: string, emoji: string): IntroStep {
    const s = new IntroStep()
    s.title = title
    s.body = body
    s.emoji = emoji
    return s
  }
}

@Component
export struct ProductIntroOverlay {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  onDismiss: () => void = () => {}
  @State step: number = 0
  private steps: IntroStep[] = [
    IntroStep.make('记录', '写下成长、家庭与里程碑，把散落的记忆收进一份份档案。', '📝'),
    IntroStep.make('整理', '用分类、标签与时间轴，让每一段经历都有清晰的脉络。', '🗂️'),
    IntroStep.make('回顾', '日历与往年今日，帮你重新看见那些值得记住的时光。', '📅')
  ]

  private async finish(): Promise<void> {
    await LifeStore.markOnboardingSeen()
    this.onDismiss()
  }

  private async startCreate(): Promise<void> {
    await LifeStore.markOnboardingSeen()
    this.onDismiss()
    ArchiveDetailNav.openCreateArchive()
  }

  build() {
    Stack() {
      Column()
        .width('100%')
        .height('100%')
        .backgroundColor(Theme.colors().overlayScrim)
      Column({ space: Theme.space.s6 }) {
        Row() {
          Blank()
          Column() {
            AppIcon({ name: 'close', iconSize: Theme.icon.md, color: Theme.colors().textSecondary })
          }
          .width(44)
          .height(44)
          .justifyContent(FlexAlign.Center)
          .onClick((): void => { void this.finish() })
        }
        .width('100%')

        Text(this.steps[this.step].emoji)
          .fontSize(48)
        Text(this.steps[this.step].title)
          .fontSize(Theme.type.title2)
          .fontWeight(FontWeight.Bold)
          .fontColor(Theme.colors().textPrimary)
        Text(this.steps[this.step].body)
          .fontSize(Theme.type.body)
          .fontColor(Theme.colors().textSecondary)
          .lineHeight(24)
          .textAlign(TextAlign.Center)

        Row({ space: Theme.space.s2 }) {
          ForEach(this.steps, (_: IntroStep, idx: number) => {
            Column()
              .width(idx === this.step ? 20 : 8)
              .height(8)
              .backgroundColor(idx === this.step ? Theme.colors().brandPrimary : Theme.colors().surfaceSubtle)
              .borderRadius(Theme.radius.pill)
          }, (_: IntroStep, idx: number) => `${idx}`)
        }

        if (this.step < this.steps.length - 1) {
          AppButton({
            label: '下一步',
            variant: 'primary',
            onTap: (): void => { this.step++ }
          })
        } else {
          AppButton({
            label: '创建第一份档案',
            variant: 'primary',
            onTap: (): void => { void this.startCreate() }
          })
          AppButton({
            label: '稍后再说',
            variant: 'secondary',
            onTap: (): void => { void this.finish() }
          })
        }
      }
      .width('88%')
      .padding(Theme.space.s6)
      .backgroundColor(Theme.colors().surfaceCard)
      .borderRadius(Theme.radius.xl)
    }
    .width('100%')
    .height('100%')
    .zIndex(70)
  }
}
