import { Theme } from '../components/design-system/Theme'
import { AppIcon } from '../components/design-system/AppIcon'
import { ConfirmSheet } from '../components/journal/ConfirmSheet'
import { CornerTag } from '../models/YouyuModels'
import { YouyuNav } from '../services/YouyuNav'
import { YouyuStore } from '../services/YouyuStore'

@Component
export struct TagManagePage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @StorageLink('youyuRev') @Watch('onStoreRev') storeRev: number = 0
  @State tags: CornerTag[] = []
  @State draft: string = ''
  @State toastText: string = ''
  @State pendingDelete: string = ''

  aboutToAppear(): void {
    this.reloadTags()
  }

  onStoreRev(): void {
    this.reloadTags()
  }

  private reloadTags(): void {
    this.tags = YouyuStore.tags()
  }

  private showToast(msg: string): void {
    this.toastText = msg
    setTimeout(() => { this.toastText = '' }, 2200)
  }

  private async addTag(): Promise<void> {
    const name = this.draft.trim()
    if (name.length === 0) {
      this.showToast('请输入标签名')
      return
    }
    for (const t of this.tags) {
      if (t.name === name) {
        this.showToast('标签已存在')
        return
      }
    }
    const tag = new CornerTag()
    tag.id = YouyuStore.newId('tag')
    tag.name = name
    tag.custom = true
    const next: CornerTag[] = []
    for (const t of this.tags) {
      next.push(t)
    }
    next.push(tag)
    const ok = await YouyuStore.saveTags(next)
    if (ok) {
      this.tags = next
      this.draft = ''
      this.showToast('已添加')
      return
    }
    this.showToast('保存失败')
  }

  private async doDelete(): Promise<void> {
    const id = this.pendingDelete
    const next: CornerTag[] = []
    for (const t of this.tags) {
      if (t.id !== id) {
        next.push(t)
      }
    }
    const ok = await YouyuStore.saveTags(next)
    this.pendingDelete = ''
    if (ok) {
      this.tags = next
      return
    }
    this.showToast('删除失败')
  }

  build() {
    Stack() {
      Column() {
        Row() {
          Column() {
            AppIcon({ name: 'chevron', iconSize: Theme.icon.md, color: Theme.colors().textPrimary })
          }
          .width(48)
          .height(48)
          .justifyContent(FlexAlign.Center)
          .rotate({ angle: 180 })
          .onClick(() => YouyuNav.closeTags())
          Text('标签管理')
            .fontSize(Theme.type.title3)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            .layoutWeight(1)
        }
        .width('100%')
        .padding({ right: Theme.space.pageX })

        Row({ space: 8 }) {
          TextInput({ text: this.draft, placeholder: '新标签名称' })
            .layoutWeight(1)
            .height(48)
            .onChange((v: string) => { this.draft = v })
          Text('添加')
            .fontSize(Theme.type.body)
            .fontWeight(FontWeight.Medium)
            .fontColor(Theme.colors().brandOnPrimary)
            .padding({ left: 16, right: 16, top: 12, bottom: 12 })
            .constraintSize({ minHeight: 48 })
            .backgroundColor(Theme.colors().brandPrimary)
            .borderRadius(Theme.radius.button)
            .onClick(() => { void this.addTag() })
        }
        .width('100%')
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX })

        Scroll() {
          Column({ space: Theme.space.s3 }) {
            ForEach(this.tags, (t: CornerTag) => {
              Row() {
                Text(t.name)
                  .fontSize(Theme.type.body)
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                  .layoutWeight(1)
                Text(t.custom ? '删除' : '预设')
                  .fontSize(Theme.type.subhead)
                  .fontColor(t.custom ? Theme.colors().danger : Theme.colors().textTertiary)
                  .padding({ left: 12, right: 12, top: 12, bottom: 12 })
                  .onClick(() => {
                    if (t.custom) {
                      this.pendingDelete = t.id
                    }
                  })
              }
              .width('100%')
              .padding(Theme.space.s4)
              .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
              .borderRadius(Theme.radius.card)
            }, (t: CornerTag) => t.id)
            Blank().height(Theme.space.s10)
          }
          .padding({
            left: Theme.space.pageX,
            right: Theme.space.pageX,
            top: Theme.space.s4,
            bottom: Theme.space.s6
          })
        }
        .layoutWeight(1)
        .scrollBar(BarState.Off)
      }
      .width('100%')
      .height('100%')
      .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)

      if (this.pendingDelete.length > 0) {
        ConfirmSheet({
          title: '删除这个标签？',
          subtitle: '记录不会被删除，只是不再挂这个标签。',
          keepLabel: '取消',
          leaveLabel: '删除标签',
          onKeep: (): void => { this.pendingDelete = '' },
          onLeave: (): void => { void this.doDelete() }
        })
      }

      if (this.toastText.length > 0) {
        Column() {
          Text(this.toastText)
            .fontSize(Theme.type.footnote)
            .fontColor(Theme.colors().brandOnPrimary)
            .padding({ left: 16, right: 16, top: 10, bottom: 10 })
            .backgroundColor(Theme.colors().brandPrimary)
            .borderRadius(Theme.radius.pill)
        }
        .width('100%')
        .padding({ top: 48 })
        .alignItems(HorizontalAlign.Center)
      }
    }
    .width('100%')
    .height('100%')
  }
}
