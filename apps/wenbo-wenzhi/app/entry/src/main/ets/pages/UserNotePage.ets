import { Theme } from '../components/design-system/Theme'
import { AppNavBar } from '../components/design-system/AppNavBar'
import { AppButton } from '../components/design-system/AppButton'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { UserNote } from '../models/GrowthModels'
import { AskNav } from '../services/AskNav'
import { GrowthStore } from '../services/GrowthStore'

@Component
export struct UserNotePage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @StorageLink('vaultRefresh') @Watch('onRefresh') vaultRefresh: number = 0
  @State items: UserNote[] = []
  @State editing: boolean = false
  @State editId: string = ''
  @State titleDraft: string = ''
  @State bodyDraft: string = ''
  @State category: string = '学习知识'
  @State userTag: string = '待了解'
  @State toastText: string = ''

  aboutToAppear(): void {
    this.reload()
  }

  onRefresh(): void {
    this.reload()
  }

  private reload(): void {
    this.items = GrowthStore.noteAll()
  }

  private showToast(msg: string): void {
    this.toastText = msg
    setTimeout(() => { this.toastText = '' }, 2200)
  }

  private openNew(): void {
    this.editing = true
    this.editId = ''
    this.titleDraft = ''
    this.bodyDraft = ''
    this.category = '学习知识'
    this.userTag = '待了解'
  }

  private openEdit(n: UserNote): void {
    this.editing = true
    this.editId = n.id
    this.titleDraft = n.title
    this.bodyDraft = n.body
    this.category = n.category
    this.userTag = n.userTag
  }

  private async saveNote(): Promise<void> {
    const t = this.titleDraft.trim()
    const b = this.bodyDraft.trim()
    if (t.length === 0 || b.length === 0) {
      this.showToast('请填写标题与正文')
      return
    }
    await GrowthStore.saveNote(t, b, this.category, this.userTag, this.editId)
    this.editing = false
    this.reload()
    AskNav.bumpRefresh()
    this.showToast('笔记已保存')
  }

  build() {
    Stack({ alignContent: Alignment.Top }) {
      Column() {
        AppNavBar({
          title: this.editing ? '编辑笔记' : '我的笔记',
          onBack: (): void => {
            if (this.editing) {
              this.editing = false
            } else {
              AskNav.closeLearn()
            }
          }
        })
        if (this.editing) {
          Scroll() {
            Column({ space: Theme.space.s3 }) {
              TextInput({ text: this.titleDraft, placeholder: '笔记标题' })
                .height(48)
                .fontSize(Theme.type.body)
                .onChange((v: string) => { this.titleDraft = v })
              TextArea({ text: this.bodyDraft, placeholder: '写下你的理解、心得或补充知识' })
                .height(160)
                .fontSize(Theme.type.body)
                .onChange((v: string) => { this.bodyDraft = v })
              AppButton({ label: '保存笔记', onTap: (): void => { void this.saveNote() } })
            }
            .padding({
              left: Theme.space.pageX,
              right: Theme.space.pageX,
              bottom: Theme.space.s10
            })
            .width('100%')
          }
          .layoutWeight(1)
        } else if (this.items.length === 0) {
          Column() {
            AppEmpty({
              title: '还没有个人笔记',
              description: '把学到的内容用自己的话记下来，形成专属知识',
              actionLabel: '写第一篇',
              onAction: (): void => { this.openNew() }
            })
            AppButton({ label: '新建笔记', onTap: (): void => { this.openNew() } })
              .margin({ top: Theme.space.s4 })
          }
          .layoutWeight(1)
          .padding(Theme.space.pageX)
        } else {
          Scroll() {
            Column({ space: Theme.space.s3 }) {
              AppButton({ label: '新建笔记', onTap: (): void => { this.openNew() } })
              ForEach(this.items, (n: UserNote) => {
                Column({ space: 6 }) {
                  Text(n.title)
                    .fontSize(Theme.type.subhead)
                    .fontWeight(FontWeight.Medium)
                    .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                    .width('100%')
                  Text(n.body)
                    .fontSize(Theme.type.body)
                    .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                    .width('100%')
                    .maxLines(3)
                    .textOverflow({ overflow: TextOverflow.Ellipsis })
                  Text(`${n.category} · ${n.userTag}`)
                    .fontSize(Theme.type.caption)
                    .fontColor(this.themeEpoch >= 0 ? Theme.colors().textTertiary : Theme.colors().textTertiary)
                }
                .width('100%')
                .padding(Theme.space.s4)
                .alignItems(HorizontalAlign.Start)
                .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
                .borderRadius(Theme.radius.card)
                .onClick(() => { this.openEdit(n) })
              }, (n: UserNote) => n.id)
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
        }
      }
      .width('100%')
      .height('100%')
      .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)

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
        .padding({ top: Theme.space.s8 })
        .alignItems(HorizontalAlign.Center)
        .zIndex(20)
      }
    }
    .width('100%')
    .height('100%')
  }
}
