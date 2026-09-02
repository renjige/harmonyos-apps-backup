import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { YdTag } from '../../models/YdModels'
import { YdLocalStore } from '../../services/YdLocalStore'
import { YdDetailNav } from '../../services/YdDetailNav'
import { DetailShell } from '../detail/DetailShell'

@Component
export struct TagsManageSheet {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @State tags: YdTag[] = []
  @State label: string = ''
  @State colorKey: string = 'blue'
  @State toast: string = ''

  aboutToAppear(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    this.tags = await YdLocalStore.loadTags()
  }

  private showToast(msg: string): void {
    this.toast = msg
    setTimeout((): void => { this.toast = '' }, 2200)
  }

  build() {
    DetailShell({
      title: '标签管理',
      onClose: (): void => { YdDetailNav.closeTagsManage() },
      body: (): void => { this.Body() }
    })
  }

  @Builder
  Body() {
    Stack() {
      Scroll() {
        Column({ space: Theme.space.s4 }) {
          Text('为任务、目标、篇章打标签，便于搜索与筛选。')
            .fontSize(Theme.type.bodyS)
            .fontColor(Theme.colors().textSecondary)
          TextInput({ text: this.label, placeholder: '新标签名（1～8 字）' })
            .onChange((v: string): void => { this.label = v })
          Row({ space: Theme.space.s2 }) {
            this.ColorChip('蓝', 'blue')
            this.ColorChip('绿', 'green')
            this.ColorChip('紫', 'purple')
            this.ColorChip('橙', 'orange')
          }
          AppButton({
            label: '添加标签',
            variant: 'secondary',
            onTap: (): void => { void this.addTag() }
          })
          if (this.tags.length === 0) {
            Text('还没有标签，先创建一个吧')
              .fontSize(Theme.type.bodyS)
              .fontColor(Theme.colors().textTertiary)
          } else {
            ForEach(this.tags, (t: YdTag) => {
              Row({ space: Theme.space.s3 }) {
                Text(t.label)
                  .fontSize(Theme.type.body)
                  .fontColor(t.colorHex())
                  .layoutWeight(1)
                Text('删除')
                  .fontSize(Theme.type.bodyS)
                  .fontColor(Theme.colors().danger)
                  .onClick((): void => { void this.removeTag(t.id) })
              }
              .width('100%')
              .padding(Theme.space.s3)
              .backgroundColor(Theme.colors().surfaceCard)
              .borderRadius(Theme.radius.md)
            }, (t: YdTag) => t.id)
          }
        }
        .width('100%')
        .padding(Theme.space.pageX)
        .padding({ bottom: Theme.space.s10 })
      }

      if (this.toast.length > 0) {
        Text(this.toast)
          .fontSize(Theme.type.bodyS)
          .fontColor(Theme.colors().textOnInverse)
          .padding({ left: 16, right: 16, top: 10, bottom: 10 })
          .backgroundColor(Theme.colors().brandDeep)
          .borderRadius(Theme.radius.pill)
          .position({ x: '8%', y: 48 })
          .zIndex(20)
      }
    }
  }

  @Builder
  ColorChip(label: string, key: string) {
    Text(label)
      .fontSize(Theme.type.caption)
      .fontColor(this.colorKey === key ? Theme.colors().brandOnPrimary : Theme.colors().textSecondary)
      .padding({ left: 12, right: 12, top: 6, bottom: 6 })
      .backgroundColor(this.colorKey === key ? Theme.colors().brandPrimary : Theme.colors().surfaceSubtle)
      .borderRadius(Theme.radius.pill)
      .onClick((): void => { this.colorKey = key })
  }

  private async addTag(): Promise<void> {
    const err = await YdLocalStore.createTag(this.label, this.colorKey)
    if (err.length > 0) {
      this.showToast(err)
      return
    }
    this.label = ''
    await this.reload()
    this.showToast('标签已添加')
  }

  private async removeTag(id: string): Promise<void> {
    await YdLocalStore.deleteTag(id)
    await this.reload()
    this.showToast('已删除标签')
  }
}
