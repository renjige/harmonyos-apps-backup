import { Theme } from '../components/design-system/Theme'
import { AppButton } from '../components/design-system/AppButton'
import { AppIcon } from '../components/design-system/AppIcon'
import { SavedActionItem } from '../models/VitalityModels'
import { ActionLibraryService } from '../services/ActionLibraryService'
import { VitalityStore } from '../services/VitalityStore'
import { DateHelper } from '../services/DateHelper'

@Component
export struct ActionHubPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop @Watch('onRefreshTokenChange') refreshToken: number = 0
  @Prop bottomInset: number = 76
  onChanged: () => void = () => {}
  @State category: string = 'all'
  @State builtin: SavedActionItem[] = []
  @State userActions: SavedActionItem[] = []
  @State showAdd: boolean = false
  @State editingUser: SavedActionItem | undefined = undefined
  @State newTitle: string = ''
  @State newHint: string = ''
  @State toastText: string = ''

  aboutToAppear(): void {
    void this.reload()
  }

  onRefreshTokenChange(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    this.builtin = ActionLibraryService.builtinCatalog()
    this.userActions = await VitalityStore.loadSavedActions()
  }

  private filtered(): SavedActionItem[] {
    const all: SavedActionItem[] = []
    for (const b of this.builtin) {
      all.push(b)
    }
    for (const u of this.userActions) {
      all.push(u)
    }
    if (this.category === 'all') {
      return all
    }
    const out: SavedActionItem[] = []
    for (const a of all) {
      if (a.category === this.category) {
        out.push(a)
      }
    }
    return out
  }

  private showToast(msg: string): void {
    this.toastText = msg
    setTimeout((): void => { this.toastText = '' }, 2400)
  }

  private async addToToday(item: SavedActionItem): Promise<void> {
    const rec = await VitalityStore.recordForDate(DateHelper.todayKey())
    if (rec === undefined || !rec.isComplete()) {
      this.showToast('请先完成今日活力记录')
      return
    }
    const ok = await ActionLibraryService.addToToday(item)
    this.showToast(ok ? '已加入今日处方' : '今日已有相同行动')
    if (ok) {
      this.onChanged()
    }
  }

  private async saveUserAction(): Promise<void> {
    if (this.newTitle.trim().length === 0) {
      this.showToast('请填写行动名称')
      return
    }
    const a = this.editingUser !== undefined ? this.editingUser : new SavedActionItem()
    if (a.id.length === 0) {
      a.id = `u-${Date.now()}`
      a.category = 'focus'
      a.source = 'user'
      a.usageCount = 0
    }
    a.title = this.newTitle.trim()
    a.hint = this.newHint.trim().length > 0 ? this.newHint.trim() : '我的常做行动'
    await VitalityStore.saveUserAction(a)
    this.newTitle = ''
    this.newHint = ''
    this.editingUser = undefined
    this.showAdd = false
    AppStorage.setOrCreate('tabBarHidden', false)
    this.showToast('已保存到我的行动')
    await this.reload()
  }

  private async deleteUserAction(id: string): Promise<void> {
    await VitalityStore.deleteUserAction(id)
    this.showToast('已删除自定义行动')
    this.onChanged()
    await this.reload()
  }

  build() {
    Stack({ alignContent: Alignment.Top }) {
      Scroll() {
        Column({ space: Theme.space.s4 }) {
          Text('活力行动库')
            .fontSize(Theme.type.title2)
            .fontWeight(FontWeight.Bold)
            .fontColor(Theme.colors().textPrimary)
            .width('100%')

          Text('精选与自定义微行动，一键加入今日处方')
            .fontSize(Theme.type.bodyS)
            .fontColor(Theme.colors().textSecondary)
            .width('100%')

          Row({ space: Theme.space.s2 }) {
            this.CatChip('全部', 'all')
            this.CatChip('恢复', 'restore')
            this.CatChip('运动', 'move')
            this.CatChip('心绪', 'mind')
            this.CatChip('专注', 'focus')
          }
          .width('100%')

          AppButton({
            label: '新建我的行动',
            variant: 'secondary',
            onTap: (): void => {
              this.showAdd = true
              AppStorage.setOrCreate('tabBarHidden', true)
            }
          })

          ForEach(this.filtered(), (a: SavedActionItem) => {
            Column({ space: Theme.space.s2 }) {
              Row() {
                Text(a.title)
                  .fontSize(Theme.type.body)
                  .fontWeight(FontWeight.Medium)
                  .fontColor(Theme.colors().textPrimary)
                  .layoutWeight(1)
                Text(ActionLibraryService.categoryLabel(a.category))
                  .fontSize(Theme.type.caption)
                  .fontColor(Theme.colors().brandPrimary)
                  .padding({ left: 8, right: 8, top: 4, bottom: 4 })
                  .backgroundColor(Theme.colors().brandPrimaryContainer)
                  .borderRadius(Theme.radius.pill)
              }
              .width('100%')
              Text(a.hint)
                .fontSize(Theme.type.caption)
                .fontColor(Theme.colors().textSecondary)
                .width('100%')
              if (a.source === 'user') {
                Text(`已使用 ${a.usageCount} 次`)
                  .fontSize(Theme.type.caption)
                  .fontColor(Theme.colors().textTertiary)
                  .width('100%')
                Row({ space: Theme.space.s2 }) {
                  Column() {
                    AppButton({
                      label: '编辑',
                      variant: 'secondary',
                      onTap: (): void => {
                        this.editingUser = a
                        this.newTitle = a.title
                        this.newHint = a.hint
                        this.showAdd = true
                        AppStorage.setOrCreate('tabBarHidden', true)
                      }
                    })
                  }
                  .layoutWeight(1)
                  Column() {
                    AppButton({
                      label: '删除',
                      variant: 'secondary',
                      onTap: (): void => { void this.deleteUserAction(a.id) }
                    })
                  }
                  .layoutWeight(1)
                }
                .width('100%')
              }
              AppButton({
                label: '加入今日',
                variant: 'primary',
                onTap: (): void => { void this.addToToday(a) }
              })
            }
            .width('100%')
            .padding(Theme.space.cardPadding)
            .backgroundColor(Theme.colors().surfaceCard)
            .borderRadius(Theme.radius.lg)
            .border({ width: 1, color: Theme.colors().strokeHairline })
          }, (a: SavedActionItem) => a.id)

          Row().height(this.bottomInset)
        }
        .width('100%')
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX, top: Theme.space.pageY })
      }
      .scrollBar(BarState.Off)

      if (this.showAdd) {
        Stack({ alignContent: Alignment.Bottom }) {
          Column().width('100%').height('100%').backgroundColor(Theme.colors().overlayScrim)
            .onClick((): void => {
              this.showAdd = false
              AppStorage.setOrCreate('tabBarHidden', false)
            })
          Column({ space: Theme.space.s4 }) {
            Text('新建行动')
              .fontSize(Theme.type.title3)
              .fontWeight(FontWeight.Medium)
            TextInput({ text: this.newTitle, placeholder: '行动名称' })
              .onChange((v: string): void => { this.newTitle = v })
            TextInput({ text: this.newHint, placeholder: '一句提示（选填）' })
              .onChange((v: string): void => { this.newHint = v })
            AppButton({ label: '保存', variant: 'primary', onTap: (): void => { void this.saveUserAction() } })
          }
          .width('100%')
          .padding(Theme.space.s6)
          .backgroundColor(Theme.colors().surfaceCard)
          .borderRadius({ topLeft: Theme.radius.xl, topRight: Theme.radius.xl })
        }
        .width('100%')
        .height('100%')
        .zIndex(40)
      }

      if (this.toastText.length > 0) {
        Text(this.toastText)
          .fontSize(Theme.type.bodyS)
          .fontColor('#FFFFFF')
          .padding({ left: 16, right: 16, top: 10, bottom: 10 })
          .backgroundColor('rgba(26,42,58,0.92)')
          .borderRadius(Theme.radius.pill)
          .position({ x: '50%', y: 56 })
          .markAnchor({ x: '50%', y: 0 })
          .zIndex(50)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Theme.colors().surfacePage)
  }

  @Builder
  CatChip(label: string, key: string) {
    Text(label)
      .fontSize(Theme.type.caption)
      .fontColor(this.category === key ? Theme.colors().brandOnPrimary : Theme.colors().textSecondary)
      .padding({ left: 10, right: 10, top: 6, bottom: 6 })
      .backgroundColor(this.category === key ? Theme.colors().brandPrimary : Theme.colors().surfaceSubtle)
      .borderRadius(Theme.radius.pill)
      .onClick((): void => { this.category = key })
  }
}
