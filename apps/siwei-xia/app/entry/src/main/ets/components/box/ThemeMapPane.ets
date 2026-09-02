import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { AppEmpty } from '../design-system/AppEmpty'
import { ThemeMapItem } from '../../models/ThinkModels'
import { ThinkStore } from '../../services/ThinkStore'

@Component
export struct ThemeMapPane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop @Watch('onPaneReload') reloadToken: number = 0
  @State maps: ThemeMapItem[] = []
  @State editing: ThemeMapItem = new ThemeMapItem()
  @State branchView: string[] = []
  @State showEdit: boolean = false
  @State branchDraft: string = ''
  @State toastText: string = ''
  @State confirmDelete: boolean = false

  aboutToAppear(): void {
    void this.reload()
  }

  onPaneReload(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    this.maps = await ThinkStore.loadMaps()
  }

  private showToast(msg: string): void {
    this.toastText = msg
    setTimeout((): void => { this.toastText = '' }, 2200)
  }

  private openNew(): void {
    const it = new ThemeMapItem()
    it.id = ThinkStore.newId('mp')
    it.createdAt = Date.now()
    it.updatedAt = it.createdAt
    this.editing = it
    this.branchView = []
    this.branchDraft = ''
    this.confirmDelete = false
    this.showEdit = true
  }

  private openEdit(it: ThemeMapItem): void {
    this.editing = it
    this.branchView = it.branches()
    this.branchDraft = ''
    this.confirmDelete = false
    this.showEdit = true
  }

  private async save(): Promise<void> {
    if (this.editing.center.trim().length === 0) {
      this.showToast('先写中心主题')
      return
    }
    this.editing.branchesCsv = this.branchView.join(';;')
    if (this.editing.title.trim().length === 0) {
      this.editing.title = this.editing.center
    }
    await ThinkStore.saveMap(this.editing)
    this.showEdit = false
    await this.reload()
    this.showToast('主题图已保存')
  }

  private addBranch(): void {
    const t = this.branchDraft.trim()
    if (t.length === 0) {
      return
    }
    const now: string[] = []
    for (const b of this.branchView) {
      now.push(b)
    }
    now.push(t)
    this.branchView = now
    this.editing.branchesCsv = now.join(';;')
    this.branchDraft = ''
  }

  private dropBranch(name: string): void {
    const next: string[] = []
    for (const b of this.branchView) {
      if (b !== name) {
        next.push(b)
      }
    }
    this.branchView = next
    this.editing.branchesCsv = next.join(';;')
  }

  private async remove(): Promise<void> {
    if (!this.confirmDelete) {
      this.confirmDelete = true
      return
    }
    await ThinkStore.removeMap(this.editing.id)
    this.showEdit = false
    await this.reload()
  }

  build() {
    Stack() {
      if (this.showEdit) {
        this.Editor()
      } else {
        Scroll() {
          Column({ space: Theme.space.s3 }) {
            Text('从中心主题长出分支，整理一层思考关系。')
              .fontSize(Theme.type.caption)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
              .width('100%')
            AppButton({ label: '新建主题图', onTap: (): void => { this.openNew() } })
            if (this.maps.length === 0) {
              AppEmpty({ title: '还没有主题图', description: '写一个中心主题，再添加分支' })
            } else {
              ForEach(this.maps, (m: ThemeMapItem) => {
                Column({ space: 6 }) {
                  Text(m.center.length > 0 ? m.center : m.title)
                    .fontSize(Theme.type.subhead)
                    .fontWeight(FontWeight.Medium)
                    .fontColor(Theme.colors().textPrimary)
                    .width('100%')
                  Text(`分支 ${m.branches().length} 条`)
                    .fontSize(Theme.type.caption)
                    .fontColor(Theme.colors().textSecondary)
                    .width('100%')
                }
                .width('100%')
                .padding(Theme.space.s4)
                .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
                .borderRadius(Theme.radius.md)
                .onClick((): void => { this.openEdit(m) })
              }, (m: ThemeMapItem) => `${m.id}|${m.updatedAt}`)
            }
          }
          .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s10, top: Theme.space.s2 })
        }
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
          .margin({ top: 48 })
      }
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  Editor() {
    Column({ space: Theme.space.s3 }) {
      Row() {
        Text('返回')
          .fontColor(Theme.colors().brandPrimary)
          .onClick((): void => { this.showEdit = false })
        Blank()
        Text('主题分支')
          .fontSize(Theme.type.subhead)
          .fontWeight(FontWeight.Medium)
          .fontColor(Theme.colors().textPrimary)
        Blank()
      }
      .width('100%')
      Scroll() {
        Column({ space: Theme.space.s3 }) {
          TextInput({ text: this.editing.center, placeholder: '中心主题，例如：提升学习效率' })
            .height(44)
            .onChange((v: string) => { this.editing.center = v })
          Text('分支内容')
            .fontSize(Theme.type.caption)
            .fontColor(Theme.colors().textSecondary)
            .width('100%')
          ForEach(this.branchView, (b: string) => {
            Row() {
              Text(b)
                .fontSize(Theme.type.body)
                .fontColor(Theme.colors().textPrimary)
                .layoutWeight(1)
              Text('移除')
                .fontSize(Theme.type.caption)
                .fontColor(Theme.colors().danger)
                .onClick((): void => { this.dropBranch(b) })
            }
            .width('100%')
            .padding(12)
            .backgroundColor(Theme.colors().surfaceSubtle)
            .borderRadius(Theme.radius.md)
          }, (b: string) => b)
          TextInput({ text: this.branchDraft, placeholder: '新增一条分支' })
            .height(44)
            .onChange((v: string) => { this.branchDraft = v })
          AppButton({ label: '添加分支', variant: 'secondary', onTap: (): void => { this.addBranch() } })
          AppButton({ label: '保存主题图', onTap: (): void => { void this.save() } })
          AppButton({
            label: this.confirmDelete ? '再点一次删除' : '删除此图',
            variant: 'danger',
            onTap: (): void => { void this.remove() }
          })
        }
        .padding({ bottom: Theme.space.s10 })
      }
      .layoutWeight(1)
      .scrollBar(BarState.On)
    }
    .width('100%')
    .height('100%')
    .padding(Theme.space.pageX)
  }
}
