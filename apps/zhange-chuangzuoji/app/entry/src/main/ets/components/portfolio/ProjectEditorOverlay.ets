import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { AppIcon } from '../design-system/AppIcon'
import { CategoryChips } from './CategoryChips'
import { PortfolioProject } from '../../models/PortfolioModels'
import { PortfolioStore } from '../../services/PortfolioStore'
import { PortfolioMedia } from '../../services/PortfolioMedia'

@Component
export struct ProjectEditorOverlay {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop project: PortfolioProject = new PortfolioProject()
  @Prop isNew: boolean = true
  onClose: () => void = () => {}
  onSaved: () => void = () => {}
  onDeleted: () => void = () => {}
  @State title: string = ''
  @State category: string = 'ui'
  @State description: string = ''
  @State tagsText: string = ''
  @State createdAt: string = ''
  @State coverKey: string = 'hero_studio'
  @State imageKeys: string[] = []
  @State toastText: string = ''
  private coverKeys: string[] = PortfolioMedia.coverKeys()

  aboutToAppear(): void {
    this.title = this.project.title
    this.category = this.project.category.length > 0 ? this.project.category : 'ui'
    this.description = this.project.description
    this.tagsText = this.project.tags.join('、')
    this.createdAt = this.project.createdAt
    this.coverKey = this.project.coverKey.length > 0 ? this.project.coverKey : 'hero_studio'
    this.imageKeys = this.project.imageKeys.length > 0 ? [...this.project.imageKeys] : [this.coverKey]
  }

  private showToast(msg: string): void {
    this.toastText = msg
    setTimeout((): void => { this.toastText = '' }, 2400)
  }

  private parseTags(): string[] {
    const raw = this.tagsText.split('、')
    const tags: string[] = []
    for (const part of raw) {
      const t = part.trim()
      if (t.length > 0) {
        tags.push(t)
      }
    }
    return tags
  }

  private isImageSelected(key: string): boolean {
    return this.imageKeys.indexOf(key) >= 0
  }

  private toggleImageKey(key: string): void {
    const idx = this.imageKeys.indexOf(key)
    if (idx >= 0) {
      if (this.imageKeys.length <= 1) {
        this.showToast('至少保留一张展示图')
        return
      }
      const next: string[] = []
      for (const k of this.imageKeys) {
        if (k !== key) {
          next.push(k)
        }
      }
      this.imageKeys = next
      if (this.coverKey === key) {
        this.coverKey = this.imageKeys[0]
      }
      return
    }
    this.imageKeys = [...this.imageKeys, key]
    this.coverKey = key
  }

  private async save(): Promise<void> {
    const name = this.title.trim()
    if (name.length === 0) {
      this.showToast('请填写作品标题')
      return
    }
    const item = new PortfolioProject()
    item.id = this.isNew ? `p_${Date.now()}` : this.project.id
    item.title = name
    item.category = this.category
    item.description = this.description.trim()
    item.tags = this.parseTags()
    item.createdAt = this.createdAt.trim().length > 0 ? this.createdAt.trim() :
      new Date().toISOString().substring(0, 10)
    item.coverKey = this.coverKey
    item.imageKeys = this.imageKeys.length > 0 ? this.imageKeys : [item.coverKey]
    await PortfolioStore.saveProject(item)
    this.onSaved()
    this.onClose()
  }

  private confirmDelete(): void {
    AlertDialog.show({
      title: '确认删除',
      message: '删除后无法恢复，确定删除该作品吗？',
      primaryButton: {
        value: '删除',
        fontColor: Theme.colors().danger,
        action: (): void => { void this.deleteProject() }
      },
      secondaryButton: {
        value: '取消',
        action: (): void => {}
      }
    })
  }

  private async deleteProject(): Promise<void> {
    await PortfolioStore.deleteProject(this.project.id)
    this.onDeleted()
    this.onClose()
  }

  build() {
    Stack() {
      Column() {
        Row({ space: Theme.space.s3 }) {
          Row() {
            AppIcon({ name: 'close', iconSize: Theme.icon.md, color: Theme.colors().textPrimary })
          }
          .width(40)
          .height(40)
          .justifyContent(FlexAlign.Center)
          .onClick((): void => { this.onClose() })
          Text(this.isNew ? '新建作品' : '编辑作品')
            .fontSize(Theme.type.title3)
            .fontWeight(FontWeight.Bold)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            .layoutWeight(1)
        }
        .width('100%')
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX, top: Theme.space.s4 })

        Scroll() {
          Column({ space: Theme.space.s4 }) {
            TextInput({ text: this.title, placeholder: '作品标题' })
              .height(44)
              .fontSize(Theme.type.body)
              .onChange((v: string) => { this.title = v })

            Text('分类')
              .fontSize(Theme.type.bodyS)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
              .width('100%')
            CategoryChips({
              selectedId: this.category,
              includeAll: false,
              onSelect: (id: string): void => {
                this.category = id
              }
            })

            TextArea({ text: this.description, placeholder: '作品描述…' })
              .height(120)
              .fontSize(Theme.type.bodyS)
              .onChange((v: string) => { this.description = v })

            TextInput({ text: this.tagsText, placeholder: '标签，用顿号分隔' })
              .height(44)
              .fontSize(Theme.type.bodyS)
              .onChange((v: string) => { this.tagsText = v })

            TextInput({ text: this.createdAt, placeholder: '创作日期，如 2026-08-20' })
              .height(44)
              .fontSize(Theme.type.bodyS)
              .onChange((v: string) => { this.createdAt = v })

            Text('展示图（点击切换选中，可多选轮播）')
              .fontSize(Theme.type.bodyS)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
              .width('100%')
            Scroll() {
              Row({ space: Theme.space.s2 }) {
                ForEach(this.coverKeys, (key: string) => {
                  Stack({ alignContent: Alignment.TopEnd }) {
                    Image(PortfolioMedia.coverResource(key))
                      .width(72)
                      .height(48)
                      .borderRadius(Theme.radius.sm)
                      .opacity(this.isImageSelected(key) ? 1 : 0.45)
                    if (this.coverKey === key) {
                      Text('封面')
                        .fontSize(10)
                        .fontColor(Theme.colors().brandOnPrimary)
                        .padding({ left: 4, right: 4, top: 2, bottom: 2 })
                        .backgroundColor(Theme.colors().brandPrimary)
                        .borderRadius(4)
                        .margin(4)
                    }
                  }
                  .border({
                    width: this.isImageSelected(key) ? 2 : 1,
                    color: this.isImageSelected(key) ? Theme.colors().brandPrimary : Theme.colors().strokeHairline
                  })
                  .borderRadius(Theme.radius.sm)
                  .onClick((): void => { this.toggleImageKey(key) })
                }, (key: string) => key)
              }
            }
            .scrollable(ScrollDirection.Horizontal)
            .scrollBar(BarState.Off)
            .width('100%')

            AppButton({
              label: '保存作品',
              variant: 'primary',
              onTap: (): void => { void this.save() }
            })

            if (!this.isNew) {
              AppButton({
                label: '删除作品',
                variant: 'danger',
                onTap: (): void => { this.confirmDelete() }
              })
            }
          }
          .width('100%')
          .padding(Theme.space.pageX)
          .padding({ bottom: Theme.space.s6 })
        }
        .layoutWeight(1)
      }
      .width('100%')
      .height('100%')
      .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)

      if (this.toastText.length > 0) {
        Text(this.toastText)
          .fontSize(Theme.type.bodyS)
          .fontColor(Theme.colors().textOnInverse)
          .padding({ left: 16, right: 16, top: 10, bottom: 10 })
          .backgroundColor(Theme.colors().brandDeep)
          .borderRadius(Theme.radius.pill)
          .position({ x: '10%', y: 56 })
          .zIndex(20)
      }
    }
    .width('100%')
    .height('100%')
  }
}
