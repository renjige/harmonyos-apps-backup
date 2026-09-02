import { Theme } from '../components/design-system/Theme'
import { AppButton } from '../components/design-system/AppButton'
import { AppIcon } from '../components/design-system/AppIcon'

@Component
export struct IngredientIdeaPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @State selected: string = ''
  @State hint: string = ''
  onShowResults: (ingredients: string[]) => void = (_ingredients: string[]) => {}

  private ingredients(): string[] {
    return ['鸡蛋', '番茄', '土豆', '鸡胸肉', '牛肉', '虾', '豆腐', '青菜', '蘑菇', '面条']
  }

  private selectedParts(): string[] {
    const out: string[] = []
    if (this.selected.length === 0) return out
    for (const p of this.selected.split(',')) {
      if (p.trim().length > 0) out.push(p.trim())
    }
    return out
  }

  private isSelected(text: string): boolean {
    for (const p of this.selectedParts()) {
      if (p === text) return true
    }
    return false
  }

  private toggle(text: string): void {
    const next: string[] = []
    let existed = false
    for (const p of this.selectedParts()) {
      if (p === text) {
        existed = true
      } else {
        next.push(p)
      }
    }
    if (!existed) next.push(text)
    this.selected = next.join(',')
    this.hint = ''
  }

  private start(): void {
    const parts = this.selectedParts()
    if (parts.length === 0) {
      this.hint = '先选择几样家里有的食材吧'
      return
    }
    this.onShowResults(parts)
  }

  build() {
    Scroll() {
      Column({ space: Theme.space.s6 }) {
        Column({ space: Theme.space.s2 }) {
          Text('灵感')
            .fontSize(Theme.type.caption)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          Text('食材妙想')
            .fontSize(34)
            .fontWeight(FontWeight.Bold)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
          Text('选择家里已有食材，为你自动搭配适合今天的做法。')
            .fontSize(Theme.type.body)
            .lineHeight(24)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
            .width('100%')
        }
        .width('100%')
        .padding({ top: Theme.space.s4 })
        .alignItems(HorizontalAlign.Start)

        Column({ space: Theme.space.s3 }) {
          Row({ space: Theme.space.s2 }) {
            this.Chip('鸡蛋')
            this.Chip('番茄')
            this.Chip('土豆')
          }
          Row({ space: Theme.space.s2 }) {
            this.Chip('鸡胸肉')
            this.Chip('牛肉')
            this.Chip('虾')
          }
          Row({ space: Theme.space.s2 }) {
            this.Chip('豆腐')
            this.Chip('青菜')
            this.Chip('蘑菇')
          }
          Row({ space: Theme.space.s2 }) {
            this.Chip('面条')
          }
        }
        .width('100%')
        .padding(Theme.space.s4)
        .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
        .borderRadius(Theme.radius.card)

        if (this.hint.length > 0) {
          Text(this.hint)
            .fontSize(Theme.type.subhead)
            .fontColor(Theme.colors().warning)
            .width('100%')
            .textAlign(TextAlign.Center)
        }

        AppButton({
          label: '开始妙想',
          variant: 'primary',
          onTap: (): void => this.start()
        })

        Row({ space: Theme.space.s3 }) {
          AppIcon({ name: 'spark', iconSize: Theme.icon.md, color: Theme.colors().warning })
          Text('智慧推荐会优先匹配已选食材，再兼顾烹饪时间和难度。')
            .fontSize(Theme.type.footnote)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
            .lineHeight(18)
            .layoutWeight(1)
        }
        .width('100%')
        .padding(Theme.space.s4)
        .backgroundColor(Theme.colors().warningContainer)
        .borderRadius(Theme.radius.lg)
      }
      .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s10 })
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
    .scrollBar(BarState.Off)
    .edgeEffect(EdgeEffect.Spring)
  }

  @Builder
  Chip(text: string) {
    Text(text)
      .fontSize(Theme.type.subhead)
      .fontWeight(this.isSelected(text) ? FontWeight.Bold : FontWeight.Normal)
      .fontColor(this.isSelected(text) ? Theme.colors().brandOnPrimary : Theme.colors().brandPrimary)
      .padding({ left: 16, right: 16, top: 10, bottom: 10 })
      .backgroundColor(this.isSelected(text) ? Theme.colors().brandPrimary : Theme.colors().brandPrimaryContainer)
      .borderRadius(Theme.radius.pill)
      .scale({ x: this.isSelected(text) ? 1.03 : 1, y: this.isSelected(text) ? 1.03 : 1 })
      .animation({ duration: Theme.motion.fast, curve: Curve.EaseOut })
      .onClick(() => this.toggle(text))
  }
}
