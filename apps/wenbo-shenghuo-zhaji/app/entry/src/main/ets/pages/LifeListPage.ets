import { Theme } from '../components/design-system/Theme'
import { AppButton } from '../components/design-system/AppButton'
import { AppCard } from '../components/design-system/AppCard'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { AppIcon } from '../components/design-system/AppIcon'
import { CreateDiaryRequest, JournalItem, UpdateDiaryRequest } from '../models/JournalModels'
import { JournalBizService } from '../services/JournalBizService'
import { LifeListCodec, LifeListLine } from '../services/LifeListCodec'
import { AuthService } from '../services/AuthService'

/** 生活清单：创建、勾选完成、即时刷新 */
@Component
export struct LifeListPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  onClose: () => void = () => {}
  onRequireAuth: () => void = () => {}
  @State lists: JournalItem[] = []
  @State listRevision: number = 0
  @State newTitle: string = ''
  @State newItems: string = ''
  @State toastText: string = ''
  @StorageLink('currentUsername') currentUsername: string = ''

  aboutToAppear(): void {
    void this.reload()
  }

  private showToast(msg: string): void {
    this.toastText = msg
    setTimeout(() => { this.toastText = '' }, 2200)
  }

  private async reload(): Promise<void> {
    if (!AuthService.isLoggedIn()) {
      this.lists = []
      return
    }
    this.lists = await JournalBizService.loadByKind(this.currentUsername, 'list')
  }

  private async addList(): Promise<void> {
    if (!AuthService.requireAuth('create_diary')) {
      this.onRequireAuth()
      return
    }
    if (this.newTitle.trim().length === 0) {
      this.showToast('请填写清单名称')
      return
    }
    const lines = LifeListCodec.fromPlain(this.newItems)
    if (lines.length === 0) {
      this.showToast('请至少写一项，每行一件事')
      return
    }
    const req = new CreateDiaryRequest()
    req.title = this.newTitle.trim()
    req.body = LifeListCodec.encode(lines)
    req.summary = `${lines.length} 项`
    req.kind = 'list'
    req.userId = this.currentUsername
    req.tags = ['生活清单']
    const created = await JournalBizService.createDiary(req)
    if (created !== undefined) {
      this.newTitle = ''
      this.newItems = ''
      this.showToast('清单已创建')
      await this.reload()
    } else {
      this.showToast('创建失败')
    }
  }

  private async toggleLine(list: JournalItem, index: number): Promise<void> {
    const lines = LifeListCodec.decode(list.body)
    if (index < 0 || index >= lines.length) {
      return
    }
    lines[index].done = !lines[index].done
    this.applyListLocal(list.id, LifeListCodec.encode(lines))
    const req = new UpdateDiaryRequest()
    req.title = list.title
    req.body = LifeListCodec.encode(lines)
    req.summary = list.summary
    req.kind = 'list'
    req.userId = this.currentUsername
    req.recordDate = list.recordDate
    const updated = await JournalBizService.updateDiary(list.id, req)
    if (updated !== undefined) {
      this.applyListLocal(list.id, updated.body)
    } else {
      await this.reload()
      this.showToast('更新失败')
    }
  }

  private applyListLocal(listId: string, body: string): void {
    const next: JournalItem[] = []
    for (let i = 0; i < this.lists.length; i++) {
      const src = this.lists[i]
      if (src.id === listId) {
        const copy = new JournalItem()
        copy.id = src.id
        copy.title = src.title
        copy.summary = src.summary
        copy.body = body
        copy.kind = src.kind
        copy.recordDate = src.recordDate
        copy.userId = src.userId
        copy.tags = src.tags
        next.push(copy)
      } else {
        next.push(src)
      }
    }
    this.lists = next
    this.listRevision += 1
  }

  build() {
    Stack() {
      Column() {
        Row({ space: Theme.space.s2 }) {
          Column() {
            AppIcon({ name: 'close', iconSize: Theme.icon.md })
          }
          .width(44)
          .height(44)
          .justifyContent(FlexAlign.Center)
          .onClick((): void => { this.onClose() })
          Text('生活清单')
            .fontSize(Theme.type.title3)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            .layoutWeight(1)
        }
        .width('100%')
        .padding({ left: Theme.space.pageX - 8, right: Theme.space.pageX, top: Theme.space.s2 })

        Scroll() {
          Column({ space: Theme.space.s4 }) {
            TextInput({ text: this.newTitle, placeholder: '清单名称，如旅行准备 / 购物' })
              .width('100%')
              .height(44)
              .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
              .borderRadius(Theme.radius.sm)
              .onChange((v: string) => { this.newTitle = v })
            TextArea({ text: this.newItems, placeholder: '每行一项，例如：\n护照\n充电器\n防晒霜' })
              .width('100%')
              .height(100)
              .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
              .borderRadius(Theme.radius.sm)
              .onChange((v: string) => { this.newItems = v })
            AppButton({
              label: '创建清单',
              onTap: (): void => { void this.addList() }
            })

            if (this.lists.length === 0) {
              AppEmpty({
                title: '还没有清单',
                description: '把计划事项写下来，完成后点选勾掉'
              })
            } else {
              ForEach(this.lists, (list: JournalItem) => {
                AppCard({ title: list.title }) {
                  Column({ space: Theme.space.s2 }) {
                    ForEach(LifeListCodec.decode(list.body), (line: LifeListLine, idx: number) => {
                      Row({ space: Theme.space.s2 }) {
                        Text(line.done ? '已完成' : '待办')
                          .fontSize(Theme.type.caption)
                          .fontColor(line.done ?
                            Theme.colors().success : Theme.colors().textSecondary)
                        Text(line.text)
                          .fontSize(Theme.type.callout)
                          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                          .decoration({ type: line.done ? TextDecorationType.LineThrough : TextDecorationType.None })
                          .layoutWeight(1)
                      }
                      .width('100%')
                      .padding({ top: 6, bottom: 6 })
                      .onClick((): void => { void this.toggleLine(list, idx) })
                    }, (line: LifeListLine, idx: number) => `${list.id}_${idx}_${line.done}_${this.listRevision}`)
                  }
                  .width('100%')
                }
              }, (list: JournalItem) => list.id)
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
      }
      .width('100%')
      .height('100%')

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
        .padding({ top: Theme.space.s6 })
        .alignItems(HorizontalAlign.Center)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }
}
