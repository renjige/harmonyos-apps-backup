import { Theme } from '../design-system/Theme'
import { CategoryOption, ObserveTag } from '../../models/ObserveCatalog'

@Component
export struct CategoryTagFields {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop categoryKey: string = 'nature'
  @Prop tags: string = ''
  @Prop itemName: string = ''
  onCategory: (key: string) => void = () => {}
  onTags: (value: string) => void = () => {}
  onItemName: (value: string) => void = () => {}

  private tagOn(name: string): boolean {
    const parts = this.tags.split(',')
    for (const p of parts) {
      if (p.trim() === name) {
        return true
      }
    }
    return false
  }

  private toggleTag(name: string): void {
    const next: string[] = []
    let found = false
    const parts = this.tags.split(',')
    for (const p of parts) {
      const t = p.trim()
      if (t.length === 0) {
        continue
      }
      if (t === name) {
        found = true
      } else {
        next.push(t)
      }
    }
    if (!found) {
      next.push(name)
    }
    this.onTags(next.join(','))
  }

  build() {
    Column({ space: Theme.space.s3 }) {
      Text('观察分类')
        .fontSize(Theme.type.caption)
        .fontColor(Theme.colors().textSecondary)
        .width('100%')
      Flex({ wrap: FlexWrap.Wrap }) {
        ForEach(CategoryOption.all(), (c: CategoryOption) => {
          Text(c.label)
            .fontSize(Theme.type.caption)
            .fontColor(this.categoryKey === c.key ? Theme.colors().brandOnPrimary : Theme.colors().textSecondary)
            .padding({ left: 10, right: 10, top: 6, bottom: 6 })
            .margin({ right: 8, bottom: 8 })
            .backgroundColor(this.categoryKey === c.key ? Theme.colors().brandPrimary : Theme.colors().surfaceSubtle)
            .borderRadius(Theme.radius.pill)
            .onClick((): void => this.onCategory(c.key))
        }, (c: CategoryOption) => c.key)
      }
      .width('100%')

      Text('物品名称（写入图鉴）')
        .fontSize(Theme.type.caption)
        .fontColor(Theme.colors().textSecondary)
        .width('100%')
      TextInput({ text: this.itemName, placeholder: '如：窗台绿萝、旧铁盒…' })
        .fontSize(Theme.type.body)
        .fontColor(Theme.colors().textPrimary)
        .backgroundColor(Theme.colors().surfaceSubtle)
        .borderRadius(Theme.radius.sm)
        .onChange((v: string): void => this.onItemName(v))

      Text('标签')
        .fontSize(Theme.type.caption)
        .fontColor(Theme.colors().textSecondary)
        .width('100%')
      Row({ space: Theme.space.s2 }) {
        ForEach(ObserveTag.presets(), (name: string) => {
          Text(name)
            .fontSize(Theme.type.caption)
            .fontColor(this.tagOn(name) ? Theme.colors().brandOnPrimary : Theme.colors().textSecondary)
            .padding({ left: 10, right: 10, top: 6, bottom: 6 })
            .backgroundColor(this.tagOn(name) ? Theme.colors().brandPrimary : Theme.colors().surfaceSubtle)
            .borderRadius(Theme.radius.pill)
            .onClick((): void => this.toggleTag(name))
        }, (name: string) => name)
      }
      .width('100%')
    }
    .width('100%')
  }
}
