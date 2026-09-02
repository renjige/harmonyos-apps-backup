import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { AppEmpty } from '../design-system/AppEmpty'
import { BreakdownItem } from '../../models/ThinkModels'
import { ThinkStore } from '../../services/ThinkStore'
import { DateHelper } from '../../services/DateHelper'

@Component
export struct BreakdownPane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop @Watch('onPaneReload') paneToken: number = 0
  @State items: BreakdownItem[] = []
  @State editing: BreakdownItem = new BreakdownItem()
  @State showEdit: boolean = false
  @State confirmDelete: boolean = false
  @State toastText: string = ''

  aboutToAppear(): void {
    void this.reload()
  }

  onPaneReload(): void {
    this.showEdit = false
    this.confirmDelete = false
    void this.reload()
  }

  private async reload(): Promise<void> {
    this.items = await ThinkStore.loadBreaks()
  }

  private openNew(): void {
    const it = new BreakdownItem()
    it.id = ThinkStore.newId('bk')
    it.createdAt = Date.now()
    it.updatedAt = it.createdAt
    this.editing = it
    this.confirmDelete = false
    this.showEdit = true
  }

  private async save(): Promise<void> {
    if (this.editing.question.trim().length === 0) {
      this.toastText = '先写下要拆解的问题'
      setTimeout((): void => { this.toastText = '' }, 2200)
      return
    }
    await ThinkStore.saveBreak(this.editing)
    this.showEdit = false
    await this.reload()
  }

  private async remove(): Promise<void> {
    if (!this.confirmDelete) {
      this.confirmDelete = true
      return
    }
    await ThinkStore.removeBreak(this.editing.id)
    this.showEdit = false
    await this.reload()
  }

  build() {
    Column() {
      Row() {
        Text('问题拆解')
          .fontSize(Theme.type.title3)
          .fontWeight(FontWeight.Bold)
          .fontColor(Theme.colors().textPrimary)
        Blank()
        Text('新建')
          .fontColor(Theme.colors().brandPrimary)
          .onClick((): void => { this.openNew() })
      }
      .width('100%')
      if (this.showEdit) {
        Scroll() {
          Column({ space: Theme.space.s3 }) {
            Text('把一个问题拆成：当前状况 → 原因 → 可执行方案')
              .fontSize(Theme.type.caption)
              .fontColor(Theme.colors().textSecondary)
              .width('100%')
            TextInput({ text: this.editing.question, placeholder: '问题，例如：如何提升学习效率' })
              .height(44)
              .onChange((v: string) => { this.editing.question = v })
            TextArea({ text: this.editing.current, placeholder: '当前问题 / 现状' })
              .height(88)
              .onChange((v: string) => { this.editing.current = v })
            TextArea({ text: this.editing.causes, placeholder: '原因分析' })
              .height(88)
              .onChange((v: string) => { this.editing.causes = v })
            TextArea({ text: this.editing.solutions, placeholder: '解决方案（可分步骤）' })
              .height(88)
              .onChange((v: string) => { this.editing.solutions = v })
            AppButton({ label: '保存拆解', onTap: (): void => { void this.save() } })
            AppButton({ label: '返回列表', variant: 'secondary', onTap: (): void => { this.showEdit = false } })
            AppButton({
              label: this.confirmDelete ? '再点一次删除' : '删除',
              variant: 'danger',
              onTap: (): void => { void this.remove() }
            })
          }
          .padding({ bottom: Theme.space.s10 })
        }
        .layoutWeight(1)
        .scrollBar(BarState.On)
      } else {
        Scroll() {
          Column({ space: Theme.space.s3 }) {
            if (this.items.length === 0) {
              AppEmpty({ title: '还没有拆解记录', description: '输入一个问题，写下现状、原因和方案' })
            } else {
              ForEach(this.items, (it: BreakdownItem) => {
                Column({ space: 6 }) {
                  Text(it.question)
                    .fontSize(Theme.type.subhead)
                    .fontWeight(FontWeight.Medium)
                    .fontColor(Theme.colors().textPrimary)
                    .width('100%')
                  Text(it.solutions.length > 0 ? it.solutions : '方案待写')
                    .fontSize(Theme.type.caption)
                    .fontColor(Theme.colors().textSecondary)
                    .maxLines(2)
                    .width('100%')
                  Text(DateHelper.formatShort(it.updatedAt))
                    .fontSize(Theme.type.caption)
                    .fontColor(Theme.colors().textSecondary)
                    .width('100%')
                }
                .width('100%')
                .padding(Theme.space.s4)
                .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
                .borderRadius(Theme.radius.md)
                .onClick((): void => {
                  this.editing = ThinkStore.cloneBreak(it)
                  this.confirmDelete = false
                  this.showEdit = true
                })
              }, (it: BreakdownItem) => `${it.id}|${it.updatedAt}`)
            }
          }
          .padding({ bottom: Theme.space.s10 })
        }
        .layoutWeight(1)
        .scrollBar(BarState.On)
        .edgeEffect(EdgeEffect.Spring)
      }
      if (this.toastText.length > 0) {
        Text(this.toastText)
          .fontSize(Theme.type.footnote)
          .fontColor(Theme.colors().textOnInverse)
          .padding(12)
          .backgroundColor(Theme.colors().brandDeep)
          .borderRadius(Theme.radius.md)
      }
    }
    .width('100%')
    .height('100%')
  }
}
