import { Theme } from '../components/design-system/Theme'
import { AppButton } from '../components/design-system/AppButton'
import { AppNavBar } from '../components/design-system/AppNavBar'
import { TagItem } from '../models/ShiyiModels'
import { ShiyiNav } from '../services/ShiyiNav'
import { ShiyiStore } from '../services/ShiyiStore'

@Component
export struct TagManagePage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  onToast: (text: string) => void = (text: string) => {}
  @State tags: TagItem[] = []
  @State draft: string = ''

  aboutToAppear(): void {
    this.tags = ShiyiStore.tags()
  }

  private async addTag(): Promise<void> {
    const name = this.draft.trim()
    if (name.length === 0) {
      this.onToast('先写下标签名称。')
      return
    }
    for (const tag of this.tags) {
      if (tag.name === name) {
        this.onToast('这个标签已经在了。')
        return
      }
    }
    const item = new TagItem()
    item.id = ShiyiStore.newId('tag')
    item.name = name
    item.custom = true
    const next: TagItem[] = []
    for (const tag of this.tags) {
      next.push(tag)
    }
    next.push(item)
    const ok = await ShiyiStore.saveTags(next)
    if (!ok) {
      this.onToast('暂时无法保存，请稍后再试。')
      return
    }
    this.draft = ''
    this.tags = next
  }

  private async removeCustom(id: string): Promise<void> {
    const next: TagItem[] = []
    for (const tag of this.tags) {
      if (tag.id !== id) {
        next.push(tag)
      }
    }
    const ok = await ShiyiStore.saveTags(next)
    if (!ok) {
      this.onToast('暂时无法保存，请稍后再试。')
      return
    }
    this.tags = next
  }

  build() {
    Column() {
      AppNavBar({
        title: '标签管理',
        onBack: (): void => {
          ShiyiNav.closeTags()
        }
      })
      Scroll() {
        Column({ space: Theme.space.s4 }) {
          Text('默认标签可以一直用。你也可以加几个自己的。')
            .fontSize(Theme.type.subhead)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
            .width('100%')
          TextInput({ text: this.draft, placeholder: '新的标签' })
            .height(48)
            .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
            .borderRadius(Theme.radius.lg)
            .padding({ left: 14, right: 14 })
            .onChange((v: string) => {
              this.draft = v
            })
          AppButton({
            label: '加上这个标签',
            onTap: (): void => {
              void this.addTag()
            }
          })
          ForEach(this.tags, (tag: TagItem) => {
            Row() {
              Text(tag.name)
                .fontSize(Theme.type.body)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                .layoutWeight(1)
              if (tag.custom) {
                Text('放下')
                  .fontSize(Theme.type.footnote)
                  .fontColor(Theme.colors().textTertiary)
                  .onClick(() => {
                    void this.removeCustom(tag.id)
                  })
              }
            }
            .width('100%')
            .padding(Theme.space.s4)
            .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
            .borderRadius(Theme.radius.lg)
          }, (tag: TagItem) => tag.id)
        }
        .padding({
          left: Theme.space.pageX,
          right: Theme.space.pageX,
          bottom: Theme.space.s10
        })
      }
      .layoutWeight(1)
      .align(Alignment.Top)
      .scrollBar(BarState.Off)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }
}
