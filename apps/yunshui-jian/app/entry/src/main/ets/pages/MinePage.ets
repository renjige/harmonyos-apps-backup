import { Theme } from '../components/design-system/Theme'
import { AppButton } from '../components/design-system/AppButton'
import { AppListRow } from '../components/design-system/AppListRow'
import { AppStatCard } from '../components/design-system/AppStatCard'
import { AppDatePickerField } from '../components/design-system/AppDatePickerField'
import { LegalDocOverlay } from '../components/legal/LegalDocOverlay'
import { YunConfirmDialog } from '../components/yun/YunConfirmDialog'
import { YunTagChips } from '../components/yun/YunTagChips'
import { YunAnniversaryItem, YunAppStats, YunTagRecord } from '../models/YunModels'
import { YunDateHelper, YunLocalStore } from '../services/YunLocalStore'
import { PrivacyService } from '../services/PrivacyService'
import { ReminderService } from '../services/ReminderService'
import { AppContextService } from '../services/AppContextService'

@Component
export struct MinePage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop @Watch('onRefreshChange') refreshToken: number = 0
  @StorageLink('yunThemeTick') themeTick: number = 0
  onDataChanged: () => void = () => {}
  @State stats: YunAppStats = new YunAppStats()
  @State tags: YunTagRecord[] = []
  @State anniversaries: YunAnniversaryItem[] = []
  @State darkMode: boolean = false
  @State showSettings: boolean = false
  @State showPrivacyDoc: boolean = false
  @State showAgreementDoc: boolean = false
  @State toastText: string = ''
  @State confirmRevoke: boolean = false
  @State confirmClearCache: boolean = false
  @State confirmClearData: boolean = false
  @State editingTag: string = ''
  @State newTagName: string = ''
  @State annivTitle: string = ''
  @State annivDate: string = ''
  @State tagNames: string[] = []

  aboutToAppear(): void {
    void this.reload()
  }

  onRefreshChange(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    this.stats = await YunLocalStore.loadStats()
    this.tags = await YunLocalStore.loadTags()
    const names: string[] = []
    for (const t of this.tags) {
      names.push(t.name)
    }
    this.tagNames = names
    this.anniversaries = await YunLocalStore.loadAnniversaries()
    this.darkMode = await YunLocalStore.isDarkMode()
  }

  private showToast(msg: string): void {
    this.toastText = msg
    setTimeout((): void => { this.toastText = '' }, 2600)
  }

  private async saveTagRename(): Promise<void> {
    if (this.editingTag.length > 0 && this.newTagName.trim().length > 0) {
      await YunLocalStore.renameTag(this.editingTag, this.newTagName.trim())
      this.editingTag = ''
      this.newTagName = ''
      await this.reload()
      this.onDataChanged()
      this.showToast('标签已更新')
    }
  }

  private async deleteTag(name: string): Promise<void> {
    await YunLocalStore.deleteTag(name)
    await this.reload()
    this.onDataChanged()
    this.showToast('标签已删除')
  }

  private async addAnniversary(): Promise<void> {
    if (this.annivTitle.trim().length === 0 || this.annivDate.length === 0) {
      this.showToast('请填写纪念日名称与日期')
      return
    }
    const item = YunAnniversaryItem.create(
      YunDateHelper.newId(),
      this.annivTitle.trim(),
      this.annivDate
    )
    await YunLocalStore.saveAnniversary(item)
    this.annivTitle = ''
    this.annivDate = ''
    await this.reload()
    this.onDataChanged()
    this.showToast('纪念日已添加')
  }

  private async deleteAnniversary(id: string): Promise<void> {
    await YunLocalStore.deleteAnniversary(id)
    await this.reload()
    this.onDataChanged()
  }

  private async handleClearCache(): Promise<void> {
    this.confirmClearCache = false
    await YunLocalStore.clearCache()
    this.showToast('界面缓存已清理（数据未删除）')
  }

  private async handleClearAllData(): Promise<void> {
    this.confirmClearData = false
    const todos = await YunLocalStore.loadTodos()
    for (const t of todos) {
      if (t.reminderAgentId > 0) {
        await ReminderService.cancelTodo(t.reminderAgentId)
      }
    }
    await YunLocalStore.clearAllData()
    await this.reload()
    this.onDataChanged()
    this.showToast('全部数据已清除')
  }

  private async handleRevokePrivacy(): Promise<void> {
    await PrivacyService.revoke()
    this.confirmRevoke = false
    this.showSettings = false
    this.showToast('已撤回本机隐私标记。系统隐私托管请在系统设置中管理')
  }

  @Builder
  SettingsPanel() {
    Column({ space: Theme.space.s4 }) {
      Row() {
        Text('设置与隐私')
          .fontSize(Theme.type.title3)
          .fontWeight(FontWeight.Bold)
          .fontColor(Theme.colors().textPrimary)
          .layoutWeight(1)
        Text('关闭')
          .fontSize(Theme.type.body)
          .fontColor(Theme.colors().brandPrimary)
          .onClick((): void => { this.showSettings = false })
      }
      .width('100%')

      Text('本应用已接入华为应用市场隐私声明托管。启动时仅由系统展示托管声明，应用内不再弹出自行构建的授权窗。')
        .fontSize(Theme.type.bodyS)
        .fontColor(Theme.colors().textSecondary)
        .lineHeight(20)

      AppListRow({
        title: '用户协议',
        subtitle: '查看全文',
        onTap: (): void => { this.showAgreementDoc = true }
      })
      AppListRow({
        title: '隐私政策',
        subtitle: '查看全文',
        onTap: (): void => { this.showPrivacyDoc = true }
      })

      AppButton({
        label: '清除缓存',
        variant: 'secondary',
        onTap: (): void => { this.confirmClearCache = true }
      })

      AppButton({
        label: '清除全部数据',
        variant: 'danger',
        onTap: (): void => { this.confirmClearData = true }
      })

      Row() {
        AppButton({
          label: '撤回本机隐私标记',
          variant: 'secondary',
          onTap: (): void => { this.confirmRevoke = true }
        })
      }
      .width('100%')
      .onClick((): void => { this.confirmRevoke = true })
    }
    .width('100%')
    .padding(Theme.space.pageX)
  }

  build() {
    Stack() {
      Scroll() {
        Column({ space: Theme.space.s4 }) {
          Text('我的')
            .fontSize(Theme.type.title2)
            .fontWeight(FontWeight.Bold)
            .fontColor(Theme.colors().textPrimary)

          Row({ space: Theme.space.s3 }) {
            AppStatCard({ label: '札记', value: `${this.stats.noteCount}`, trend: '条记录' })
              .layoutWeight(1)
            AppStatCard({ label: '连续', value: `${this.stats.streakDays}`, trend: '天记录' })
              .layoutWeight(1)
          }
          .width('100%')

          Row({ space: Theme.space.s3 }) {
            AppStatCard({ label: '照片', value: `${this.stats.imageCount}`, trend: '张影像' })
              .layoutWeight(1)
            AppStatCard({ label: '提醒', value: `${this.stats.todoActive}`, trend: '待完成' })
              .layoutWeight(1)
          }
          .width('100%')

          Row({ space: Theme.space.s3 }) {
            AppStatCard({ label: '打卡', value: `${this.stats.habitCheckins}`, trend: '次累计' })
              .layoutWeight(1)
            AppStatCard({ label: '心情', value: `${this.stats.moodDays}`, trend: '天记录' })
              .layoutWeight(1)
          }
          .width('100%')

          Text('生活档案')
            .fontSize(Theme.type.subhead)
            .fontWeight(FontWeight.Medium)
            .fontColor(Theme.colors().brandDeep)

          Row({ space: Theme.space.s3 }) {
            AppStatCard({ label: '锦囊', value: `${this.stats.craftCount}`, trend: '条沉淀' })
              .layoutWeight(1)
            AppStatCard({ label: '目标', value: `${this.stats.goalOpen}`, trend: '进行中' })
              .layoutWeight(1)
          }
          .width('100%')

          Row({ space: Theme.space.s3 }) {
            AppStatCard({ label: '档案', value: `${this.stats.archiveDays}`, trend: '天累计' })
              .layoutWeight(1)
            AppStatCard({ label: '完成', value: `${this.stats.todoDone}`, trend: '件事项' })
              .layoutWeight(1)
          }
          .width('100%')

          Column({ space: Theme.space.s3 }) {
            Text('标签管理')
              .fontSize(Theme.type.subhead)
              .fontWeight(FontWeight.Medium)
              .fontColor(Theme.colors().textPrimary)
            if (this.tags.length === 0) {
              Text('写札记时添加标签，会在这里统一管理')
                .fontSize(Theme.type.bodyS)
                .fontColor(Theme.colors().textSecondary)
            } else {
              YunTagChips({ tags: this.tagNames })
              ForEach(this.tags, (tag: YunTagRecord) => {
                Row({ space: Theme.space.s2 }) {
                  Text(`${tag.name} (${tag.usageCount})`)
                    .fontSize(Theme.type.bodyS)
                    .fontColor(Theme.colors().textPrimary)
                    .layoutWeight(1)
                  Text('重命名')
                    .fontSize(Theme.type.caption)
                    .fontColor(Theme.colors().brandPrimary)
                    .onClick((): void => {
                      this.editingTag = tag.name
                      this.newTagName = tag.name
                    })
                  Text('删除')
                    .fontSize(Theme.type.caption)
                    .fontColor(Theme.colors().danger)
                    .onClick((): void => { void this.deleteTag(tag.name) })
                }
                .width('100%')
              }, (tag: YunTagRecord) => tag.name)
            }
            if (this.editingTag.length > 0) {
              Row({ space: Theme.space.s2 }) {
                TextInput({ text: this.newTagName, placeholder: '新标签名' })
                  .layoutWeight(1)
                  .height(44)
                  .fontSize(Theme.type.body)
                  .fontColor(Theme.colors().textPrimary)
                  .placeholderColor(Theme.colors().textSecondary)
                  .caretColor(Theme.colors().brandDeep)
                  .backgroundColor('#FFFFFF')
                  .borderRadius(Theme.radius.sm)
                  .border({ width: 1, color: Theme.colors().strokeStrong })
                  .padding({ left: 12, right: 12 })
                  .onChange((v: string) => { this.newTagName = v })
                Text('保存')
                  .fontSize(Theme.type.body)
                  .fontWeight(FontWeight.Medium)
                  .fontColor(Theme.colors().brandOnPrimary)
                  .padding({ left: 16, right: 16, top: 10, bottom: 10 })
                  .constraintSize({ minHeight: 44 })
                  .backgroundColor(Theme.colors().brandPrimary)
                  .borderRadius(Theme.radius.sm)
                  .onClick((): void => { void this.saveTagRename() })
              }
              .width('100%')
              .alignItems(VerticalAlign.Center)
            }
          }
          .width('100%')
          .padding(Theme.space.cardPadding)
          .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
          .borderRadius(Theme.radius.md)

          Column({ space: Theme.space.s3 }) {
            Text('纪念日')
              .fontSize(Theme.type.subhead)
              .fontWeight(FontWeight.Medium)
              .fontColor(Theme.colors().textPrimary)
            TextInput({ text: this.annivTitle, placeholder: '纪念日名称' })
              .height(44)
              .fontSize(Theme.type.body)
              .fontColor(Theme.colors().textPrimary)
              .placeholderColor(Theme.colors().textSecondary)
              .caretColor(Theme.colors().brandDeep)
              .backgroundColor('#FFFFFF')
              .borderRadius(Theme.radius.sm)
              .border({ width: 1, color: Theme.colors().strokeStrong })
              .padding({ left: 12, right: 12 })
              .onChange((v: string) => { this.annivTitle = v })
            AppDatePickerField({
              label: '日期',
              value: this.annivDate,
              placeholder: '选择日期',
              minDaysFromToday: -3650,
              maxDaysFromToday: 3650,
              onChange: (v: string) => { this.annivDate = v }
            })
            AppButton({
              label: '添加纪念日',
              variant: 'secondary',
              onTap: (): void => { void this.addAnniversary() }
            })
            ForEach(this.anniversaries, (a: YunAnniversaryItem) => {
              Row() {
                Column({ space: 2 }) {
                  Text(a.title)
                    .fontSize(Theme.type.body)
                    .fontColor(Theme.colors().textPrimary)
                  Text(`${a.dateKey} · ${YunDateHelper.daysUntil(a.dateKey, a.yearly)} 天后`)
                    .fontSize(Theme.type.caption)
                    .fontColor(Theme.colors().textSecondary)
                }
                .layoutWeight(1)
                .alignItems(HorizontalAlign.Start)
                Text('删除')
                  .fontSize(Theme.type.caption)
                  .fontColor(Theme.colors().danger)
                  .onClick((): void => { void this.deleteAnniversary(a.id) })
              }
              .width('100%')
              .padding({ top: 8, bottom: 8 })
            }, (a: YunAnniversaryItem) => a.id)
          }
          .width('100%')
          .padding(Theme.space.cardPadding)
          .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
          .borderRadius(Theme.radius.md)

          Row({ space: Theme.space.s3 }) {
            Text('深色模式')
              .fontSize(Theme.type.body)
              .fontColor(Theme.colors().textPrimary)
              .layoutWeight(1)
            Toggle({ type: ToggleType.Switch, isOn: this.darkMode })
              .selectedColor(Theme.colors().brandPrimary)
              .onChange((v: boolean) => {
                this.darkMode = v
                void YunLocalStore.setDarkMode(v)
              })
          }
          .width('100%')
          .padding(Theme.space.cardPadding)
          .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
          .borderRadius(Theme.radius.md)

          Column() {
            AppListRow({
              title: '设置与隐私',
              subtitle: '协议 · 华为隐私托管 · 清除缓存',
              onTap: (): void => { this.showSettings = true }
            })
          }
          .width('100%')
          .padding({ left: Theme.space.cardPadding, right: Theme.space.cardPadding })
          .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
          .borderRadius(Theme.radius.md)
        }
        .padding({
          left: Theme.space.pageX,
          right: Theme.space.pageX,
          top: Theme.space.s4,
          bottom: Theme.space.s10
        })
        .width('100%')
      }
      .width('100%')
      .height('100%')
      .backgroundColor(this.themeTick >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)

      if (this.showSettings) {
        Column() {
          Blank()
            .layoutWeight(1)
            .backgroundColor(Theme.colors().overlayScrim)
            .onClick((): void => { this.showSettings = false })
          Column() {
            this.SettingsPanel()
          }
          .width('100%')
          .padding({ top: Theme.space.s6, bottom: Theme.space.s8 })
          .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
          .borderRadius({ topLeft: Theme.radius.sheet, topRight: Theme.radius.sheet })
        }
        .width('100%')
        .height('100%')
        .zIndex(40)
      }

      if (this.showPrivacyDoc) {
        LegalDocOverlay({ kind: 'privacy', onClose: (): void => { this.showPrivacyDoc = false } })
      }
      if (this.showAgreementDoc) {
        LegalDocOverlay({ kind: 'agreement', onClose: (): void => { this.showAgreementDoc = false } })
      }

      if (this.confirmClearCache) {
        YunConfirmDialog({
          title: '清除缓存',
          message: '仅清理界面缓存，不会删除札记与提醒数据。',
          confirmLabel: '确认',
          onConfirm: (): void => { void this.handleClearCache() },
          onCancel: (): void => { this.confirmClearCache = false }
        })
      }
      if (this.confirmClearData) {
        YunConfirmDialog({
          title: '清除全部数据',
          message: '将删除所有札记、提醒与纪念日，且无法恢复。',
          confirmLabel: '确认清除',
          danger: true,
          onConfirm: (): void => { void this.handleClearAllData() },
          onCancel: (): void => { this.confirmClearData = false }
        })
      }
      if (this.confirmRevoke) {
        YunConfirmDialog({
          title: '撤回本机隐私标记',
          message: '仅清除本应用记录的同意标记，不会再次弹出应用内授权窗。系统隐私托管仍由华为统一管理。',
          confirmLabel: '确认撤回',
          onConfirm: (): void => { void this.handleRevokePrivacy() },
          onCancel: (): void => { this.confirmRevoke = false }
        })
      }

      if (this.toastText.length > 0) {
        Text(this.toastText)
          .fontSize(Theme.type.subhead)
          .fontColor(Theme.colors().brandOnPrimary)
          .padding({ left: 16, right: 16, top: 10, bottom: 10 })
          .backgroundColor(Theme.colors().brandDeep)
          .borderRadius(Theme.radius.pill)
          .position({ x: '8%', y: 56 })
          .zIndex(60)
      }
    }
    .width('100%')
    .height('100%')
  }
}
