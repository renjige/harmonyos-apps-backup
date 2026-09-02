import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { AppCard } from '../design-system/AppCard'
import { RmCategory, RmCheckItem, RmChecklist, RmDateUtil, RmLabels, RmTheme } from '../../models/RmModels'
import { RmStore } from '../../services/RmStore'
import { RmDetailNav } from '../../services/RmDetailNav'
import { RmMedia } from '../../services/RmMedia'
import { RmConfirmDialog } from '../rm/RmConfirmDialog'

@Component
export struct ChecklistDetailPane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop entryId: string = ''
  @Prop @Watch('onRefreshToken') refreshToken: number = 0
  onChanged: () => void = () => {}
  @State entry: RmChecklist = new RmChecklist()
  @State items: RmCheckItem[] = []
  @State catLabel: string = ''
  @State confirmDel: boolean = false
  @State themes: RmTheme[] = []
  @State newItemTitle: string = ''
  @State toastText: string = ''

  aboutToAppear(): void {
    void this.reload()
  }

  onRefreshToken(): void {
    void this.reload()
  }

  private showToast(message: string): void {
    this.toastText = message
    setTimeout((): void => { this.toastText = '' }, 2200)
  }

  private cloneItem(src: RmCheckItem): RmCheckItem {
    const c = new RmCheckItem()
    c.id = src.id
    c.checklistId = src.checklistId
    c.title = src.title
    c.status = src.status
    c.feeling = src.feeling
    c.harvest = src.harvest
    c.note = src.note
    c.starred = src.starred
    c.completedAt = src.completedAt
    c.sortOrder = src.sortOrder
    return c
  }

  private cloneItems(list: RmCheckItem[]): RmCheckItem[] {
    const out: RmCheckItem[] = []
    for (const it of list) {
      out.push(this.cloneItem(it))
    }
    return out
  }

  private cloneChecklist(src: RmChecklist): RmChecklist {
    const e = new RmChecklist()
    e.id = src.id
    e.title = src.title
    e.dateKey = src.dateKey
    e.categoryKey = src.categoryKey
    e.tagCsv = src.tagCsv
    e.status = src.status
    e.templateKey = src.templateKey
    e.fieldA = src.fieldA
    e.fieldB = src.fieldB
    e.fieldC = src.fieldC
    e.body = src.body
    e.themeCsv = src.themeCsv
    e.createdAt = src.createdAt
    e.updatedAt = src.updatedAt
    return e
  }

  private async reload(): Promise<void> {
    const found = await RmStore.findChecklist(this.entryId)
    if (found !== undefined) {
      this.entry = this.cloneChecklist(found)
    }
    this.items = this.cloneItems(await RmStore.itemsForChecklist(this.entryId))
    const cats = await RmStore.loadCategories()
    this.catLabel = RmStore.categoryLabel(this.entry.categoryKey, cats)
    this.themes = await RmStore.loadThemes()
  }

  private doneCount(): number {
    let n = 0
    for (const it of this.items) {
      if (it.status === 'done') {
        n++
      }
    }
    return n
  }

  private async addItem(): Promise<void> {
    const title = this.newItemTitle.trim()
    if (title.length === 0) {
      return
    }
    const item = RmCheckItem.createNew(this.entryId, title)
    await RmStore.saveItem(item)
    this.newItemTitle = ''
    this.onChanged()
    await this.reload()
  }

  private async quickComplete(itemId: string): Promise<void> {
    const found = await RmStore.findItem(itemId)
    if (found === undefined) {
      this.showToast('清单项不存在')
      return
    }
    found.status = 'done'
    found.completedAt = Date.now()
    await RmStore.saveItem(found)
    const next: RmCheckItem[] = []
    for (const it of this.items) {
      if (it.id === itemId) {
        next.push(this.cloneItem(found))
      } else {
        next.push(this.cloneItem(it))
      }
    }
    this.items = next
    this.onChanged()
    this.showToast('已标记完成')
  }

  private async toggleTheme(id: string): Promise<void> {
    this.entry.themeCsv = RmStore.toggleCsv(this.entry.themeCsv, id)
    await RmStore.saveChecklist(this.entry)
    this.onChanged()
    await this.reload()
  }

  private async remove(): Promise<void> {
    await RmStore.deleteChecklist(this.entryId)
    this.confirmDel = false
    this.onChanged()
    RmDetailNav.closeChecklist()
  }

  build() {
    Stack() {
      Scroll() {
        Column({ space: Theme.space.s4 }) {
          Stack({ alignContent: Alignment.BottomStart }) {
            Image(RmMedia.coverOf(this.entry.categoryKey))
              .id(`${this.entry.id}_${this.entry.categoryKey}_${this.entry.updatedAt}`)
              .width('100%')
              .height(180)
              .objectFit(ImageFit.Cover)
            Column()
              .width('100%')
              .height(100)
              .linearGradient({ angle: 180, colors: [['rgba(12,74,110,0)', 0], ['rgba(12,74,110,0.82)', 1]] })
            Text(this.entry.title)
              .fontSize(Theme.type.title2)
              .fontWeight(FontWeight.Bold)
              .fontColor('#F8FAFC')
              .padding({ left: Theme.space.s4, right: Theme.space.s4, bottom: Theme.space.s4 })
          }
          .width('100%')
          .clip(true)
          .borderRadius(Theme.radius.md)

          Text(`${this.catLabel} · ${this.doneCount()}/${this.items.length} 已完成 · ${RmDateUtil.displayDate(this.entry.dateKey)}`)
            .fontSize(Theme.type.footnote)
            .fontColor(Theme.colors().textSecondary)
            .width('100%')

          if (this.entry.body.length > 0) {
            AppCard({ title: '清单描述' }) {
              Text(this.entry.body)
                .fontSize(Theme.type.body)
                .fontColor(Theme.colors().textPrimary)
                .width('100%')
            }
          }

          AppCard({ title: '清单项' }) {
            Column({ space: Theme.space.s3 }) {
              ForEach(this.items, (it: RmCheckItem) => {
                Row({ space: Theme.space.s3 }) {
                  Row({ space: Theme.space.s3 }) {
                    Column()
                      .width(8)
                      .height(8)
                      .borderRadius(4)
                      .backgroundColor(it.status === 'done' ? Theme.colors().brandAccent : Theme.colors().textTertiary)
                    Column({ space: 2 }) {
                      Text(it.title)
                        .fontSize(Theme.type.body)
                        .fontColor(Theme.colors().textPrimary)
                        .decoration({ type: it.status === 'done' ? TextDecorationType.LineThrough : TextDecorationType.None })
                      Text(RmLabels.itemStatusLabel(it.status))
                        .fontSize(Theme.type.caption)
                        .fontColor(it.status === 'done' ? Theme.colors().brandPrimary : Theme.colors().textSecondary)
                    }
                    .alignItems(HorizontalAlign.Start)
                  }
                  .layoutWeight(1)
                  .onClick((): void => { RmDetailNav.openItem(it.id) })

                  if (it.status !== 'done') {
                    Row({ space: Theme.space.s2 }) {
                      Text('完成')
                        .fontSize(Theme.type.caption)
                        .fontWeight(FontWeight.Medium)
                        .fontColor(Theme.colors().brandOnPrimary)
                        .padding({ left: 10, right: 10, top: 5, bottom: 5 })
                        .backgroundColor(Theme.colors().brandPrimary)
                        .borderRadius(Theme.radius.pill)
                        .onClick((): void => { void this.quickComplete(it.id) })
                      Text('体验')
                        .fontSize(Theme.type.caption)
                        .fontColor(Theme.colors().brandPrimary)
                        .padding({ left: 8, right: 8, top: 5, bottom: 5 })
                        .onClick((): void => { RmDetailNav.openItem(it.id) })
                    }
                  } else {
                    Text('查看记录')
                      .fontSize(Theme.type.caption)
                      .fontColor(Theme.colors().brandPrimary)
                      .padding({ left: 8, right: 8, top: 5, bottom: 5 })
                      .onClick((): void => { RmDetailNav.openItem(it.id) })
                  }
                }
                .width('100%')
                .alignItems(VerticalAlign.Center)
              }, (it: RmCheckItem) => `${it.id}_${it.status}`)

              Row({ space: Theme.space.s2 }) {
                TextInput({ text: this.newItemTitle, placeholder: '添加清单项…' })
                  .layoutWeight(1)
                  .onChange((v: string) => { this.newItemTitle = v })
                Text('添加')
                  .fontSize(Theme.type.subtitleS)
                  .fontColor(Theme.colors().brandPrimary)
                  .onClick((): void => { void this.addItem() })
              }
              .width('100%')
            }
          }

          if (this.entry.fieldA.length > 0) {
            AppCard({ title: '清单总结' }) {
              Text(this.entry.fieldA)
                .fontSize(Theme.type.body)
                .fontColor(Theme.colors().textPrimary)
                .width('100%')
            }
          }

          if (this.themes.length > 0) {
            Text('关联主题')
              .fontSize(Theme.type.subtitleS)
              .fontColor(Theme.colors().textPrimary)
              .width('100%')
            Flex({ wrap: FlexWrap.Wrap }) {
              ForEach(this.themes, (t: RmTheme) => {
                Text(t.title)
                  .fontSize(Theme.type.caption)
                  .fontColor(RmStore.csvHas(this.entry.themeCsv, t.id) ? Theme.colors().brandOnPrimary : Theme.colors().brandPrimary)
                  .padding({ left: 10, right: 10, top: 6, bottom: 6 })
                  .margin({ right: 8, bottom: 8 })
                  .backgroundColor(RmStore.csvHas(this.entry.themeCsv, t.id) ? Theme.colors().brandPrimary : Theme.colors().brandPrimaryContainer)
                  .borderRadius(Theme.radius.pill)
                  .onClick((): void => { void this.toggleTheme(t.id) })
              }, (t: RmTheme) => t.id)
            }
          }

          AppButton({ label: '编辑清单', onTap: (): void => { RmDetailNav.openChecklistEditor(this.entry.id, this.entry.templateKey) } })
          AppButton({ label: '删除清单', variant: 'danger', onTap: (): void => { this.confirmDel = true } })
          Column().height(Theme.space.s10)
        }
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s6 })
      }
      .width('100%')
      .height('100%')
      .align(Alignment.Top)

      if (this.confirmDel) {
        RmConfirmDialog({
          title: '删除这份清单？',
          message: '清单项与体验记录将一并删除。',
          confirmLabel: '删除',
          onConfirm: (): void => { void this.remove() },
          onCancel: (): void => { this.confirmDel = false }
        })
      }

      if (this.toastText.length > 0) {
        Text(this.toastText)
          .fontSize(Theme.type.footnote)
          .fontColor('#F8FAFC')
          .padding({ left: 16, right: 16, top: 10, bottom: 10 })
          .backgroundColor('rgba(12,74,110,0.92)')
          .borderRadius(Theme.radius.pill)
          .position({ x: '50%', y: 56 })
          .translate({ x: '-50%' })
          .zIndex(30)
      }
    }
    .width('100%')
    .height('100%')
  }
}
